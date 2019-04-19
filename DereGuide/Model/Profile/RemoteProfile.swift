//
//  RemoteProfile.swift
//  DereGuide
//
//  Created by zzk on 2017/8/2.
//  Copyright © 2017 zzk. All rights reserved.
//

import Foundation
import CloudKit

struct RemoteProfile: RemoteRecord {
    
    var gameID: String
    var nickName: String
    var cuteCardID: Int64
    var coolCardID: Int64
    var passionCardID: Int64
    var cuteVocalLevel: Int64
    var allTypeCardID: Int64
    var guestAllTypeCardID: Int64
    var guestPassionCardID: Int64
    var guestCoolCardID: Int64
    var guestCuteCardID: Int64
    var passionVisualLevel: Int64
    var passionDanceLevel: Int64
    var passionVocalLevel: Int64
    var passionLifeLevel: Int64
    var passionSkillPotentialLevel: Int64
    var coolDanceLevel: Int64
    var coolVocalLevel: Int64
    var coolLifeLevel: Int64
    var coolSkillPotentialLevel: Int64
    var cuteLifeLevel: Int64
    var cuteVisualLevel: Int64
    var cuteDanceLevel: Int64
    var cuteSkillPotentialLevel: Int64
    var allTypeVisualLevel: Int64
    var allTypeDanceLevel: Int64
    var allTypeVocalLevel: Int64
    var allTypeLifeLevel: Int64
    var allTypeSkillPotentialLevel: Int64
    var message: String
    var id: RemoteIdentifier
    var creatorID: RemoteIdentifier
    var coolVisualLevel: Int64
    
    var guestCuteMinLevel: Int64
    var guestCoolMinLevel: Int64
    var guestPassionMinLevel: Int64
    var guestAllTypeMinLevel: Int64
    var isOpen: Int64
    
    var remoteModifiedAt: Date?
    
    var leaderCardID: Int64
    
    var freeCharaID1: Int64
    var freeCharaID2: Int64
    var freeCharaID3: Int64
    var freeCharaID4: Int64
    var freeCharaID5: Int64

}

extension RemoteProfile {
    
    static var recordType: String {
        return "Profile"
    }
    
