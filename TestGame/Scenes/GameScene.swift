//
//  GameScene.swift
//  TestGame
//
//  Created by Edward Gasparian on 03.10.2025.
//
//  ----------------------------------------------------
//  GameScene
//  ----------------------------------------------------
//  This file defines the main game logic using SpriteKit.
//
//  Responsibilities:
//  - Setup of the scene (background, floor, player, HUD).
//  - Spawning and handling physics of balls (enemies).
//  - Player actions: moving, jumping, and shooting bullets.
//  - Collision detection between bullets, balls, floor, and player.
//  - Score and lives tracking with HUD updates.
//  - Game state management (start countdown, restart, game over).
//  - Game Over overlay with buttons to Restart or Exit to Main Menu.
//  - Integration with UserDefaults for high score storage.
//  - Integration with AudioManager for background music and sound effects.
//
//  The scene lifecycle:
//  1. Scene is created -> countdown timer before unpausing.
//  2. Player spawns with floor and initial ball.
//  3. Game runs until player loses all lives.
//  4. On Game Over -> overlay with options is displayed.
//  5. Player can restart game instantly or exit back to menu.
//
//  Notes:
//  - Physics categories are defined in struct PhysicsCategory.
//  - UI elements (HUD and overlays) use SKLabelNode and SKSpriteNode.
//  - All sounds and music are managed through AudioManager.shared.
//  - Adaptive layout: HUD is positioned relative to frame edges, so it works
//    across different iPhone screen sizes (from SE to 17Pro Max).
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //MARK: - Gameplay state
    var isShooting = false
    var isJumping = false
    
    // Timers for shooting and spawning balls
    var shootingTimer: Timer?
    var ballTimer: Timer?
    
    // Touch tracking for jump and swipe moves
    var initialTouch: CGPoint?
    
    // Score and lives
    var score = 0
    var lives = 1
    
    // HUD labels
    var scoreLabel: SKLabelNode!
    var livesLabel: SKLabelNode!
    
    //MARK: - Physics Categories
    struct PhysicsCategory {
        static let player: UInt32 = 0x1 << 0
        static let bullet: UInt32 = 0x1 << 1
        static let ball: UInt32   = 0x1 << 2
        static let floor: UInt32  = 0x1 << 3
    }
    
    //MARK: - Scene lifecycle
    override func didMove(to view: SKView) {
        isPaused = true
        addBackground()
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .init(dx: 0, dy: -3)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.fontSize = 60
        label.fontColor = .white
        label.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(label)
        
        // Timer before game starts
        var count = 3
        label.text = "\(count)"
        
        _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            count -= 1
            if count > 0 {
                label.text = "\(count)"
            } else if count == 0 {
                label.text = "Start!"
            } else {
                label.removeFromParent()
                self.isPaused = false
                self.startGame()
                t.invalidate()
            }
        }
       
    }
    
    //MARK: - Setup methods
    func addFloor() {
        let floor = SKSpriteNode(color: .black, size: CGSize(width: frame.width, height: 20))
        floor.position = CGPoint(x: frame.midX, y: 10)
        floor.physicsBody = SKPhysicsBody(rectangleOf: floor.size)
        floor.physicsBody?.isDynamic = false
        floor.physicsBody?.categoryBitMask = PhysicsCategory.floor
        floor.physicsBody?.collisionBitMask = PhysicsCategory.ball | PhysicsCategory.player
        floor.physicsBody?.contactTestBitMask = PhysicsCategory.ball | PhysicsCategory.player
        
        addChild(floor)
    }
    
    func addPlayer() {
        let player = SKSpriteNode(imageNamed: "playerIMG")
        player.size = CGSize(width: 80, height: 80)
        player.position = CGPoint(x: frame.midX, y: 60)
        player.name = "player"
        
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.allowsRotation = false
        
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.ball | PhysicsCategory.floor
        player.physicsBody?.collisionBitMask = PhysicsCategory.ball | PhysicsCategory.floor
        
        addChild(player)
    }
    
    func addBackground() {
        let background = SKSpriteNode(imageNamed: "backgroundGameIMG")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.size = self.size
        background.zPosition = -1
        background.name = "backgroundGameIMG"
        addChild(background)
    }
    
    func addHUD(resetScore: Bool = true) {
        if resetScore { score = 0 }
        lives = 1
        
        // Score labels
        scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontSize = 20
        scoreLabel.fontName = "Helvetica-Bold"
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: frame.minX + 20, y: frame.maxY - 60)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        // Lives Label
        livesLabel = SKLabelNode(text: "Lives: \(lives)")
        livesLabel.fontSize = 20
        livesLabel.fontName = "Helvetica-Bold"
        livesLabel.fontColor = .white
        livesLabel.position = CGPoint(x: frame.maxX - 20, y: frame.maxY - 60)
        livesLabel.horizontalAlignmentMode = .right
        addChild(livesLabel)
    }
    
    //MARK: - Game flow
    func startGame() {
        addHUD(resetScore: true)
        addFloor()
        addPlayer()
        spawnBall()
        
        // Start ball spawner
        ballTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true ) { _ in
            self.spawnBall()
        }
    }
    
    func restartGame() {
        removeAllChildren()
        isPaused = false
        score = 0
        initialTouch = nil
        
        // Reset timers
        isShooting = false
        shootingTimer?.invalidate()
        shootingTimer = nil
        
        ballTimer?.invalidate()
        ballTimer = nil
        
        // Rebuild scene
        addHUD(resetScore: false)
        addBackground()
        addFloor()
        addPlayer()
        spawnBall()
        
        ballTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.spawnBall()
        }
    }
    
    func gameOver() {
        isPaused = true
        AudioManager.shared.playSFX(name: "gameOverSound")
        initialTouch = nil
        
        // Stop timers
        isShooting = false
        shootingTimer?.invalidate()
        shootingTimer = nil
        
        ballTimer?.invalidate()
        ballTimer = nil
        saveScore(score)
        
        // Dark overlay
        let overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.6),
                                   size: self.size)
        overlay.position = CGPoint(x: frame.midX, y: frame.midY)
        overlay.zPosition = 100
        overlay.name = "overlay"
        addChild(overlay)
        
        // Game Over Label
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontSize = 60
        gameOverLabel.fontName = "Helvetica-Bold"
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY + 120)
        gameOverLabel.zPosition = 101
        addChild(gameOverLabel)
        
        // Restart Button
        let restartBackground = SKShapeNode(rectOf: CGSize(width: 200, height: 80), cornerRadius: 12)
        restartBackground.fillColor = .yellow.withAlphaComponent(0.3)
        restartBackground.strokeColor = .yellow
        restartBackground.position = CGPoint(x: frame.midX, y: frame.midY + 20)
        restartBackground.zPosition = 100
        restartBackground.name = "restartButton"
        addChild(restartBackground)
        
        let restartLabel = SKLabelNode(text: "Restart")
        restartLabel.fontSize = 40
        restartLabel.fontName = "Helvetica-Bold"
        restartLabel.fontColor = .yellow
        restartLabel.verticalAlignmentMode = .center
        restartLabel.position = .zero
        restartLabel.zPosition = 101
        restartBackground.addChild(restartLabel)
        
        // Main Menu Button
        let menuBackground = SKShapeNode(rectOf: CGSize(width: 220, height: 80), cornerRadius: 12)
        menuBackground.fillColor = .cyan.withAlphaComponent(0.3)
        menuBackground.strokeColor = .cyan
        menuBackground.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        menuBackground.zPosition = 100
        menuBackground.name = "menuButton"
        addChild(menuBackground)
        
        let menuLabel = SKLabelNode(text: "Main Menu")
        menuLabel.fontSize = 40
        menuLabel.fontName = "Helvetica-Bold"
        menuLabel.fontColor = .cyan
        menuLabel.verticalAlignmentMode = .center
        menuLabel.position = .zero
        menuLabel.zPosition = 101
        menuBackground.addChild(menuLabel)
    }
    
    //MARK: - Game objects
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
        
        // Give ball random horizontal velocity
        let randomX = CGFloat.random(in: -200...200)
        ball.physicsBody?.velocity = CGVector(dx: randomX, dy: 0)
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
        
        AudioManager.shared.playSFX(name: "laserShot")
    }
    
    //MARK: - Physics contact
    func didBegin(_ contact: SKPhysicsContact) {
        // Get nodes involved in collision
        guard let nodeA = contact.bodyA.node,
              let nodeB = contact.bodyB.node else { return }
        
        // Collect names of both nodes for easier checks
        let names = [nodeA.name, nodeB.name]
        
        // Bullet hits ball =>
        if names.contains("bullet") && names.contains("ball") {
            // Increase score for destroying a ball
            score += 10
            scoreLabel.text = "Score: \(score)"
            
            // Determine which is the bullet and which is the ball
            let bullet = (nodeA.name == "bullet" ? nodeA : nodeB)
            let ball = (nodeA.name == "ball" ? nodeA : nodeB)
            
            // Remove bullet on impact
            bullet.removeFromParent()
            
            // If big ball => split
            if let shape = ball as? SKShapeNode {
                let radius = shape.frame.width / 2
                if radius > 20 {
                    let newRadius = radius / 2
                    // Spawn two smaller balls
                    spawnBall(radius: newRadius, position: CGPoint(x: shape.position.x - 20, y: shape.position.y))
                    spawnBall(radius: newRadius, position: CGPoint(x: shape.position.x + 20, y: shape.position.y))
                }
                // Remove original ball (destroyed by bullet)
                shape.removeFromParent()
            }
        }
        
        // Player touches floor => reset jump
        if names.contains("player") && names.contains("floor") {
            isJumping = false
        }
        
        // Player hit by ball => lose life
        if names.contains("player") && names.contains("ball") {
            lives -= 1
            livesLabel.text = "Lives: \(lives)"
            if lives <= 0 {
                gameOver()
            }
        }
    }
    
    // MARK: - Controls
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Get the first touch (ignore multitouch for now)
        guard let touch = touches.first else { return }
        let location = touch.location(in: self) // touch location in the scene
        let nodes = nodes(at: location)         // All nodes at that location
        
        // User taped restart button on game over screen
        if nodes.contains(where: { $0.name == "restartButton" }) {
            restartGame()
            return
        }
        
        // User taped main menu button on game over screen
        if nodes.contains(where: { $0.name == "menuButton" }) {
            NotificationCenter.default.post(name: Notification.Name("exitToMenu"), object: nil)
            return
        }
        
        // If game paused => ignore touches
        if isPaused {
            return
        }
        
        // Save initial touch point (used to detect swipe direction later)
        initialTouch = location
        
        // If the touch was on the player node => start shooting
        if let player = childNode(withName: "player"), player.contains(location) {
            startShooting(from: player.position)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Ignore input when game is paused
        guard !isPaused else {return}
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Move player horizontally to follow touch
        if let player = childNode(withName: "player") {
            player.position.x = location.x
            
            // If finger moved outside player sprite => stop shooting
            if !player.contains(location) {
                stopShooting()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let endLocation = touch.location(in: self)
        
        // Detect swipe up => jump
        if let start = initialTouch {
            let dy = endLocation.y - start.y        // Vertical distance moved
            let dx = abs(endLocation.x - start.x)   // Horizontal distance moved
            
            // Only trigger jump if swipe is mostly vertical and large
            if dy > 50 && dy > dx {
                jump()
            }
        }
        // When finger is lifted => stop shooting
        stopShooting()
    }
    //MARK: - Update loop
    override func update(_ currentTime: TimeInterval) {
        //removes bullets outside screen
        enumerateChildNodes(withName: "bullet") { bullet, _ in
            if bullet.position.y > self.frame.maxY {
                bullet.removeFromParent()
            }
        }
        
        //reset jump state when player lands
        if let player = childNode(withName: "player") as? SKSpriteNode {
            if abs(player.physicsBody?.velocity.dy ?? 0) < 0.1 && player.position.y <= 70 {
                isJumping = false
            }
        }
    }
    
    //MARK: - Actions
    func jump() {
        guard let player = childNode(withName: "player") as? SKSpriteNode else { return }
        
        if !isJumping {
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
            isJumping = true
            AudioManager.shared.playSFX(name: "playerJumped")
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
    
    //MARK: - Score persistence
    func saveScore( _ newScore: Int) {
        var scores = UserDefaults.standard.array(forKey: "scores") as? [Int] ?? []
        scores.insert(newScore, at: 0)
        if scores.count > 10 {
            scores = Array(scores.prefix(10))
        }
        UserDefaults.standard.set(scores, forKey: "scores")
    }
    
}
