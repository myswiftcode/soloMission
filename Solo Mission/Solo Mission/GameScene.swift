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
    
    // Создаем случайную
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFF)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat(arc4random_uniform(UInt32(max - min)) + UInt32(min))
    }
    
    // Создаем игровую зону для игрока и врагов
    var gameArea: CGRect
    
    override init(size: CGSize) {
        let maxAspectRation: CGFloat = 16.0 / 9.0
        let playableWidth = size.height / maxAspectRation
        let mardin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: mardin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        // Пишем фон
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.zPosition = 0
        self.addChild(background)
        
        // Пишем игрока
        player.setScale(0.3)
        player.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.2)
        player.zPosition = 2
        self.addChild(player)
        
        startNewLevel()
    }
    
    func startNewLevel() {
        
        // Создаем задержку для появление противника и разделяем createEnemy01() от touchesBegan()
        let spawn = SKAction.run(createEnemy01)
        let waitToSpawn = SKAction.wait(forDuration: 2) // время задержки  при 0.1 - 40 спрайтов врагов!
        let spawnSequence = SKAction.sequence([spawn, waitToSpawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever)
    }
    
    // Пуля от игрока
    func playerCircleBullet(){
        
        let bullet = SKSpriteNode(imageNamed: "playerBullet")
        bullet.setScale(0.3)
        bullet.position = player.position
        bullet.zPosition = 1
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([playerBulletSoundEffect, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
    }
    
    // Создаем противника
    func createEnemy01() {
        
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.setScale(0.2)
        enemy.position = startPoint
        enemy.zPosition = 2
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 4) // Скорость полета врагов 1 - быстро ... 9 - очень медленно
        let deleteEnemy = SKAction.removeFromParent()
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        enemy.run(enemySequence)
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
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
        //createEnemy01()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Реализовываем движение игрока от прикосновения на дисплее
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self.view)
            let previousPointOfTouch = touch.previousLocation(in: self.view)
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            player.position.x += amountDragged
            
            // Добавляем проверку на игровую зону
            // Проверка - право
            if player.position.x >= gameArea.maxX - player.size.width / 2 {
                player.position.x = gameArea.maxX - player.size.width / 2
            }
            // Проверка - лево
            if player.position.x <= gameArea.minX + player.size.width / 2 {
                player.position.x = gameArea.minX + player.size.width / 2
            }
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
