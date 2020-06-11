//
//  MusicController.swift
//  Stardust
//
//  Created by Олеся Мартынюк on 05.06.2020.
//  Copyright © 2020 Olesia Martinyuk. All rights reserved.
//

import Foundation
import AVFoundation

var backgroundPlayer: AVAudioPlayer!

func playBackgroundMusic() {
    let url = Bundle.main.url(forResource: "backgroundMusic.m4a", withExtension: nil)
    do {
        try
            backgroundPlayer = AVAudioPlayer(contentsOf: url!)
            backgroundPlayer.numberOfLoops = -1
            backgroundPlayer.prepareToPlay()

    } catch {
        print("Error during music read")
        return
    }
    backgroundPlayer.volume = 0.3
    backgroundPlayer.play()
}
   
func stopBackgroundMusic() {
    backgroundPlayer.stop()
}
