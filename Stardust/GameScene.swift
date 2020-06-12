//
//  GameScene.swift
//  Stardust
//
//  Created by Олеся Мартынюк on 12.02.2020.
//  Copyright © 2020 Olesia Martinyuk. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    let cameraNode = SKCameraNode()
    
    let girl = SKSpriteNode(imageNamed: "GG1")
    var lastUpdateTime: TimeInterval = 0
    var deltaTime: TimeInterval = 0
    let girlMovePointsPerSec: CGFloat = 500.0
    let cameraMovePointsPerSec: CGFloat = 100.0
    var velocity = CGPoint.zero // вектор скорости спрайта (кол-во точек / сек)
    
    let playableRect: CGRect
    var cameraRect: CGRect
    
    let deviceWidth = UIScreen.main.bounds.width
    let deviceHeight = UIScreen.main.bounds.height
    var touchLocation: CGPoint?
    
    let girlAnimation: SKAction
    let asteroidAnimation: SKAction
    let starAnimation: SKAction
    
    let girlCategory:UInt32 = 0x1 << 1;
    let asteroidCategory:UInt32 = 0x1 << 2;
    let starCategory:UInt32 = 0x1 << 3;
    
    var isImmortal: Bool = false
    let defaultLives = 5
    var lives = 5
    var gameResult: Bool = false
    var stars = 0
    let maxStars = 20
    
    let livesLabel = SKLabelNode(fontNamed: "ArialRoundedMTBold")
    let starsLabel = SKLabelNode(fontNamed: "ArialRoundedMTBold")

    
    override init(size: CGSize) {
        let maxApectRatio: CGFloat = deviceHeight / deviceWidth
        let playableWidth = size.height / maxApectRatio
        // сцена заполняется полностью, чтобы центрировать воспроизводимый прямоугольник на экран, для этого край сверху и снизу высчитывается как  (высота сцены - воспроизводимая высота) /2
        let playableMargin = (size.width - playableWidth) / 2.0
        // пря-ник с максимальным соотношением сторон, в центре которого находится экран
        playableRect = CGRect(x: 0, y: playableMargin, width: playableWidth, height: size.height)
        
        var texturesGirl:[SKTexture] = []
        for i in 1...6 {
            texturesGirl.append(SKTexture(imageNamed: "GG\(i)"))
        }
        girlAnimation = SKAction.animate(with: texturesGirl, timePerFrame: 0.1)
        
        var texturesAsteroid: [SKTexture] = []
        for i in 1...6 {
            texturesAsteroid.append(SKTexture(imageNamed: "Ast\(i)"))
        }
        asteroidAnimation = SKAction.animate(with: texturesAsteroid, timePerFrame: 0.05)
        
        var texturesStar: [SKTexture] = []
        for i in 1...6 {
            texturesStar.append(SKTexture(imageNamed: "Star\(i)"))
        }
        starAnimation = SKAction.animate(with: texturesStar, timePerFrame: 0.05)
        playBackgroundMusic()
        
        self.cameraRect = CGRect(x: cameraNode.position.x - size.width / 2 + (size.width - playableRect.width) / 2, y: cameraNode.position.y - size.height / 2 + (size.height - playableRect.height) / 2, width: playableRect.width, height: playableRect.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMove(to view: SKView) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        backgroundColor = SKColor.black // начальные настройки сцены
        for i in 0...1 {
            let background = generateBackground()
            background.anchorPoint = CGPoint.zero
            background.name = "background"
            background.position = CGPoint(x: 0, y: background.size.height * CGFloat(i))
            addChild(background)
        }
        
        girl.position = CGPoint(x: deviceWidth / 2, y: self.size.height / 4)
        girl.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: girl.size.width - 50, height: girl.size.height - 50))
        girl.physicsBody!.contactTestBitMask = starCategory + asteroidCategory
        girl.name = "girl"
        girl.physicsBody?.categoryBitMask = girlCategory
        girl.physicsBody?.isDynamic = false
        
        addChild(girl)
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 3.0),
                                                      SKAction.run({
                                                        [weak self] in self?.generateAsteroid()
                                                      })])))
        run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 0.8),
                                                      SKAction.run({
                                                        [weak self] in self?.generateStars()
                                                      })])))
        playBackgroundMusic()
        addChild(cameraNode)
        self.camera = cameraNode
        cameraNode.position = CGPoint(x:self.size.width / 2, y: self.size.height / 2)
        
        livesLabel.text = updateLives(defaultLives: defaultLives, lives: lives).text
        livesLabel.fontColor = SKColor.white
        livesLabel.fontSize = 25
        livesLabel.zPosition = 150
        livesLabel.position = CGPoint(x: Int(self.cameraRect.maxX - 10) , y: Int(self.cameraRect.maxY - 60))
        livesLabel.horizontalAlignmentMode = .right
        cameraNode.addChild(livesLabel)
        
        starsLabel.text = "⭐️ \(stars)/\(maxStars)"
        starsLabel.fontSize = 25
        starsLabel.zPosition = 150
        starsLabel.position = CGPoint(x: Int(self.cameraRect.maxX - 10) , y: Int(self.cameraRect.maxY - 90))
        starsLabel.horizontalAlignmentMode = .right
        cameraNode.addChild(starsLabel)
        
