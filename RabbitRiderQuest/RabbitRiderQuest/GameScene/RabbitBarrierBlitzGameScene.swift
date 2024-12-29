//
//  GameScene3.swift
//  RabbitRiderQuest
//
//  Created by RabbitRiderQuest on 2024/12/29.
//

import UIKit
import SpriteKit
import GameplayKit

// MARK: - Game Scene

class RabbitBarrierBlitzGameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties
    let player = SKSpriteNode(imageNamed: "playerImage")
    let background = SKSpriteNode(imageNamed: "ic_gamebg1")
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
            NotificationCenter.default.post(name: NSNotification.Name("BarrierBlitzScoreDidChange"), object: self, userInfo: ["newScore": score])
        }
    }
    var currentLine: SKShapeNode?
    var linePath = CGMutablePath()
    var removedObstaclesCount = 0
    
    // Physics Categories
    struct PhysicsCategory {
        static let none: UInt32 = 0
        static let player: UInt32 = 0b1
        static let obstacle: UInt32 = 0b10
        static let line: UInt32 = 0b100
    }
    
    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        setupScene()
        setupPlayer()
        setupScoreLabel()
        startSpawningObstacles()
    }
    
    // MARK: - Setup Methods
    func setupScene() {
        physicsWorld.contactDelegate = self
        backgroundColor = .clear

        // Setup Background
        background.size = self.size
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = -1
        addChild(background)
        
        // Add edges to the screen for boundary
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.categoryBitMask = PhysicsCategory.none
    }
    
    func setupPlayer() {
        player.size = CGSize(width: 80, height: 80)
        player.position = CGPoint(x: frame.midX, y: frame.minY + player.size.height + 20)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = false
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle
        player.physicsBody?.collisionBitMask = PhysicsCategory.none
        addChild(player)
    }
    
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 120)
        scoreLabel.text = "Score: \(score)"
        addChild(scoreLabel)
    }
    
    // MARK: - Obstacle Spawning
    func startSpawningObstacles() {
        let spawn = SKAction.run { [weak self] in
            self?.spawnObstacle()
        }
        let delay = SKAction.wait(forDuration: 1.0)
        let sequence = SKAction.sequence([spawn, delay])
        run(SKAction.repeatForever(sequence), withKey: "spawningObstacles")
    }
    
    func spawnObstacle() {
        let randomImageIndex = Int.random(in: 1...4)
        let obstacleImageName = "obstacleImage\(randomImageIndex)"
        
        let obstacle = SKSpriteNode(imageNamed: obstacleImageName)
        obstacle.size = CGSize(width: 60, height: 60)
        
        let randomX = CGFloat.random(in: frame.minX + obstacle.size.width / 2...frame.maxX - obstacle.size.width / 2)
        obstacle.position = CGPoint(x: randomX, y: frame.maxY + obstacle.size.height)
        
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.isDynamic = true
        obstacle.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        obstacle.physicsBody?.contactTestBitMask = PhysicsCategory.player | PhysicsCategory.line
        obstacle.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        addChild(obstacle)
        
        let moveDown = SKAction.moveTo(y: frame.minY - obstacle.size.height, duration: 4.0)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveDown, remove])
        obstacle.run(sequence)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let startPoint = touch.location(in: self)
        linePath = CGMutablePath()
        linePath.move(to: startPoint) // 设置起点
        
        currentLine?.removeFromParent() // 清除当前线条节点
        currentLine = SKShapeNode(path: linePath)
        currentLine?.strokeColor = .blue
        currentLine?.lineWidth = 5
        currentLine?.zPosition = 1
        addChild(currentLine!)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentPoint = touch.location(in: self)
        
        linePath.addLine(to: currentPoint)
        currentLine?.path = linePath
        currentLine?.physicsBody = SKPhysicsBody(edgeChainFrom: linePath)
        currentLine?.physicsBody?.isDynamic = false
        currentLine?.physicsBody?.categoryBitMask = PhysicsCategory.line
        currentLine?.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle
        currentLine?.physicsBody?.collisionBitMask = PhysicsCategory.none
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentLine?.physicsBody = SKPhysicsBody(edgeChainFrom: linePath)
        currentLine?.physicsBody?.isDynamic = false
        currentLine?.physicsBody?.categoryBitMask = PhysicsCategory.line
        currentLine?.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle
        currentLine?.physicsBody?.collisionBitMask = PhysicsCategory.none
    }
    
    // MARK: - Collision Detection
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB

        let obstacle = (bodyA.categoryBitMask == PhysicsCategory.obstacle) ? bodyA.node as? SKSpriteNode : bodyB.node as? SKSpriteNode
        let isLineCollision = (bodyA.categoryBitMask == PhysicsCategory.line || bodyB.categoryBitMask == PhysicsCategory.line)
        
        if isLineCollision, let obstacle = obstacle {
            obstacle.physicsBody?.velocity = .zero
            obstacle.removeAllActions()
            obstacle.removeFromParent()
            
            removedObstaclesCount += 1
            checkWinCondition()
        }

        if (bodyA.categoryBitMask | bodyB.categoryBitMask) == (PhysicsCategory.player | PhysicsCategory.obstacle) {
            gameOver()
        }
    }
    
    func checkWinCondition() {
        if removedObstaclesCount >= 5 {
            score += 1
            removedObstaclesCount = 0
            showWinAlert()
        }
    }
    
    // MARK: - Game Over
    func gameOver() {
        removeAllActions()
        removeAllChildren()
        
        self.viewController?.checkPoRecord()
        
        let alert = UIAlertController(title: "Game Over", message: "You lost the game!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Restart", style: .default, handler: { _ in
            self.restartGame()
        }))
        
        if let viewController = self.view?.window?.rootViewController {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Win Alert
    func showWinAlert() {
        let alert = UIAlertController(title: "You Win!", message: "You successfully blocked 5 obstacles!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Next Round", style: .default, handler: { _ in
            self.startNextRound()
        }))
        if let view = self.view?.window?.rootViewController {
            view.present(alert, animated: true, completion: nil)
        }
    }
    
    func restartGame() {
        score = 0
        removedObstaclesCount = 0
        removeAllChildren()
        setupScene()
        setupPlayer()
        setupScoreLabel()
        startSpawningObstacles()
    }
    
    func startNextRound() {
        removedObstaclesCount = 0
        currentLine?.removeFromParent()
        startSpawningObstacles()
    }
}
