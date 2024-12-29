//
//  Utils.swift
//  RabbitRiderQuest
//
//  Created by jin fu on 2024/12/29.
//

import UIKit
import SpriteKit

class RabbitRiderUtils {
    static func showAlert(title: String, message: String, from viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}

protocol RabbitRiderScoreProcol {
    func checkPoRecord()
}

extension SKScene {
    // 扩展 SKScene 添加一个计算属性
    var viewController: RabbitRiderScoreProcol? {
        var responder: UIResponder? = self.view
        
        // 不断沿着响应链向上查找
        while responder != nil {
            if let vc = responder as? UIViewController{
                return vc as? RabbitRiderScoreProcol
            }
            responder = responder?.next
        }
        return nil
    }
}