    init?(record: CKRecord) {
        guard record.recordType == RemoteProfile.recordType else { return nil }
        guard
        let gameID = record["gameID"] as? NSString,
        let nickName = record["nickName"] as? NSString,
        let cuteCardID = record["cuteCardID"] as? NSNumber,
        let coolCardID = record["coolCardID"] as? NSNumber,
        let passionCardID = record["passionCardID"] as? NSNumber,
        let cuteVocalLevel = record["cuteVocalLevel"] as? NSNumber,
        let allTypeCardID = record["allTypeCardID"] as? NSNumber,
        let guestAllTypeCardID = record["guestAllTypeCardID"] as? NSNumber,
        let guestPassionCardID = record["guestPassionCardID"] as? NSNumber,
        let guestCoolCardID = record["guestCoolCardID"] as? NSNumber,
        let guestCuteCardID = record["guestCuteCardID"] as? NSNumber,
        let passionVisualLevel = record["passionVisualLevel"] as? NSNumber,
        let passionDanceLevel = record["passionDanceLevel"] as? NSNumber,
        let passionVocalLevel = record["passionVocalLevel"] as? NSNumber,
        let coolDanceLevel = record["coolDanceLevel"] as? NSNumber,
        let coolVocalLevel = record["coolVocalLevel"] as? NSNumber,
        let cuteVisualLevel = record["cuteVisualLevel"] as? NSNumber,
        let cuteDanceLevel = record["cuteDanceLevel"] as? NSNumber,
        let allTypeVisualLevel = record["allTypeVisualLevel"] as? NSNumber,
        let allTypeDanceLevel = record["allTypeDanceLevel"] as? NSNumber,
        let allTypeVocalLevel = record["allTypeVocalLevel"] as? NSNumber,
        let message = record["message"] as? NSString,
        let creatorID = record.creatorUserRecordID?.recordName,
        let coolVisualLevel = record["coolVisualLevel"] as? NSNumber,
        
        let guestCuteMinLevel = record["guestCuteMinLevel"] as? NSNumber,
        let guestCoolMinLevel = record["guestCoolMinLevel"] as? NSNumber,
        let guestPassionMinLevel = record["guestPassionMinLevel"] as? NSNumber,
        let guestAllTypeMinLevel = record["guestAllTypeMinLevel"] as? NSNumber,
        let leaderCardID = record["leaderCardID"] as? NSNumber,
        let isOpen = record["isOpen"] as? NSNumber else { return nil }
        
        self.id = record.recordID.recordName
        self.creatorID = creatorID
        self.remoteModifiedAt = record.modificationDate
        
        self.gameID = gameID as String
        self.nickName = nickName as String
        self.cuteCardID = cuteCardID.int64Value
        self.coolCardID = coolCardID.int64Value
        self.passionCardID = passionCardID.int64Value
        self.cuteVocalLevel = cuteVocalLevel.int64Value
        self.allTypeCardID = allTypeCardID.int64Value
        self.guestAllTypeCardID = guestAllTypeCardID.int64Value
        self.guestPassionCardID = guestPassionCardID.int64Value
        self.guestCoolCardID = guestCoolCardID.int64Value
        self.guestCuteCardID = guestCuteCardID.int64Value
        self.passionVisualLevel = passionVisualLevel.int64Value
        self.passionDanceLevel = passionDanceLevel.int64Value
        self.passionVocalLevel = passionVocalLevel.int64Value
        self.coolDanceLevel = coolDanceLevel.int64Value
        self.coolVocalLevel = coolVocalLevel.int64Value
        self.cuteVisualLevel = cuteVisualLevel.int64Value
        self.cuteDanceLevel = cuteDanceLevel.int64Value
        self.allTypeVisualLevel = allTypeVisualLevel.int64Value
        self.allTypeDanceLevel = allTypeDanceLevel.int64Value
        self.allTypeVocalLevel = allTypeVocalLevel.int64Value
        self.message = message as String
        self.coolVisualLevel = coolVisualLevel.int64Value
        self.allTypeLifeLevel = (record["allTypeLifeLevel"] as? NSNumber)?.int64Value ?? 0
        self.cuteLifeLevel = (record["cuteLifeLevel"] as? NSNumber)?.int64Value ?? 0
        self.coolLifeLevel = (record["coolLifeLevel"] as? NSNumber)?.int64Value ?? 0
        self.passionLifeLevel = (record["passionLifeLevel"] as? NSNumber)?.int64Value ?? 0
        
        self.allTypeSkillPotentialLevel = (record["allTypeSkillPotentialLevel"] as? NSNumber)?.int64Value ?? 0
        self.cuteSkillPotentialLevel = (record["cuteSkillPotentialLevel"] as? NSNumber)?.int64Value ?? 0
        self.coolSkillPotentialLevel = (record["coolSkillPotentialLevel"] as? NSNumber)?.int64Value ?? 0
        self.passionSkillPotentialLevel = (record["passionSkillPotentialLevel"] as? NSNumber)?.int64Value ?? 0
        
        self.guestCuteMinLevel = guestCuteMinLevel.int64Value
        self.guestCoolMinLevel = guestCoolMinLevel.int64Value
        self.guestPassionMinLevel = guestPassionMinLevel.int64Value
        self.guestAllTypeMinLevel = guestAllTypeMinLevel.int64Value
        self.leaderCardID = leaderCardID.int64Value
        self.isOpen = isOpen.int64Value
        
        self.freeCharaID1 = (record["freeCharaID1"] as? NSNumber)?.int64Value ?? 0
        self.freeCharaID2 = (record["freeCharaID2"] as? NSNumber)?.int64Value ?? 0
        self.freeCharaID3 = (record["freeCharaID3"] as? NSNumber)?.int64Value ?? 0
        self.freeCharaID4 = (record["freeCharaID4"] as? NSNumber)?.int64Value ?? 0
        self.freeCharaID5 = (record["freeCharaID5"] as? NSNumber)?.int64Value ?? 0
    }
    
}
