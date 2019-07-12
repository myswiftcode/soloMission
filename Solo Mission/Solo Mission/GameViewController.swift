//
//  GameViewController.swift
//  Solo Mission
//
//  Created by V.Sergeev on 07/07/2019.
//  Copyright © 2019 v.sergeev.m@icloud.com. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
// Добавляем AVFoundation(звуковые эффекты)
import AVFoundation

class GameViewController: UIViewController {
    
    var backingAudio = AVAudioPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Загружаем звуковой формат файла
        let filePath = Bundle.main.path(forResource: "spaceinvaders1", ofType: "mpeg")
        let audioNSURL = NSURL(fileURLWithPath: filePath!)
        
        do { backingAudio = try AVAudioPlayer(contentsOf: audioNSURL as URL) }
        catch { return print("Cannot Find The Audio!") }
        
        // Сколько раз проигрывать файл 1 or 10 или бесконечно -1
        backingAudio.numberOfLoops = -1
        // Уровень звука volume = 1 or 10 (в нашем случае зависит от настроек самого девайса play() )
        backingAudio.play()
        
        let scene = MainMenuScene(size: CGSize(width: 1536, height: 2048))
        
            let view = self.view as! SKView
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
                
            // Present the scene
            view.presentScene(scene)

            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
