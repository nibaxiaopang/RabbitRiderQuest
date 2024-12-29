//
//  GameScene.swift
//  RabbitRiderQuest
//
//  Created by RabbitRiderQuest on 2024/12/29.
//

import UIKit
import SpriteKit
import CoreMotion

//MARK: Game Class

class RabbitHighwaySurvivalGameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties
    
    let road1 = SKSpriteNode(imageNamed: "ic_road")
    let road2 = SKSpriteNode(imageNamed: "ic_road")
    let plane = SKSpriteNode(imageNamed: "ic_bike")
    var scoreLabel: SKLabelNode! // Score label
    
    let motionManager = CMMotionManager()
    var currentZombies: [SKSpriteNode] = []
    var isGameOver = false
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)" // Update the score label
            NotificationCenter.default.post(name: NSNotification.Name("ScoreDidChange"), object: self, userInfo: ["newScore": score])
        }
    }
    
    struct PhysicsCategory {
        static let none: UInt32 = 0
        static let all: UInt32 = UInt32.max
        static let zombie: UInt32 = 0b1
        static let bullet: UInt32 = 0b10
        static let plane: UInt32 = 0b100
    }
    
    // MARK: - Lifecycle
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupPlane()
        setupScoreLabel() // Setup the score label
        setupMotionManager()
        spawnZombiesPeriodically()
        setupSwipeGestures()
        startScoring()
        
        physicsWorld.contactDelegate = self
        
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = borderBody
    }
    
    // MARK: - Setup Methods
    
    func setupBackground() {
        road1.size = CGSize(width: size.width, height: size.height)
        road1.position = CGPoint(x: size.width / 2, y: size.height / 2)
        road1.zPosition = -1
        addChild(road1)
        
        road2.size = CGSize(width: size.width, height: size.height)
        road2.position = CGPoint(x: size.width / 2, y: size.height + size.height / 2)
        road2.zPosition = -1
        addChild(road2)
    }
    
    func setupPlane() {
        plane.size = CGSize(width: 80, height: 150)
        plane.position = CGPoint(x: size.width / 2, y: plane.size.height / 2 + 20)
        plane.zPosition = 1
        plane.physicsBody = SKPhysicsBody(rectangleOf: plane.size)
        plane.physicsBody?.isDynamic = false // The player shouldn't be affected by physics forces
        plane.physicsBody?.categoryBitMask = PhysicsCategory.plane
        plane.physicsBody?.contactTestBitMask = PhysicsCategory.zombie
        plane.physicsBody?.collisionBitMask = PhysicsCategory.none
        addChild(plane)
    }
    
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 120)
        scoreLabel.zPosition = 10
        scoreLabel.text = "Score: \(score)"
        addChild(scoreLabel)
    }
    
    func setupMotionManager() {
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { [weak self] (data, error) in
            guard let data = data, error == nil else { return }
            self?.movePlane(acceleration: data.acceleration)
        }
    }
    
    func setupSwipeGestures() {
        guard let view = self.view else { return }
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            swipeUp.direction = .up
            view.addGestureRecognizer(swipeUp)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        view.addGestureRecognizer(longPress)
        
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        let movement: CGFloat = 50.0
        let verticalMovement: CGFloat = 50.0
        
        if gesture.direction == .right {
            var newPosition = plane.position.x + movement
            newPosition = min(newPosition, size.width - plane.size.width / 2)
            plane.position.x = newPosition
        } else if gesture.direction == .left {
            var newPosition = plane.position.x - movement
            newPosition = max(newPosition, plane.size.width / 2)
            plane.position.x = newPosition
        } else if gesture.direction == .up {
            var newPosition = plane.position.y + verticalMovement
            newPosition = min(newPosition, size.height - plane.size.height / 2) // Ensure it doesn't go outside the top edge
            plane.position.y = newPosition
        }
        
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            startMovingDown()
        case .ended, .cancelled:
            stopMovingDown()
        default:
            break
        }
    }

    func startMovingDown() {
        let moveDownAction = SKAction.moveBy(x: 0, y: -5, duration: 0.1)
        let repeatAction = SKAction.repeatForever(moveDownAction)
        plane.run(repeatAction, withKey: "moveDown")
    }

    func stopMovingDown() {
        plane.removeAction(forKey: "moveDown")
    }
    
    func movePlane(acceleration: CMAcceleration) {
        let movement = CGFloat(acceleration.x) * 500
        var newPosition = plane.position.x + movement
        newPosition = max(newPosition, plane.size.width / 2)
        newPosition = min(newPosition, size.width - plane.size.width / 2)
        plane.position.x = newPosition
    }
    
    func spawnZombiesPeriodically() {
        let spawnAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            let zombie = self.createZombie()
            self.addChild(zombie)
            zombie.run(SKAction.moveBy(x: 0, y: -self.size.height, duration: 5))
        }
        let waitAction = SKAction.wait(forDuration: 1.5)
        run(SKAction.repeatForever(SKAction.sequence([spawnAction, waitAction])))
    }
    
    func createZombie() -> SKSpriteNode {
        let zombie = SKSpriteNode(imageNamed: "obstacleBike")
        zombie.size = CGSize(width: 60, height: 70)
        zombie.position = CGPoint(x: CGFloat.random(in: 0...size.width), y: size.height)
        zombie.physicsBody = SKPhysicsBody(rectangleOf: zombie.size)
        zombie.physicsBody?.isDynamic = true
        zombie.physicsBody?.categoryBitMask = PhysicsCategory.zombie
        zombie.physicsBody?.contactTestBitMask = PhysicsCategory.plane
        zombie.physicsBody?.collisionBitMask = PhysicsCategory.none
        return zombie
    }
    
    // MARK: - Scrolling Background
    
    func scrollBackground() {
        road1.position.y -= 5
        road2.position.y -= 5
        
        if road1.position.y <= -size.height / 2 {
            road1.position.y = road2.position.y + size.height
        }
        if road2.position.y <= -size.height / 2 {
            road2.position.y = road1.position.y + size.height
        }
    }
    
    // MARK: - Scoring System
    
    func startScoring() {
        let scoreIncrement = SKAction.run { [weak self] in
            guard let self = self, !self.isGameOver else { return }
            self.score += 1
        }
        let waitAction = SKAction.wait(forDuration: 1.0) // Increment score every second
        let scoringSequence = SKAction.sequence([scoreIncrement, waitAction])
        run(SKAction.repeatForever(scoringSequence), withKey: "scoring")
    }
    
    // MARK: - Game Loop
    
    override func update(_ currentTime: TimeInterval) {
        scrollBackground()
    }
    
    // MARK: - Contact Detection
    
    func didBegin(_ contact: SKPhysicsContact) {
        if isGameOver { return }
        
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.plane | PhysicsCategory.zombie {
            gameOver()
        }
    }
    
    // MARK: - Game Over
    
    func gameOver() {
        isGameOver = true
        
        self.viewController?.checkPoRecord()
        
        // Stop scoring
        removeAction(forKey: "scoring")
        
        // Pause the scene
        self.isPaused = true

        // Show game over alert
        let alert = UIAlertController(title: "Game Over", message: "You collided with an obstacle! Your Score: \(score)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Restart", style: .default, handler: { _ in
            self.restartGame()
        }))
        
        if let viewController = view?.window?.rootViewController {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    func restartGame() {
        isGameOver = false
        self.isPaused = false
        score = 0

        children.filter { $0 is SKSpriteNode && $0 != plane && $0 != road1 && $0 != road2 }
            .forEach { $0.removeFromParent() }
        
        plane.position = CGPoint(x: size.width / 2, y: plane.size.height / 2 + 20)
        startScoring() // Restart scoring
    }
}
