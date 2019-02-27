//
//  DataVersionPayload.swift
//  DereGuide
//
//  Created by zzk on 01/03/2018.
//  Copyright © 2018 zzk. All rights reserved.
//

import UIKit

enum PatchType: String, Codable {
    case card
    case skill
    case leaderSkill
    case chara
    case beatmap
}

struct PatchItem: Codable {
    var type: PatchType
    var id: String
}

struct DataVersionPayload: Codable {

    /// version number in string eg. "1.0.0"
    var version: String
    
    /// { "ja" : "reason in Japanese" , "zh-Hans" : "reason in simplified Chinese" }
    var reasons: [String: String]
    
    /// patch items, used in silent updating, should be removed every minor reversion.
    var items: [PatchItem]
    
    var userID: String?
    
    var viewerID: String?
    
    var udid: String?
    
}

extension DataVersionPayload {
    
    var localizedReason: String? {
        if let identifier = Locale.preferredLanguages.first {
            return reasons.filter { identifier.hasPrefix($0.key) }.max { $0.key.count < $1.key.count }?.value ?? reasons["default"]
        }
        return reasons["default"]
    }
}
