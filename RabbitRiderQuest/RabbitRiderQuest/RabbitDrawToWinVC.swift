//
//  SecondGameVC.swift
//  RabbitRiderQuest
//
//  Created by jin fu on 2024/12/29.
//


import SpriteKit
import UIKit
import Foundation

class RabbitDrawToWinVC: UIViewController, SKPhysicsContactDelegate {
    
    @IBOutlet weak var skView: SKView!
    
    var score = 0 {
        didSet {
            // You can also update a UI element here, if necessary
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Present the game scene
        let scene = RabbitDrawToWinGameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        scene.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        skView.presentScene(scene)
        skView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        // Observe score changes
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
        - Start by drawing a path from the START point to the FINISH point.
        - Avoid crossing outside the red drawable area.
        - Collect stars to earn bonus points.
        - Avoid hazard zones (red squares) to prevent slowing down.
        - Complete as many paths as possible before the timer runs out!
        """, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Got It!", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}

