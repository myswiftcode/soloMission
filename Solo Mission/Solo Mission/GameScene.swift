//
//  GameScene.swift
//  Solo Mission
//
//  Created by V.Sergeev on 07/07/2019.
//  Copyright © 2019 v.sergeev.m@icloud.com. All rights reserved.
//

import SpriteKit
//import CoreMotion
//import GameplayKit

// Добавляем счет игр
var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    // Добвляем жизнь игроку
    var livesNumber = 3
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    // Добавляем уровни в игре
    var levelNumber = 0
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    let player = SKSpriteNode(imageNamed: "playerShip")
    let playerBulletSoundEffect = SKAction.playSoundFileNamed("playerBullet.mp3", waitForCompletion: false)
    let explosionSundEffect = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    
    // Добавляем появление игрока по нажатию на экран(выезжает с низу экрана)
    let tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    // Появлеине Босса стадия 01
    let BossInvasionStage01 = SKLabelNode(fontNamed: "The Bold Font")
    
    // Для акселерометра
    //var xAccelerate:CGFloat = 0
    
    // Обазаначем переменную для управления кораблем игрока в игре
    //let motionManager = CMMotionManager()
    
    // Добавляем события игры
    enum gameState {
        // До начала игры
        case preGame
        // Во время игры
        case inGame
        // Появление босса
        case bossInvStag01
        // В конце игры gameOver
        case afterGame
    }
    
    // До начала игры
    var currentGameState = gameState.preGame
    
    
    struct PhysicsCategories {
        static let pNone : UInt32 = 0
        static let pPlayer : UInt32 = 0b1  // 1
        static let pBullet : UInt32 = 0b10 // 2
        static let pEnemy : UInt32 = 0b100 // 4
        static let pBoss: UInt32 = 0b1000  // 5
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
        
        // Счетчик в 0
        gameScore = 0
        
        // Добавляем физику в игру
        self.physicsWorld.contactDelegate = self
        
        // Пишем фон с прокруткой и зацикливанием
        for i in 0...1 {
            let background = SKSpriteNode(imageNamed: "background")
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            background.position = CGPoint(x: self.size.width / 2, y: self.size.height * CGFloat(i))
            background.zPosition = 0
            background.name = "background"
            self.addChild(background)
        }
        
        // Пишем игрока
        player.setScale(0.3)
        //player.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.2)
        player.position = CGPoint(x: self.size.width / 2, y: 0 - player.size.height)
        player.zPosition = 2
        
        // Добавляем физику
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.pPlayer
        player.physicsBody!.contactTestBitMask = PhysicsCategories.pNone
        player.physicsBody!.contactTestBitMask = PhysicsCategories.pEnemy
        self.addChild(player)
        
        // Добавляем текс на экран игры
        // Счетчик
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.15, y: self.size.height + livesLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        // Жизни игрока
        livesLabel.text = "Levels: 3"
        livesLabel.fontSize = 70
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width * 0.85, y: self.size.height + scoreLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        // Добавляем логику появления верхних меню на экране
        //let moveOnToScreenAction = SKAction.move(to: self.size.height*0.9, duration: 0.3)
        let moveOnToScreenActionScoreLabel = SKAction.moveTo(y: self.size.height * 0.9, duration: 0.3)
        scoreLabel.run(moveOnToScreenActionScoreLabel)
        
        let moveOnToScreenActionLivesLabel = SKAction.moveTo(y: self.size.height * 0.9, duration: 0.3)
        livesLabel.run(moveOnToScreenActionLivesLabel)
        
        // Нажмите на экран чтобы начать игру
        tapToStartLabel.text = "Tap To Begin Game"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.2)
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        
        // Добавляем появление
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)
        
        // Появление босса
        BossInvasionStage01.text = "Boss Invasion!"
        BossInvasionStage01.fontSize = 100
        BossInvasionStage01.fontColor = SKColor.white
        BossInvasionStage01.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.2)
        BossInvasionStage01.alpha = 0
        self.addChild(BossInvasionStage01)
        
        let bossInvasionStage01 = SKAction.fadeIn(withDuration: 0.3)
        BossInvasionStage01.run(bossInvasionStage01)
        
        //startNewLevel()
        
