//
//  LiveSimulationAdvanceOptionsManager.swift
//  DereGuide
//
//  Created by zzk on 2017/6/3.
//  Copyright © 2017 zzk. All rights reserved.
//

import Foundation

class LiveSimulationAdvanceOptionsManager {

    static let `default` = LiveSimulationAdvanceOptionsManager()
    
    private init() {
        
    }
    
    var roomUpValue: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: "roomUpValue")
        }
        get {
            return UserDefaults.standard.object(forKey: "roomUpValue") as? Int ?? 10
        }
    }
    
    var greatPercent: Double {
        set {
            UserDefaults.standard.set(newValue, forKey: "greatPercent")
        }
        get {
            return UserDefaults.standard.double(forKey: "greatPercent")
        }
    }
    
    var simulationTimes: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: "simulationTimes")
        }
        get {
            return UserDefaults.standard.object(forKey: "simulationTimes") as? Int ?? 10000
        }
    }
    
    var startGrooveWithDoubleHP: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "startGrooveWithDoubleHP")
        }
        get {
            return UserDefaults.standard.object(forKey: "startGrooveWithDoubleHP") as? Bool ?? true
        }
    }
    
    var afkModeStartSeconds: Float {
        set {
            UserDefaults.standard.set(newValue, forKey: "afkModeStartSeconds")
        }
        get {
            return UserDefaults.standard.object(forKey: "afkModeStartSeconds") as? Float ?? 0
        }
    }
    
    var afkModeStartCombo: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: "afkModeStartCombo")
        }
        get {
            return UserDefaults.standard.object(forKey: "afkModeStartCombo") as? Int ?? 0
        }
    }
    
    var afkModeSimulationTimes: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: "afkModeSimuationTimes")
        }
        get {
            return UserDefaults.standard.object(forKey: "afkModeSimuationTimes") as? Int ?? 1000
        }
    }
    
    func reset() {
//        considerOverloadSkillsTriggerLifeCondition = false
        greatPercent = 0.0
        simulationTimes = 10000
        roomUpValue = 10
        afkModeStartSeconds = 0.0
        afkModeStartCombo = 0
        afkModeSimulationTimes = 1000
    }

}
