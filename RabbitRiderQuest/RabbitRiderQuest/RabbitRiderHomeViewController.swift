//
//  HomeVC.swift
//  RabbitRiderQuest
//
//  Created by jin fu on 2024/12/29.
//


import UIKit

class RabbitRiderHomeViewController: UIViewController {

    //MARK: - Declare IBOutlets
    
    @IBOutlet weak var imglogo: UIImageView!
    
    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        animateLogo()
    }
    
    //MARK: - Functions
    
    func animateLogo() {
        imglogo.transform = CGAffineTransform(scaleX: 0.5, y: 0.5) // Start smaller
        UIView.animate(withDuration: 1.0, // Animation duration
                       delay: 0.0, // No delay
                       usingSpringWithDamping: 0.5, // Bounce effect
                       initialSpringVelocity: 0.5, // Initial velocity of bounce
                       options: .curveEaseInOut, // Smooth animation
                       animations: {
            self.imglogo.transform = CGAffineTransform.identity // Return to original size
        }, completion: { _ in
            // Reverse the animation for a continuous effect
            UIView.animate(withDuration: 1.0,
                           delay: 0.0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.5,
                           options: .curveEaseInOut,
                           animations: {
                self.imglogo.transform = CGAffineTransform(scaleX: 0.5, y: 0.5) // Scale down again
            }, completion: { _ in
                // Recursively call animateLogo to loop the animation
                self.animateLogo()
            })
        })
    }
    
    //MARK: - Declare IBAction
}