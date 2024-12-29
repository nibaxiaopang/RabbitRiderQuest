//
//  ThirdGameVC.swift
//  RabbitRiderQuest
//
//  Created by RabbitRiderQuest on 2024/12/29.
//


import UIKit
import SpriteKit
import GameplayKit

class RabbitBarrierBlitzGameVC: UIViewController, SKPhysicsContactDelegate, RabbitRiderScoreProcol {
    
    @IBOutlet weak var skView: SKView!
    
    var score = 0 {
        didSet {
            // Update any UI elements if needed
        }
    }
    
    func checkPoRecord() {
        if RabbitRiderScoreManager.shared.config_barrierBlitzScore(score: score) {
            let alert = UIAlertController(
                        title: "Congratulations!",
                        message: "You've broken the record and achieved the highest score:\(score)!",
                        preferredStyle: .alert
                    )
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = RabbitBarrierBlitzGameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        skView.presentScene(scene)
        skView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(scoreDidChange(_:)), name: NSNotification.Name("BarrierBlitzScoreDidChange"), object: nil)
        
        // Show "How to Play" alert
        showHowToPlayAlert(scene: scene)
    }
    
    @objc func scoreDidChange(_ notification: Notification) {
        if let newScore = notification.userInfo?["newScore"] as? Int {
            score = newScore
        }
    }
    
    func showHowToPlayAlert(scene: RabbitBarrierBlitzGameScene) {
        let alert = UIAlertController(
            title: "How to Play",
            message: """
            - Draw a line to block falling obstacles.
            - Touch and drag to create the line.
            - Block 5 obstacles to win the round.
            - Avoid letting obstacles hit the player.
            - Keep the player safe to keep scoring!
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Start Game", style: .default, handler: { _ in
            scene.isPaused = false // Resume the game when the button is pressed
        }))
        
        present(alert, animated: true, completion: {
            scene.isPaused = true // Pause the game while the alert is displayed
        })
    }
}


