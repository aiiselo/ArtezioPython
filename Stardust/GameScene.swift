//
//  GameScene.swift
//  Stardust
//
//  Created by Олеся Мартынюк on 12.02.2020.
//  Copyright © 2020 Olesia Martinyuk. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    let girl = SKSpriteNode(imageNamed: "GG1")
    var lastUpdateTime: TimeInterval = 0
    var deltaTime: TimeInterval = 0
    let girlMovePointsPerSec: CGFloat = 250.0
    var velocity = CGPoint.zero // вектор скорости спрайта (кол-во точек / сек)
    let playableRect: CGRect
    let deviceWidth = UIScreen.main.bounds.width
    let deviceHeight = UIScreen.main.bounds.height
    
    override init(size: CGSize) {
        let maxApectRatio: CGFloat = deviceHeight / deviceWidth
        let playableWidth = size.height / maxApectRatio
        // сцена заполняется полностью, чтобы центрировать воспроизводимый прямоугольник на экран, для этого край сверху и снизу высчитывается как  (высота сцены - воспроизводимая высота) /2
        let playableMargin = (size.width - playableWidth) / 2.0
        // пря-ник с максимальным соотношением сторон, в центре которого находится экран
        playableRect = CGRect(x: 0, y: playableMargin, width: playableWidth, height: size.height)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black // начальные настройки сцены
        let background = SKSpriteNode(imageNamed: "backgroundSpace")
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.position = CGPoint(x: 0, y: 0)
        background.size = CGSize(width: background.size.width / (background.size.height / deviceHeight), height: deviceHeight)
        background.zPosition = -1
        addChild(background)
        girl.position = CGPoint(x: 100, y: 500)
        addChild(girl)
        drawPlayableArea()
    }
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            deltaTime = currentTime - lastUpdateTime
        }
        else {
            deltaTime = 0
        }
        lastUpdateTime = currentTime
        move(sprite: girl, velocity: velocity)
        boundsCheck()
        flipSprite(sprite: girl, velocity: velocity)
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint){
        let amountToMove = CGPoint(x: velocity.x * CGFloat(deltaTime), y: velocity.y * CGFloat(deltaTime))
        sprite.position = CGPoint(x: sprite.position.x + amountToMove.x, y: sprite.position.y + amountToMove.y)
    }
    
    func moveGirl(location: CGPoint) {
        let offset = CGPoint(x:location.x - girl.position.x, y:location.y - girl.position.y)
        let length = sqrt(pow(offset.x, 2) + pow(offset.y, 2))
        let direction = CGPoint(x: offset.x / CGFloat(length), y: offset.y / CGFloat(length)) // нормированный вектор
        velocity = CGPoint(x: direction.x * girlMovePointsPerSec, y: direction.y * girlMovePointsPerSec)
    }
    
    func sceneTouched(touchLocation: CGPoint) {
        moveGirl(location: touchLocation)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
    
    func boundsCheck(){
        let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
        let topRight = CGPoint(x: playableRect.maxX, y: playableRect.maxY)
        if bottomLeft.x >= girl.position.x {
            girl.position.x = bottomLeft.x
            velocity.x *= -1
        }
        if topRight.x <= girl.position.x {
            girl.position.x = topRight.x
            velocity.x *= -1
        }
        if bottomLeft.y >= girl.position.y {
            girl.position.y = bottomLeft.y
            velocity.y *= -1
        }
        if topRight.y <= girl.position.y {
            girl.position.y = topRight.y
            velocity.y *= -1
        }
    }
    func drawPlayableArea() {
        let shape = SKShapeNode()
        shape.strokeColor = SKColor.black
        shape.lineWidth = 8
        addChild(shape)
    }
    
    func flipSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        if velocity.x < 0 {
            sprite.xScale = -1;
        }
        if velocity.x > 0 {
            sprite.xScale = 1;
        }
    }
}
