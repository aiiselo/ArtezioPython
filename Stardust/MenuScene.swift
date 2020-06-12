//
//  MenuScene.swift
//  Stardust
//
//  Created by Олеся Мартынюк on 11.06.2020.
//  Copyright © 2020 Olesia Martinyuk. All rights reserved.
//

import UIKit
import SpriteKit

class MenuScene: SKScene {
    
    let deviceWidth = UIScreen.main.bounds.width
    let deviceHeight = UIScreen.main.bounds.height
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "Menu")
        background.position = CGPoint(x: deviceWidth/2, y: deviceHeight/2)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.size = CGSize(width: background.size.width / (background.size.height / deviceHeight), height: deviceHeight)
        background.zPosition = -1
        addChild(background)
        
        let tapNode = SKSpriteNode(imageNamed: "tapToStart")
        tapNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        tapNode.position = CGPoint(x: deviceWidth/2, y: deviceHeight/3.5)
        tapNode.size = CGSize(width: deviceWidth / 5, height: tapNode.size.height * (deviceWidth / 5) / tapNode.size.width)
        addChild(tapNode)
        
        let actionAppearance = SKAction.scale(to: 4, duration: 0.5)
        let actionDisappearance = SKAction.scale(to: 3, duration: 0.5)
        let sequence = SKAction.sequence([actionAppearance, actionDisappearance])
        tapNode.run(SKAction.repeatForever(sequence))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let defaultScene = GameScene(size: self.size)
        defaultScene.scaleMode = self.scaleMode
        let transition = SKTransition.moveIn(with: SKTransitionDirection(rawValue:2)!, duration: 1)
        self.view?.presentScene(defaultScene, transition: transition)
    }
}