//        // Время обновления
//        motionManager.accelerometerUpdateInterval = 0.2
//        // Добавляем параметры для обновления
//        // Шаблонный метод для управления акселерометором на iPhone, для iPad нужно переработать
//        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error: Error?) in
//            if let accelerometerData = data {
//                let acceleration = accelerometerData.acceleration
//                // Плавное передвижение игрока на экране
//                self.xAccelerate = CGFloat(acceleration.x) * 0.75 + self.xAccelerate * 0.25
//            }
//        }

    }
    
    // Логика для старта игры
    func startGame() {
        currentGameState = gameState.inGame
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        
        let moveShipOnScreenAction = SKAction.moveTo(y: self.size.height * 0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOnScreenAction, startLevelAction])
        player.run(startGameSequence)
    }
    
    // Добавляем проверку жизней и конец игры
    func loseAlife(){
        
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
        
        if livesNumber == 0 {
            runGameOver()
        }
    }
    
    // Добавляем обработчик счетчика игры
    func addScore() {
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        // Добавляем события - новый уровень при достижении количества убитых врагов
//        if gameScore == 10 || gameScore == 25 || gameScore == 50 {
//            startNewLevel()
//        }
        
        // Добавляем события - новый уровень при достижении количества убитых врагов
        switch gameScore {
//        case 10: gameScore += 50
//                 startNewLevel()
        case 11: gameScore += 5
                 createBossInvasionLevelStage01()
        default:
            print("Cannot find Game Score level!")
        }
    }
    
    // Создаем обработку конца игры
    func runGameOver() {
        
        currentGameState = gameState.afterGame
        
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Bullet") {
            bullet, stop in
            bullet.removeAllActions()
        }
        
        self.enumerateChildNodes(withName: "Enemy") {
            enemy, stop in
            enemy.removeAllActions()
        }
        
        // Создаем переключение экрана после конца игры с задержкой в 1 секунду
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
    }
    
    func changeScene() {
        let sceneToMove = GameOverScene(size: self.size)
        sceneToMove.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMove, transition: myTransition)
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
            //spawnEnemyExplosion(spawnPosition: body2.node!.position)
            
            runGameOver()
        }
        
        if body1.categoryBitMask == PhysicsCategories.pBullet && body2.categoryBitMask == PhysicsCategories.pEnemy && (body2.node?.position.y)! < self.size.height {
            // Пуля наносит урон варгу
            
            addScore()
            
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
        
        levelNumber += 1
        
        if self.action(forKey: "spawningEnemies") != nil {
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        switch levelNumber {
            // время задержки  при 0.1 - 40 спрайтов врагов!
            case 1: levelDuration = 1.2
            case 2: levelDuration = 1
            case 3: levelDuration = 0.8
            case 4: levelDuration = 0.5
            default:
                levelDuration = 0.5
                print("Cannot find level info")
        }
        
        
        // Создаем задержку для появление противника и разделяем createEnemy01() от touchesBegan()
        let spawn = SKAction.run(createEnemy01)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
        self.run(spawnForever)
    }
    
    // Пуля от игрока
    func playerCircleBullet(){
        
        let bullet = SKSpriteNode(imageNamed: "playerBullet")
        bullet.name = "Bullet"
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
    
    // Создаем первого босса
    func createBossInvasionLevelStage01() {
        
        //currentGameState = gameState.bossInvStag01
        
        // Задержка перед появлением
        //_ = SKAction.wait(forDuration: 2)
        
        // Появление Босса стадия 01
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        
        // Добавляем босса первой стадии
        let bossStageInvLev01 = SKSpriteNode(imageNamed: "enemyShip")
        bossStageInvLev01.name = "BossStage01"
        bossStageInvLev01.setScale(0.8)
        bossStageInvLev01.position = startPoint
        // Добавляем физику
        bossStageInvLev01.physicsBody = SKPhysicsBody(rectangleOf: bossStageInvLev01.size)
        bossStageInvLev01.physicsBody!.affectedByGravity = false
        bossStageInvLev01.physicsBody!.categoryBitMask = PhysicsCategories.pEnemy
        bossStageInvLev01.physicsBody!.collisionBitMask = PhysicsCategories.pNone
        bossStageInvLev01.physicsBody!.contactTestBitMask = PhysicsCategories.pPlayer | PhysicsCategories.pBullet
        bossStageInvLev01.zPosition = 2
        self.addChild(bossStageInvLev01)
        
        // DEBUG:
        // Удаляем всех врагов
        self.enumerateChildNodes(withName: "Enemy") {
            enemy, stop in
            enemy.removeAllActions()
        }
        
    }
    
    // Создаем противника
    func createEnemy01() {
        
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.name = "Enemy"
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
        let loseALifeAction = SKAction.run(loseAlife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction])
        
        if currentGameState == gameState.inGame {
            enemy.run(enemySequence)
        }
        
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
        
        // Логика для пре старта игры
        if currentGameState == gameState.preGame {
            startGame()
        }
        // Если статус не выполнен в preGame то выполняем inGame
        else if currentGameState == gameState.inGame {
            playerCircleBullet()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Реализовываем движение игрока от прикосновения на дисплее
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self.view)
            let previousPointOfTouch = touch.previousLocation(in: self.view)
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            if currentGameState == gameState.inGame {
                player.position.x += amountDragged
            }
            
            // Добавляем проверку на игровую зону
            // Проверка - право
            if player.position.x >= gameArea.maxX - player.size.width / 10 {
                player.position.x = gameArea.maxX - player.size.width / 2
            }
            // Проверка - лево
            if player.position.x <= gameArea.minX + player.size.width / 10 {
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
    
//    override func didSimulatePhysics() {
//        // Добавляем скорость перемещения игрока по экрану * 50
//        player.position.x += xAccelerate * 50
//        if player.position.x < 0 {
//            player.position = CGPoint(x: UIScreen.main.bounds.height - player.size.width, y: player.position.y)
//        } else if player.position.x > UIScreen.main.bounds.width {
//            player.position = CGPoint(x: 20, y: player.position.y)
//        }
//    }
    
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var amountToMovePerSecond: CGFloat = 600.0
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        } else {
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
        
        self.enumerateChildNodes(withName: "background") {
            background, stop in
            
            if self.currentGameState == gameState.inGame {
                background.position.y -= amountToMoveBackground
            }
            
            if background.position.y < -self.size.height {
                background.position.y += self.size.height * 2
            }
        }
    }
}
