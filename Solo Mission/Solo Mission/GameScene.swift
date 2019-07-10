//
//  GameScene.swift
//  Solo Mission
//
//  Created by V.Sergeev on 07/07/2019.
//  Copyright © 2019 v.sergeev.m@icloud.com. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    let player = SKSpriteNode(imageNamed: "playerShip")
    let playerBulletSoundEffect = SKAction.playSoundFileNamed("playerBullet.mp3", waitForCompletion: false)
    let explosionSundEffect = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    
    
    struct PhysicsCategories {
        static let pNone : UInt32 = 0
        static let pPlayer : UInt32 = 0b1  // 1
        static let pBullet : UInt32 = 0b10 // 2
        static let pEnemy : UInt32 = 0b100 // 4
    }
    
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
        
        // Добавляем физику в игру
        self.physicsWorld.contactDelegate = self
        
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
        // Добавляем фищику
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.pPlayer
        player.physicsBody!.contactTestBitMask = PhysicsCategories.pNone
        player.physicsBody!.contactTestBitMask = PhysicsCategories.pEnemy
        self.addChild(player)
        
        startNewLevel()
    }
    
    // Создаем обработку контактов спрайтов
    func didBegin(_ contact: SKPhysicsContact) {
        //
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        } else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == PhysicsCategories.pPlayer && body2.categoryBitMask == PhysicsCategories.pEnemy {
            // Игрок наносит урон врагу
            
            if body1.node != nil {
                spawnEnemyExplosion(spawnPosition: body1.node!.position)
            }
            
            if body2.node != nil {
                spawnEnemyExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            //body2.node?.removeFromParent() // Косякцц
            
            spawnEnemyExplosion(spawnPosition: body1.node!.position)
            spawnEnemyExplosion(spawnPosition: body2.node!.position)
        }
        
        if body1.categoryBitMask == PhysicsCategories.pBullet && body2.categoryBitMask == PhysicsCategories.pEnemy && (body2.node?.position.y)! < self.size.height {
            // Пуля наносит урон варгу
            
            if body2.node != nil {
                spawnEnemyExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            //spawnEnemyExplosion(spawnPosition: body2.node!.position)
        }
        
    }
    
    func spawnEnemyExplosion(spawnPosition: CGPoint) {
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explosionSundEffect, scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
        
    }
    
    func startNewLevel() {
        
        // Создаем задержку для появление противника и разделяем createEnemy01() от touchesBegan()
        let spawn = SKAction.run(createEnemy01)
        let waitToSpawn = SKAction.wait(forDuration: 2.5) // время задержки  при 0.1 - 40 спрайтов врагов!
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
        // Добавляем физику
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.pBullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.pNone
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.pEnemy
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
        // Добавляем физику
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.pEnemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.pNone
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.pPlayer | PhysicsCategories.pBullet
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
