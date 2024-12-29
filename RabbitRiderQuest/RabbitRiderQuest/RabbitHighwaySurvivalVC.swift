//
//  NewGameVC.swift
//  RabbitRiderQuest
//
//  Created by jin fu on 2024/12/29.
//


import UIKit
import SpriteKit
import CoreMotion

class RabbitHighwaySurvivalVC: UIViewController, SKPhysicsContactDelegate, RabbitRiderScoreProcol {
    
    @IBOutlet weak var skView: SKView!

    var score = 0 {
        didSet {
            // You can add functionality to update UI elements if necessary
        }
    }
    
    func checkPoRecord() {
        if RabbitRiderScoreManager.shared.config_highwaySurvivalScore(score: score) {
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(scoreDidChange(_:)), name: NSNotification.Name("ScoreDidChange"), object: nil)
        
        // Show "How to Play" alert
        showHowToPlayAlert()
    }
    
    @objc func scoreDidChange(_ notification: Notification) {
        if let newScore = notification.userInfo?["newScore"] as? Int {
            score = newScore
        }
    }
    
    func showHowToPlayAlert() {
        let alert = UIAlertController(title: "How to Play", message: """
        - Use swipe gestures to move the bike left, right, or up.
        - Long press to move the bike down.
        - Avoid obstacles to stay in the game.
        - Your score increases over time—stay alive as long as possible!
        """, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Start Game", style: .default, handler: { _ in
            self.addGameScene()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func addGameScene() {
        let scene = RabbitHighwaySurvivalGameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        skView.presentScene(scene)
        skView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
    }
}


