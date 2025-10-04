//
//  GameScene.swift
//  TestGame
//
//  Created by Edward Gasparian on 03.10.2025.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var isShooting = false
    var isJumping = false
    
    var shootingTimer: Timer?
    var ballTimer: Timer?
    var initialTouch: CGPoint?
    
    var score = 0
    var lives = 3
    
    var scoreLabel: SKLabelNode!
    var livesLabel: SKLabelNode!
    
    struct PhysicsCategory {
        static let player: UInt32 = 0x1 << 0
        static let bullet: UInt32 = 0x1 << 1
        static let ball: UInt32   = 0x1 << 2
        static let floor: UInt32  = 0x1 << 3
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .systemGray
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .init(dx: 0, dy: -3)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        addHUD(resetScore: true)
        addFloor()
        addPlayer()
        spawnBall()
        
        ballTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true ) { _ in
            self.spawnBall()
        }
    }
    
    func addFloor() {
        let floor = SKSpriteNode(color: .brown, size: CGSize(width: frame.width, height: 20))
        floor.position = CGPoint(x: frame.midX, y: 10)
        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        floor.physicsBody?.isDynamic = false
        floor.physicsBody?.categoryBitMask = PhysicsCategory.floor
        floor.physicsBody?.collisionBitMask = PhysicsCategory.ball | PhysicsCategory.player
        floor.physicsBody?.contactTestBitMask = PhysicsCategory.ball | PhysicsCategory.player
        
        addChild(floor)
    }
    
    func addPlayer() {
        let player = SKSpriteNode(color: .blue, size: CGSize(width: 50, height: 50))
        player.position = CGPoint(x: frame.midX, y: 60)
        player.name = "player"
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.allowsRotation = false
        
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.ball | PhysicsCategory.floor
        player.physicsBody?.collisionBitMask = PhysicsCategory.ball | PhysicsCategory.floor
        
        addChild(player)
    }
    
    func spawnBall(radius: CGFloat? = nil, position: CGPoint? = nil) {
        let randomRadius = radius ?? CGFloat.random(in: 15...25)
        
        let ball = SKShapeNode(circleOfRadius: randomRadius)
        ball.fillColor = .red
        ball.name = "ball"
        
        let pos = position ?? CGPoint(
            x: CGFloat.random(in: 50 ... (frame.width - 50)),
            y: frame.maxY - 50
        )
        ball.position = pos
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: randomRadius)
        ball.physicsBody?.restitution = 0.9
        ball.physicsBody?.friction = 0
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.allowsRotation = true
        ball.physicsBody?.angularDamping = 0.5
        ball.physicsBody?.categoryBitMask = PhysicsCategory.ball
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.bullet
        addChild(ball)
        
        let randomX = CGFloat.random(in: -200...200)
        ball.physicsBody?.velocity = CGVector(dx: randomX, dy: 0)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node,
              let nodeB = contact.bodyB.node else { return }
        
        let names = [nodeA.name, nodeB.name]
        
        // bullet + ball
        if names.contains("bullet") && names.contains("ball") {
            score += 10
            scoreLabel.text = "Score: \(score)"
            
            let bullet = (nodeA.name == "bullet" ? nodeA : nodeB)
            let ball = (nodeA.name == "ball" ? nodeA : nodeB)
            
            bullet.removeFromParent()
            
            if let shape = ball as? SKShapeNode {
                let radius = shape.frame.width / 2
                if radius > 20 {
                    let newRadius = radius / 2
                    spawnBall(radius: newRadius, position: CGPoint(x: shape.position.x - 20, y: shape.position.y))
                    spawnBall(radius: newRadius, position: CGPoint(x: shape.position.x + 20, y: shape.position.y))
                }
                shape.removeFromParent()
            }
        }
        
        if names.contains("player") && names.contains("floor") {
            isJumping = false
        }
        
        // player + ball
        if names.contains("player") && names.contains("ball") {
            lives -= 1
            livesLabel.text = "Lives: \(lives)"
            if lives <= 0 {
                gameOver()
            }
        }
    }
    
    func shoot(from position: CGPoint) {
        let bullet = SKShapeNode(circleOfRadius: 10)
        bullet.fillColor = .yellow
        bullet.position = position
        bullet.name = "bullet"
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.velocity = CGVector(dx: 0, dy: 600)
        
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.bullet
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.ball
        addChild(bullet)
    }
    
    func gameOver() {
        isPaused = true
        initialTouch = nil
        
        isShooting = false
        shootingTimer?.invalidate()
        shootingTimer = nil
        
        ballTimer?.invalidate()
        ballTimer = nil
        saveScore(score)
        
        let overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.6),
                                   size: self.size)
        overlay.position = CGPoint(x: frame.midX, y: frame.midY)
        overlay.zPosition = 100
        overlay.name = "overlay"
        addChild(overlay)
        
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontSize = 50
        gameOverLabel.fontName = "Helvetica-Bold"
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY + 60)
        gameOverLabel.zPosition = 101
        addChild(gameOverLabel)
        
        // Restart
        let restartLabel = SKLabelNode(text: "Restart")
        restartLabel.fontSize = 30
        restartLabel.fontName = "Helvetica-Bold"
        restartLabel.fontColor = .yellow
        restartLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        restartLabel.zPosition = 101
        restartLabel.name = "restartButton"
        addChild(restartLabel)
        
        // Exit to menu
        let menuLabel = SKLabelNode(text: "Main Menu")
        menuLabel.fontSize = 30
        menuLabel.fontName = "Helvetica-Bold"
        menuLabel.fontColor = .cyan
        menuLabel.position = CGPoint(x: frame.midX, y: frame.midY - 60)
        menuLabel.zPosition = 101
        menuLabel.name = "menuButton"
        addChild(menuLabel)
    }
    
    func restartGame() {
        removeAllChildren()
        isPaused = false
        score = 0
        
        isShooting = false
        shootingTimer?.invalidate()
        shootingTimer = nil
        
        ballTimer?.invalidate()
        ballTimer = nil
        
        initialTouch = nil
        addHUD(resetScore: false)
        
        addFloor()
        addPlayer()
        spawnBall()
        
        ballTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.spawnBall()
        }
    }
    
    // MARK: - Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)
        
        if nodes.contains(where: { $0.name == "restartButton" }) {
            restartGame()
            return
        }
        
        if nodes.contains(where: { $0.name == "menuButton" }) {
            NotificationCenter.default.post(name: Notification.Name("exitToMenu"), object: nil)
            return
        }
        
        if isPaused {
            restartGame()
            return
        }
        
        initialTouch = location
        
        if let player = childNode(withName: "player"), player.contains(location) {
            startShooting(from: player.position)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isPaused else {return}
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if let player = childNode(withName: "player") {
            player.position.x = location.x
            if !player.contains(location) {
                stopShooting()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let endLocation = touch.location(in: self)
        
        // Визначаємо свайп
        if let start = initialTouch {
            let dy = endLocation.y - start.y
            let dx = abs(endLocation.x - start.x)
            
            // Свайп вгору (мінімум 50 пікселів і вертикаль переважає горизонталь)
            if dy > 50 && dy > dx {
                jump()
            }
        }
        
        stopShooting()
    }
    
    override func update(_ currentTime: TimeInterval) {
        enumerateChildNodes(withName: "bullet") { bullet, _ in
            if bullet.position.y > self.frame.maxY {
                bullet.removeFromParent()
            }
        }
        
        if let player = childNode(withName: "player") as? SKSpriteNode {
            if abs(player.physicsBody?.velocity.dy ?? 0) < 0.1 && player.position.y <= 70 {
                isJumping = false
            }
        }
    }
    
    func jump() {
        guard let player = childNode(withName: "player") as? SKSpriteNode else { return }
        
        if !isJumping {
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 40))
            isJumping = true
        }
    }
    
    func startShooting(from _: CGPoint) {
        guard !isShooting else { return }
        isShooting = true
        
        shootingTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            guard let self = self,
                  let player = self.childNode(withName: "player") else { return }
            
            self.shoot(from: CGPoint(x: player.position.x, y: player.position.y + 40))
        }
    }

    func stopShooting() {
        isShooting = false
        shootingTimer?.invalidate()
        shootingTimer = nil
    }
    
    func addHUD(resetScore: Bool = true) {
        if resetScore {
            score = 0
        }
        lives = 3
        
        scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontSize = 20
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: frame.minX + 20, y: frame.maxY - 60)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        livesLabel = SKLabelNode(text: "Lives: \(lives)")
        livesLabel.fontSize = 20
        livesLabel.fontName = "Helvetica-Bold"
        livesLabel.fontColor = .black
        livesLabel.position = CGPoint(x: frame.maxX - 20, y: frame.maxY - 60)
        livesLabel.horizontalAlignmentMode = .right
        addChild(livesLabel)
    }
    
    func saveScore( _ newScore: Int) {
        var scores = UserDefaults.standard.array(forKey: "scores") as? [Int] ?? []
        scores.insert(newScore, at: 0)
        if scores.count > 10 {
            scores = Array(scores.prefix(10))
        }
        UserDefaults.standard.set(scores, forKey: "scores")
    }
}
