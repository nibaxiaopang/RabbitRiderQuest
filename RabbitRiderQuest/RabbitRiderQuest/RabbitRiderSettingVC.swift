//
//  SettingVC.swift
//  RabbitRiderQuest
//
//  Created by jin fu on 2024/12/29.
//


import UIKit

class RabbitRiderSettingVC: UIViewController {

    //MARK: - Declare IBOutlets
    
    @IBOutlet weak var btnaboutus             : UIButton!
    @IBOutlet weak var btnprivacypolicy       : UIButton!
    @IBOutlet weak var btnfeedback            : UIButton!
    @IBOutlet weak var btnshare               : UIButton!
    
    //MARK: - Declare Variables
    
    
    
    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnaboutus.cornerRadius = self.btnaboutus.bounds.height / 2
        btnprivacypolicy.cornerRadius = self.btnprivacypolicy.bounds.height / 2
        btnfeedback.cornerRadius = self.btnfeedback.bounds.height / 2
        btnshare.cornerRadius = self.btnshare.bounds.height / 2
        
    }
    
    //MARK: - Functions
    
    
    
    //MARK: - Declare IBAction
    @IBAction func btnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnShareApp(_ sender: Any) {
        let textToShare = "Check out Rabbit Rider Quest app!"
        
        let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop]
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
    
}
