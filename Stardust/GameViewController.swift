//
//  GameViewController.swift
//  Stardust
//
//  Created by Олеся Мартынюк on 12.02.2020.
//  Copyright © 2020 Olesia Martinyuk. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() { // вызов метода супер-класса, дальнейшая загрузка сцены 
        super.viewDidLoad()
        let scene = GameScene(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        let skView = self.view as! SKView
        skView.showsFPS = true // устанавливаем отображение FPS на экране
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFill // режимое масштабирования
        skView.presentScene(scene)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
