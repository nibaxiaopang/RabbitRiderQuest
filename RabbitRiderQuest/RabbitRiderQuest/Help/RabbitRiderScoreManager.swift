//
//  Singleton.swift
//  RabbitRiderQuest
//
//  Created by jin fu on 2024/12/29.
//


import Foundation

class RabbitRiderScoreManager {
    static let shared = RabbitRiderScoreManager()
    
    var highwaySurvivalScore = UserDefaults.standard.integer(forKey: "highwaySurvivalScore") {
        didSet {
            UserDefaults.standard.set(highwaySurvivalScore, forKey: "highwaySurvivalScore")
        }
    }
    
    var drawToWinScore = UserDefaults.standard.integer(forKey: "drawToWinScore") {
        didSet {
            UserDefaults.standard.set(drawToWinScore, forKey: "drawToWinScore")
        }
    }
    
    var barrierBlitzScore = UserDefaults.standard.integer(forKey: "barrierBlitzScore") {
        didSet {
            UserDefaults.standard.set(barrierBlitzScore, forKey: "barrierBlitzScore")
        }
    }
    
    private init() {
        print("Singleton initialized")
        UserDefaults.standard.register(defaults: ["highwaySurvivalScore": 0])
        UserDefaults.standard.register(defaults: ["drawToWinScore": 0])
        UserDefaults.standard.register(defaults: ["barrierBlitzScore": 0])
    }
    
    func config_highwaySurvivalScore(score: Int) -> Bool {
        if score > highwaySurvivalScore {
            highwaySurvivalScore = score
            return true
        }
        return false
    }
    
    func config_drawToWinScore(score: Int) -> Bool {
        if score > drawToWinScore {
            drawToWinScore = score
            return true
        }
        return false
    }
    
    func config_barrierBlitzScore(score: Int) -> Bool {
        if score > barrierBlitzScore {
            barrierBlitzScore = score
            return true
        }
        return false
    }
}
