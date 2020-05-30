//
//  GameOver.swift
//  Stardust
//
//  Created by Олеся Мартынюк on 02.05.2020.
//  Copyright © 2020 Olesia Martinyuk. All rights reserved.
//

import UIKit
import SpriteKit

class GameOver: SKScene {
    let victory: Bool
    let deviceWidth = UIScreen.main.bounds.width
    let deviceHeight = UIScreen.main.bounds.height
    
    init(victory:Bool, size: CGSize) {
        self.victory = victory
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        let background: SKSpriteNode
        if victory {
            background = SKSpriteNode(imageNamed: "victoryOver")
            background.position = CGPoint(x: deviceWidth/2 - 35, y: deviceHeight/2)
            let actionVictoryMusic = SKAction.playSoundFileNamed("victory.wav", waitForCompletion: true)
            run(actionVictoryMusic)
        }
        else {
            background = SKSpriteNode(imageNamed: "failOver")
            background.position = CGPoint(x: deviceWidth/2, y: deviceHeight/2)
            let actionFailMusic = SKAction.playSoundFileNamed("lose.wav", waitForCompletion: true)
            run(actionFailMusic)
        }
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.size = CGSize(width: background.size.width / (background.size.height / deviceHeight), height: deviceHeight)
        addChild(background)
        
        let actionWait = SKAction.wait(forDuration: 5)
        let actionReturn = SKAction.run {
            let defaultScene = GameScene(size: self.size)
            defaultScene.scaleMode = self.scaleMode
            let transition = SKTransition.fade(with: SKColor.white, duration: 1.5)
            self.view?.presentScene(defaultScene, transition: transition)
        }
        
        run(SKAction.sequence([actionWait, actionReturn]))

    }
    
}
