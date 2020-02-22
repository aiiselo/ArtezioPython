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
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black // начальные настройки сцены
        let background = SKSpriteNode(imageNamed: "backgroundSpace")
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
        girl.position = CGPoint(x: 450, y: 1024)
        addChild(girl)
    }
    override func update(_ currentTime: TimeInterval) {
        <#code#>
    }
    
}
