//
//  GameScene.swift
//  Solo Mission
//
//  Created by V.Sergeev on 07/07/2019.
//  Copyright © 2019 v.sergeev.m@icloud.com. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    let player = SKSpriteNode(imageNamed: "playerShip")
    let playerBulletSoundEffect = SKAction.playSoundFileNamed("playerBullet.mp3", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        
        // Пишем фон
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.zPosition = 0
        self.addChild(background)
        
        // Пишем игрока
        player.setScale(0.5)
        player.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.2)
        player.zPosition = 2
        self.addChild(player)
    }
    
    func playerCircleBullet(){
        
        let bullet = SKSpriteNode(imageNamed: "playerBullet")
        bullet.setScale(0.5)
        bullet.position = player.position
        bullet.zPosition = 1
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([playerBulletSoundEffect, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        playerCircleBullet()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Реализовываем движение игрока от прикосновения на дисплее
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self.view)
            let previousPointOfTouch = touch.previousLocation(in: self.view)
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            player.position.x += amountDragged
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