//        print("self size: \(self.size.width),  \(self.size.height)")
//        print("camera position: \(camera?.position.x), \(camera?.position.y)")
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            deltaTime = currentTime - lastUpdateTime
        }
        else {
            deltaTime = 0
        }
        lastUpdateTime = currentTime
        /** COMMENT CODE BLOCK BELOW FOR ANOTHER GIRL MOVING */
        if let touchLocation_ = touchLocation {
            let distancePoint = CGPoint(x: touchLocation_.x - girl.position.x, y: touchLocation_.y - girl.position.y)
            let distance = sqrt(pow(distancePoint.x, 2) + pow(distancePoint.y, 2))
            if distance <= girlMovePointsPerSec * CGFloat(deltaTime) {
                velocity = CGPoint.zero
                girl.position = touchLocation!
                stopAnimation(sprite: girl, spriteAction: girlAnimation)
            }
            else {
                move(sprite: girl, velocity: velocity)
                flipSprite(sprite: girl, velocity: velocity)
            }
        }
        /** COMMENT CODE BLOCK BELOW FOR ANOTHER GIRL MOVING */
        
//        move(sprite: girl, velocity: velocity)
//        flipSprite(sprite: girl, velocity: velocity)
        bordersCheck()
        if lives <= 0 || stars >= maxStars {
            if lives <= 0 {
                self.gameResult = false
                let gameOverScene = GameOver(victory: gameResult, size: size)
                gameOverScene.scaleMode = scaleMode
                let transition = SKTransition.fade(with: SKColor.red, duration: 1.5)
                view?.presentScene(gameOverScene, transition: transition)
                stopBackgroundMusic()
            }
            else {
                self.gameResult = true
                let gameOverScene = GameOver(victory: gameResult, size: size)
                gameOverScene.scaleMode = scaleMode
                let transition = SKTransition.fade(with: SKColor.green, duration: 1.5)
                view?.presentScene(gameOverScene, transition: transition)
                stopBackgroundMusic()
            }
        }
        moveCamera()
        starsLabel.text = "⭐️ \(stars)/\(maxStars)"
        livesLabel.text = updateLives(defaultLives: defaultLives, lives: lives).text
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint){
        let amountToMove = CGPoint(x: velocity.x * CGFloat(deltaTime), y: velocity.y * CGFloat(deltaTime))
        sprite.position = CGPoint(x: sprite.position.x + amountToMove.x, y: sprite.position.y + amountToMove.y)
    }
    
    func moveCamera() {
        cameraNode.position = CGPoint(x: cameraNode.position.x, y: cameraNode.position.y + cameraMovePointsPerSec * CGFloat(deltaTime))
        self.cameraRect = CGRect(x: cameraNode.position.x - size.width / 2 + (size.width - playableRect.width) / 2, y: cameraNode.position.y - size.height / 2 + (size.height - playableRect.height) / 2, width: playableRect.width, height: playableRect.height)
        enumerateChildNodes(withName: "background") { (node, stop) in
            let bg = node as!SKSpriteNode
            if bg.position.y + bg.size.height < self.cameraRect.origin.y { // если один из экранов полностью прокрутился, то перемещаем вперед
                bg.position = CGPoint(x: bg.position.x, y: bg.position.y + bg.size.height * 2)
            }
        }
    }
    
    func moveGirl(location: CGPoint) {
        startAnimation(sprite: girl, spriteAction: girlAnimation)
        let offset = CGPoint(x:location.x - girl.position.x, y:location.y - girl.position.y)
        let length = sqrt(pow(offset.x, 2) + pow(offset.y, 2))
        let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length)) // нормированный вектор
        velocity = CGPoint(x: direction.x * girlMovePointsPerSec, y: direction.y * girlMovePointsPerSec)
    }
    
    func sceneTouched(touchLocation_: CGPoint) {
        touchLocation = touchLocation_
        moveGirl(location: touchLocation_)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        sceneTouched(touchLocation_: touch.location(in: self))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        sceneTouched(touchLocation_: touch.location(in: self))
    }
    
    /** UNCOMMENT FOR ANOTHER GIRL MOVING */
    
     func bordersCheck(){
         let bottomLeft = CGPoint(x: 0, y: cameraRect.minY)
         //let topRight = CGPoint(x: cameraRect.maxX, y: cameraRect.maxY)
//         if bottomLeft.x >= girl.position.x {
//             girl.position.x = bottomLeft.x
//             velocity.x *= -1
//         }
//         if topRight.x <= girl.position.x {
//             girl.position.x = topRight.x
//             velocity.x *= -1
//         }
         if bottomLeft.y >= girl.position.y - girl.size.height/2 {
            girl.position.y = bottomLeft.y + girl.size.height/2 + 1
             //velocity.y *= -1
         }
//         if topRight.y <= girl.position.y {
//             girl.position.y = topRight.y
//             velocity.y *= -1
//         }
     }
    
    func flipSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        if velocity.x < 0 {
            sprite.xScale = -1;
        }
        if velocity.x > 0 {
            sprite.xScale = 1;
        }
    }
    
    func generateBackground() -> SKSpriteNode {
        let background = SKSpriteNode()
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.name = "background"
        
        let background1 = SKSpriteNode(imageNamed: "backgroundSpace")
        background1.anchorPoint = CGPoint(x: 0, y: 0)
        background1.position = CGPoint(x: 0, y: 0)
        let height = background1.size.height / (background1.size.width / deviceWidth)
        background1.size = CGSize(width: deviceWidth, height: height)
        background.addChild(background1)
//        print("background1 size: \(background1.size.width), \(background1.size.height)")
        
        let background2 = SKSpriteNode(imageNamed: "backgroundSpace")
        background2.anchorPoint = CGPoint(x: 0, y: 0)
        background2.position = CGPoint(x: 0, y: background1.size.height)
        background2.size = CGSize(width: deviceWidth, height: height)
        background.addChild(background2)
//        print("background2 size: \(background2.size.width), \(background2.size.height)")
        
        background.size = CGSize(width: deviceWidth, height: background1.size.height * 2)
//        print("background size: \(background.size.width), \(background.size.height)")
        background.zPosition = -1
        return background
    }
    
    func generateAsteroid() {
        let timeIntervalAsteroid: TimeInterval = TimeInterval(Float.random(in: 2 ... 3))
        let asteroid = SKSpriteNode(imageNamed: "Ast1")
        asteroid.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        asteroid.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: asteroid.size.width - 50, height: asteroid.size.height - 50))
        asteroid.name = "asteroid"
        asteroid.physicsBody!.contactTestBitMask = girlCategory
        asteroid.physicsBody?.categoryBitMask = asteroidCategory
        
        let positionX = Int.random(in: 0 ... Int(size.width))
        asteroid.position = CGPoint(x: positionX, y: Int(self.cameraRect.maxY + asteroid.size.height/2))
        addChild(asteroid)
        let actionDownStraight = SKAction.move(to: CGPoint(x: positionX, y: 0 - Int(asteroid.size.height) / 2), duration: timeIntervalAsteroid)
        let actionDownRight = SKAction.move(to: CGPoint(x: Int(size.width)/2 + Int(size.width)/4, y: 0 - Int(asteroid.size.height) / 2), duration: timeIntervalAsteroid)
        let actionDownLeft = SKAction.move(to: CGPoint(x: Int(size.width)/2 - Int(size.width)/4, y: 0 - Int(asteroid.size.height) / 2), duration: timeIntervalAsteroid)
        let actionDelete = SKAction.removeFromParent()
        
        let randomMove = Int.random(in: 0 ..< 3)
        if randomMove == 0 {
            startAnimation(sprite: asteroid, spriteAction: asteroidAnimation)
            asteroid.run(SKAction.sequence([actionDownStraight, actionDelete]))
        }
        if randomMove == 1 {
            startAnimation(sprite: asteroid, spriteAction: asteroidAnimation)
            asteroid.run(SKAction.sequence([actionDownLeft, actionDelete]))
        }
        if randomMove == 2 {
            startAnimation(sprite: asteroid, spriteAction: asteroidAnimation)
            asteroid.run(SKAction.sequence([actionDownRight, actionDelete]))
        }
    }
    
    func generateStars() {
        let timeIntervalStar: TimeInterval = TimeInterval(Float.random(in: 3...5))
        let star = SKSpriteNode(imageNamed: "Star1")
        star.physicsBody = SKPhysicsBody(rectangleOf: star.size)
        star.name = "star"
        star.physicsBody!.categoryBitMask = starCategory
        star.physicsBody!.contactTestBitMask = girlCategory
        star.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let positionX = Int.random(in: 0 ... Int(size.width))
        star.position = CGPoint(x: positionX, y: Int(self.cameraRect.maxY + star.size.height / 2))
        addChild(star)
        let actionAppearance = SKAction.scale(to: 0.9, duration: 4)
        let actionFall = SKAction.move(to: CGPoint(x: positionX, y: 0 - Int(star.size.height) / 2), duration: timeIntervalStar)
        let actionDelete = SKAction.removeFromParent()
        let actionGroup = SKAction.group([actionFall, actionAppearance])
        let sequence = SKAction.sequence([actionGroup, actionDelete])
        startAnimation(sprite: star, spriteAction: starAnimation)
        star.run(sequence)
    }
    
    func startAnimation(sprite: SKSpriteNode, spriteAction:SKAction) {
        if sprite.action(forKey: "animation") == nil {
            sprite.run(SKAction.repeatForever(spriteAction), withKey: "animation")
        }
    }
    
    func stopAnimation(sprite: SKSpriteNode, spriteAction:SKAction) {
        sprite.removeAction(forKey: "animation")
    }
    
    func collision(between girl: SKNode, object: SKNode) {
        if object.name == "star" {
            self.stars += 1
            if self.stars >= maxStars {
                if lives <= 0 {
                    self.gameResult = false
                    let gameOverScene = GameOver(victory: gameResult, size: size)
                    gameOverScene.scaleMode = scaleMode
                    let transition = SKTransition.moveIn(with: SKTransitionDirection(rawValue:1)!, duration: 1)
                    view?.presentScene(gameOverScene, transition: transition)
                }
                else {
                    self.gameResult = true
                    let gameOverScene = GameOver(victory: gameResult, size: size)
                    gameOverScene.scaleMode = scaleMode
                    let transition = SKTransition.moveIn(with: SKTransitionDirection(rawValue:1)!, duration: 1)
                    view?.presentScene(gameOverScene, transition: transition)
                }
            }
            let i = Int.random(in: 1...4)
            run(SKAction.playSoundFileNamed("Star\(i).wav", waitForCompletion: false))
            destroy(object: object)
        }
        
        if object.name == "asteroid" {
            if self.stars >= 2 {
                self.stars -= 2
            }
            lives -= 1
            if lives <= 0 {
                self.gameResult = false
                let gameOverScene = GameOver(victory: gameResult, size: size)
                gameOverScene.scaleMode = scaleMode
                let transition = SKTransition.moveIn(with: SKTransitionDirection(rawValue:1)!, duration: 1)
                view?.presentScene(gameOverScene, transition: transition)
                stopBackgroundMusic()
            }
            let blinksAmount = 10.0
            let duration = 2.0
            let actionBlink = SKAction.customAction(withDuration: duration, actionBlock: {(node, elapsedTime) in
                let slice = duration / blinksAmount
                let reminder = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
                node.isHidden = reminder > slice / 2
            })
            let actionInvisible = SKAction.run { [weak self] in
                self?.girl.isHidden = false
                self?.isImmortal = false
            }
            girl.run(SKAction.sequence([actionBlink, actionInvisible]))
            self.isImmortal = false
            let i = Int.random(in: 1...2)
            run(SKAction.playSoundFileNamed("Ast\(i).wav", waitForCompletion: false))
            destroy(object: object)
        }
    }
    
    func destroy(object: SKNode) {
        object.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
        if contact.bodyA.node?.name == "girl" {
            if contact.bodyB.node?.name == "asteroid" && isImmortal == false || contact.bodyB.node?.name == "star" {
                collision(between: nodeA, object: nodeB)
            }
        }
        if contact.bodyB.node?.name == "girl" {
            if contact.bodyA.node?.name == "asteroid" && isImmortal == false || contact.bodyA.node?.name == "star" {
                collision(between: nodeB, object: nodeA)
            }
        }
    }
    
    func updateLives(defaultLives: Int, lives: Int) -> SKLabelNode {
        var labelLives: String = ""
        for _ in 0...lives-1 {
            labelLives += String("❤️")
        }
        if defaultLives - lives > 0 {
            for _ in 0...(defaultLives-lives-1) {
                labelLives += String("🤍")
            }
        }
        return SKLabelNode(text: labelLives)
    }
}
