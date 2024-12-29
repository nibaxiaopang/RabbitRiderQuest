//
//  GameScene2.swift
//  RabbitRiderQuest
//
//  Created by jin fu on 2024/12/29.
//

import SpriteKit
import UIKit
import Foundation

//MARK: - GameScene2

class RabbitDrawToWinGameScene: SKScene {
    
    // MARK: - Properties
    let startPoint = SKSpriteNode(imageNamed: "ic_start")
    let finishPoint = SKSpriteNode(imageNamed: "ic_finish")
    let bike = SKSpriteNode(imageNamed: "ic_cycle")
    let background = SKSpriteNode(imageNamed: "ic_gamebg2")
    var scoreLabel: SKLabelNode!
    var timerLabel: SKLabelNode!
    var timer: Int = 10 {
        didSet {
            timerLabel.text = "Time: \(timer)s"
        }
    }
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var drawnPath = UIBezierPath()
    var pathNode: SKShapeNode?
    var isDrawingStartedAtStartPoint = false
    var hazardZone: SKSpriteNode?
    var drawableArea: SKShapeNode?
    var collectible: SKSpriteNode?

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        setupGameElements()
        setupScoreLabel()
        setupTimerLabel()
        startTimer()
        spawnCollectibles()
        spawnHazardZones()
    }

    // MARK: - Setup
    func setupGameElements() {
        backgroundColor = .clear

        // Setup Background
        background.size = self.size
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = -1
        addChild(background)

        // Setup Start Point
        startPoint.size = CGSize(width: 80, height: 80)
        startPoint.position = CGPoint(
            x: CGFloat.random(in: size.width * 0.1...size.width * 0.4),
            y: CGFloat.random(in: size.height * 0.3...size.height * 0.7)
        )
        addChild(startPoint)

        // Setup Finish Point
        finishPoint.size = CGSize(width: 70, height: 70)
        finishPoint.position = CGPoint(
            x: CGFloat.random(in: size.width * 0.6...size.width * 0.9),
            y: CGFloat.random(in: size.height * 0.3...size.height * 0.7)
        )
        addChild(finishPoint)

        // Setup Bike
        bike.size = CGSize(width: 70, height: 50)
        bike.anchorPoint = CGPoint(x: 0.5, y: 0)
        bike.position = startPoint.position
        addChild(bike)

        // Setup Drawable Area
        drawableArea = SKShapeNode(rect: CGRect(x: size.width * 0.1, y: size.height * 0.1, width: size.width * 0.8, height: size.height * 0.8))
        drawableArea?.strokeColor = .red
        drawableArea?.lineWidth = 1
        addChild(drawableArea!)
    }

    func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 120)
        scoreLabel.zPosition = 10
        scoreLabel.text = "Score: \(score)"
        addChild(scoreLabel)
    }

    func setupTimerLabel() {
        timerLabel = SKLabelNode(fontNamed: "Chalkduster")
        timerLabel.fontSize = 24
        timerLabel.fontColor = .black
        timerLabel.position = CGPoint(x: frame.midX, y: frame.minY + 140)
        timerLabel.zPosition = 10
        timerLabel.text = "Time: \(timer)s"
        addChild(timerLabel)
    }

    // MARK: - Timer
    func startTimer() {
        let wait = SKAction.wait(forDuration: 1.0)
        let countdown = SKAction.run { [weak self] in
            self?.timer -= 1
            self?.shrinkDrawableArea()
            if self?.timer == 0 {
                self?.endGame()
            }
        }
        run(SKAction.repeatForever(SKAction.sequence([wait, countdown])), withKey: "timer")
    }

    // MARK: - Collectibles
    func spawnCollectibles() {
        let wait = SKAction.wait(forDuration: 3.0)
        let spawn = SKAction.run { [weak self] in
            self?.createCollectible()
        }
        run(SKAction.repeatForever(SKAction.sequence([wait, spawn])), withKey: "collectibles")
    }

    func createCollectible() {
        collectible?.removeFromParent()
        collectible = SKSpriteNode(imageNamed: "powerUpImage")
        collectible?.size = CGSize(width: 40, height: 40)
        collectible?.position = CGPoint(
            x: CGFloat.random(in: size.width * 0.1...size.width * 0.9),
            y: CGFloat.random(in: size.height * 0.1...size.height * 0.9)
        )
        collectible?.zPosition = 2
        addChild(collectible!)
    }

    func spawnHazardZones() {
        let wait = SKAction.wait(forDuration: 5.0)
        let spawn = SKAction.run { [weak self] in
            self?.createHazardZone()
        }
        run(SKAction.repeatForever(SKAction.sequence([wait, spawn])), withKey: "hazards")
    }

    func createHazardZone() {
        hazardZone?.removeFromParent()
        hazardZone = SKSpriteNode(color: .red, size: CGSize(width: 100, height: 100))
        hazardZone?.alpha = 0.5
        hazardZone?.position = CGPoint(
            x: CGFloat.random(in: size.width * 0.2...size.width * 0.8),
            y: CGFloat.random(in: size.height * 0.2...size.height * 0.8)
        )
        hazardZone?.zPosition = 1
        addChild(hazardZone!)
    }

    // MARK: - Drawing Path
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let startPosition = touch.location(in: self)

        if startPoint.frame.contains(startPosition) {
            isDrawingStartedAtStartPoint = true
            drawnPath = UIBezierPath()
            drawnPath.move(to: startPosition)
            pathNode?.removeFromParent()
            pathNode = nil
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, isDrawingStartedAtStartPoint else { return }
        let currentPosition = touch.location(in: self)

        if drawableArea?.contains(currentPosition) == true {
            drawnPath.addLine(to: currentPosition)
            pathNode?.removeFromParent()
            pathNode = SKShapeNode(path: drawnPath.cgPath)
            pathNode?.strokeColor = .blue
            pathNode?.lineWidth = 3
            addChild(pathNode!)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, isDrawingStartedAtStartPoint else { return }
        let endPosition = touch.location(in: self)

        if finishPoint.frame.contains(endPosition) {
            moveBikeAlongPath()
        } else {
            endGame()
        }

        isDrawingStartedAtStartPoint = false
    }

    // MARK: - Bike Movement
    func moveBikeAlongPath() {
        guard let path = pathNode?.path else { return }
        let followPath = SKAction.follow(path, asOffset: false, orientToPath: false, duration: Double(drawnPath.cgPath.boundingBox.height / 100))
        let sequence = SKAction.sequence([followPath, SKAction.run { [weak self] in self?.checkWinCondition() }])
        bike.run(sequence)
    }

    func checkWinCondition() {
        if bike.frame.intersects(finishPoint.frame) {
            score += 10
            resetGame()
        }
    }

    // MARK: - End Game
    func endGame() {
        removeAllActions()
        removeAllChildren()

        let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 40
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(gameOverLabel)
    }

    func resetGame() {
        bike.position = startPoint.position
        startPoint.position = CGPoint(
            x: CGFloat.random(in: size.width * 0.1...size.width * 0.4),
            y: CGFloat.random(in: size.height * 0.3...size.height * 0.7)
        )
        finishPoint.position = CGPoint(
            x: CGFloat.random(in: size.width * 0.6...size.width * 0.9),
            y: CGFloat.random(in: size.height * 0.3...size.height * 0.7)
        )
        pathNode?.removeFromParent()
        pathNode = nil
        drawnPath = UIBezierPath()
    }

    func shrinkDrawableArea() {
        let newFrame = CGRect(
            x: drawableArea!.frame.origin.x + 5,
            y: drawableArea!.frame.origin.y + 5,
            width: drawableArea!.frame.size.width - 10,
            height: drawableArea!.frame.size.height - 10
        )
        drawableArea?.removeFromParent()
        drawableArea = SKShapeNode(rect: newFrame)
        drawableArea?.strokeColor = .red
        drawableArea?.lineWidth = 2
        addChild(drawableArea!)
    }
}
