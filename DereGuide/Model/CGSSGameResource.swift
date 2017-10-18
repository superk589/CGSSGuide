//
//  CGSSGameResource.swift
//  DereGuide
//
//  Created by zzk on 2016/9/13.
//  Copyright © 2016年 zzk. All rights reserved.
//

import UIKit
import FMDB
import SwiftyJSON

typealias FMDBCallBackClosure<T> = (T) -> Void
typealias FMDBWrapperClosure = (FMDatabase) throws -> Void

extension FMDatabaseQueue {
    func execute(_ task: @escaping FMDBWrapperClosure, completion:
        (() -> Void)? = nil) {
        inDatabase { (db) in
            defer {
                db.close()
            }
            do {
                if db.open(withFlags: SQLITE_OPEN_READONLY) {
                    try task(db)
                }
            } catch {
                print(db.lastErrorMessage())
            }
            completion?()
        }
    }
}

class MusicScoreDBQueue: FMDatabaseQueue {
    
    func getBeatmaps(callback: @escaping FMDBCallBackClosure<[CGSSBeatmap]>) {
        var beatmaps = [CGSSBeatmap]()
        execute({ (db) in
            let selectSql = "select * from blobs order by name asc"
            let set = try db.executeQuery(selectSql, values: nil)
            while set.next() {
                if let data = set.data(forColumn: "data"),
                    let name = set.string(forColumn: "name"),
                    let number = name.match(pattern: "_([0-9]+).csv", index: 1).first,
                    let rawDifficulty = Int(number),
                    let beatmap = CGSSBeatmap.init(data: data, rawDifficulty: rawDifficulty) {
                    beatmaps.append(beatmap)
                }
            }
        }) {
            callback(beatmaps)
        }
    }
    
    func getBeatmapCount(callback: @escaping FMDBCallBackClosure<Int>) {
        var result = 0
        execute({ (db) in
            let selectSql = "select * from blobs order by name asc"
            let set = try db.executeQuery(selectSql, values: nil)
            while set.next() {
                if let name = set.string(forColumn: "name"),
                    let _ = name.match(pattern: "_([0-9]+).csv", index: 1).first {
                    result += 1
                }
            }
        }) {
            callback(result)
        }
    }
    
    func validateBeatmapCount(_ beatmapCount: Int, callback: @escaping FMDBCallBackClosure<Bool>) {
        getBeatmapCount { (count) in
            callback(beatmapCount == count)
        }
    }
    
}

class Master: FMDatabaseQueue {
    
    func getEventAvailableList(callback: @escaping FMDBCallBackClosure<[Int]>) {
        var list = [Int]()
        execute({ (db) in
            let selectSql = "select reward_id from event_available"
            let set = try db.executeQuery(selectSql, values: nil)
            while set.next() {
                let rewardId = set.int(forColumnIndex: 0)
                list.append(Int(rewardId))
            }
            
            // snow wings 两张活动卡数据库中遗失 做特殊处理
            list.append(200129)
            list.append(300135)
        }) {
            callback(list)
        }
    }
    
    func getGachaAvailableList(callback: @escaping FMDBCallBackClosure<[Int]>) {
        var list = [Int]()
        
        execute({ (db) in
            let selectSql = "select reward_id from gacha_data a, gacha_available b where a.id = b.gacha_id and a.dicription not like '%限定%'"
            let set = try db.executeQuery(selectSql, values: nil)
            while set.next() {
                let rewardId = set.int(forColumnIndex: 0)
                list.append(Int(rewardId))
            }
        }) {
            callback(list)
        }
    }
    
    func getTimeLimitAvailableList(callback: @escaping FMDBCallBackClosure<[Int]>) {
        var list = [Int]()
        execute({ (db) in
            let selectSql = "select reward_id from gacha_data a, gacha_available b where a.id = b.gacha_id and a.dicription like '%期間限定%' and recommend_order > 0"
            let set = try db.executeQuery(selectSql, values: nil)
            while set.next() {
                let rewardId = set.int(forColumnIndex: 0)
                list.append(Int(rewardId))
            }
        }) {
            callback(list)
        }
    }
    
    func getFesAvailableList(callback: @escaping FMDBCallBackClosure<[Int]>) {
        var list = [Int]()
        execute({ (db) in
            let selectSql = "select reward_id from gacha_data a, gacha_available b where a.id = b.gacha_id and a.dicription like '%フェス限定%' and recommend_order > 0"
            let set = try db.executeQuery(selectSql, values: nil)
            while set.next() {
                let rewardId = set.int(forColumnIndex: 0)
                list.append(Int(rewardId))
            }
        }) {
            callback(list)
        }
    }
    
    func getValidGacha(callback: @escaping FMDBCallBackClosure<[CGSSGachaPool]>) {
        var list = [CGSSGachaPool]()
        execute({ (db) in
            let selectSql = "select a.id, a.name, a.dicription, a.start_date, a.end_date, b.rare_ratio, b.sr_ratio, b.ssr_ratio from gacha_data a, gacha_rate b where a.id = b.id and a.id like '3%' order by end_date DESC"
            let set = try db.executeQuery(selectSql, values: nil)
            while set.next() {
                let endDate = set.string(forColumn: "end_date")
                let id = Int(set.int(forColumn: "id"))
                let name = set.string(forColumn: "name")
                let dicription = set.string(forColumn: "dicription")
                let startDate = set.string(forColumn: "start_date")
                
                let rareRatio = Int(set.int(forColumn: "rare_ratio"))
                let srRatio = Int(set.int(forColumn: "sr_ratio"))
                let ssrRatio = Int(set.int(forColumn: "ssr_ratio"))
                
                let rewardSql = "select * from gacha_available where gacha_id = \(id)"
                var rewards = [Reward]()
                let subSet = try db.executeQuery(rewardSql, values: nil)
                while subSet.next() {
                    let rewardId = Int(subSet.int(forColumn: "reward_id"))
                    let recommendOrder = Int(subSet.int(forColumn: "recommend_order"))
                    let relativeOdds = Int(subSet.int(forColumn: "relative_odds"))
                    let relativeSROdds = Int(subSet.int(forColumn: "relative_sr_odds"))
                    rewards.append(Reward(cardId: rewardId, recommandOrder: recommendOrder, relativeOdds: relativeOdds, relativeSROdds: relativeSROdds))
                }
                
                let gachaPool = CGSSGachaPool.init(id: id, name: name!, dicription: dicription!, start_date: startDate!, end_date: endDate!, rare_ratio: rareRatio, sr_ratio: srRatio, ssr_ratio: ssrRatio, rewards: rewards)
                list.append(gachaPool)
            }
        }) {
            callback(list)
        }
    }
    
    func getChara(charaId: Int? = nil, callback: @escaping FMDBCallBackClosure<[CGSSChar]>) {
        var result = [CGSSChar]()
        execute({ (db) in
            let selectSql = "select * from chara_data\(charaId == nil ? "" : " where chara_id = \(charaId!)")"
            let set = try db.executeQuery(selectSql, values: nil)
            while set.next() {
                if let data = try? JSONSerialization.data(withJSONObject: set.resultDictionary ?? [], options: []) {
                    let chara = CGSSChar.init(fromJson: JSON.init(data: data))
                    result.append(chara)
                }
            }
        }) {
            callback(result)
        }
    }
    
    func selectTextBy(category: Int, index: Int, callback: @escaping FMDBCallBackClosure<String>) {
        var result = ""
        execute({ (db) in
            let selectSql = "select * from text_data where category = \(category) and \"index\" = \(index)"
            let set = try db.executeQuery(selectSql, values: nil)
            if set.next() {
                result = set.string(forColumn: "text") ?? ""
            }
        }) {
            callback(result)
        }
    }
    
    func getEvents(callback: @escaping FMDBCallBackClosure<[CGSSEvent]>) {
        var list = [CGSSEvent]()
        execute({ (db) in
            let selectSql = "select * from event_data order by event_start asc"
            var grooveOrParadeCount = 0
            var count = 0
            let set = try db.executeQuery(selectSql, values: nil)
            while set.next() {
                count += 1
                let sortId = count > 16 ? count + 2 : count + 1
                let id = Int(set.int(forColumn: "id"))
                let type = Int(set.int(forColumn: "type"))
                let name = set.string(forColumn: "name")
                let startDate = set.string(forColumn: "event_start")
                let endDate = set.string(forColumn: "event_end")
                let secondHalfStartDate = set.string(forColumn: "second_half_start")
                
                let rewardSql = "select * from event_available where event_id = \(id)"
                var rewards = [Reward]()
                let subSet = try db.executeQuery(rewardSql, values: nil)
                while subSet.next() {
                    let rewardId = Int(subSet.int(forColumn: "reward_id"))
                    let recommendOrder = Int(subSet.int(forColumn: "recommend_order"))
                    let reward = Reward.init(cardId: rewardId, recommandOrder: recommendOrder, relativeOdds: 0, relativeSROdds: 0)
                    rewards.append(reward)
                }
                
                var liveId: Int = 0
                if type == 5 || type == 3 {
                    grooveOrParadeCount += 1
                    let liveSql = "select * from live_data where sort = \(3000 + grooveOrParadeCount) and event_type > 0"
                    let subSet2 = try db.executeQuery(liveSql, values: nil)
                    while subSet2.next() {
                        liveId = Int(subSet2.int(forColumn: "id"))
                        break
                    }
                } else {
                    // here use event_type > 0 to filter, cuz sort_id may be the same (1024)
                    // another way is to use start_date
                    let liveSql = "select * from live_data where sort = \(id) and event_type > 0"
                    let subSet2 = try db.executeQuery(liveSql, values: nil)
                    while subSet2.next() {
                        liveId = Int(subSet2.int(forColumn: "id"))
                        break
                    }
                }
                let event = CGSSEvent.init(sortId: sortId, id: id, type: type, startDate: startDate!, endDate: endDate!, name: name!, secondHalfStartDate: secondHalfStartDate!, reward: rewards, liveId: liveId)
                
                list.append(event)
            }
        }) {
            callback(list)
        }
    }
    
    func getMusicInfo(musicDataID: Int? = nil, callback: @escaping FMDBCallBackClosure<[CGSSSong]>) {
        var list = [CGSSSong]()
        execute({ (db) in
            let selectSql = """
                SELECT
                    b.id,
                    max( a.id ) live_id,
                    min( a.id ) normal_live_id,
                    max( a.type ) type,
                    max( a.event_type ) event_type,
                    min( a.start_date ) start_date,
                    d.discription,
                    b.bpm,
                    b.name,
                    b.composer,
                    b.lyricist,
                    b.name_sort,
                    c.chara_position_1,
                    c.chara_position_2,
                    c.chara_position_3,
                    c.chara_position_4,
                    c.chara_position_5,
                    c.position_num
                FROM
                    live_data a,
                    music_data b,
                    music_info d
                    LEFT OUTER JOIN live_data_position c ON a.id = c.live_data_id
                WHERE
                    a.music_data_id = b.id
                    AND b.id = d.id
                    \(musicDataID == nil ? "" : "AND a.music_data_id = \(musicDataID!)")
                GROUP BY
                    b.id
            """
            let set = try db.executeQuery(selectSql, values: nil)
            while set.next() {
                
                let json = JSON(set.resultDictionary ?? [AnyHashable: Any]())
                
                guard let song = CGSSSong(fromJson: json) else { continue }
                
                // 去掉一些无效数据
                if song.detail == "？" { continue }
                if [1901, 1902, 90001].contains(song.musicID) { continue }
                // some of the event songs have a start date at the end of the event, so add 30 days 
                if song.startDate > Date().addingTimeInterval(30 * 24 * 3600) && musicDataID == nil { continue }
                list.append(song)
            }
        }) {
            callback(list)
        }
    }
    
    func getMusicInfo(charaID: Int, callback: @escaping FMDBCallBackClosure<[CGSSSong]>) {
        var list = [CGSSSong]()
        execute({ (db) in
            let selectSql = """
                SELECT
                    b.id,
                    max( a.id ) live_id,
                    min( a.id ) normal_live_id,
                    max( a.type ) type,
                    max( a.event_type ) event_type,
                    min( a.start_date ) start_date,
                    d.discription,
                    b.bpm,
                    b.name,
                    b.composer,
                    b.lyricist,
                    b.name_sort,
                    c.chara_position_1,
                    c.chara_position_2,
                    c.chara_position_3,
                    c.chara_position_4,
                    c.chara_position_5,
                    c.position_num
                FROM
                    live_data a,
                    music_data b,
                    music_info d
                    LEFT OUTER JOIN live_data_position c ON a.id = c.live_data_id
                WHERE
                    a.music_data_id = b.id
                    AND b.id = d.id
                    AND (c.chara_position_1 == \(charaID)
                    OR c.chara_position_2 == \(charaID)
                    OR c.chara_position_3 == \(charaID)
                    OR c.chara_position_4 == \(charaID)
                    OR c.chara_position_5 == \(charaID))
                GROUP BY
                    b.id
            """
            let set = try db.executeQuery(selectSql, values: nil)
            while set.next() {
                
                let json = JSON(set.resultDictionary ?? [AnyHashable: Any]())
                
                guard let song = CGSSSong(fromJson: json) else { continue }
                
                // 去掉一些无效数据
                if song.detail == "？" { continue }
                if [1901, 1902, 90001].contains(song.musicID) { continue }
                list.append(song)
            }
        }) {
            callback(list)
        }
    }
    
    func getLiveTrend(eventId: Int, callback: @escaping FMDBCallBackClosure<[EventTrend]>) {
        var list = [EventTrend]()
        execute({ (db) in
            let selectSql = "select * from tour_trend_live where event_id = \(eventId)"
            let set = try db.executeQuery(selectSql, values: nil)
            while set.next() {
                let json = JSON(set.resultDictionary ?? [AnyHashable: Any]())
                let trend = EventTrend.init(fromJson: json)
                list.append(trend)
            }
        }) {
            callback(list)
        }
    }
    
    func getLives(liveId: Int? = nil, callback: @escaping FMDBCallBackClosure<[CGSSLive]>) {
        var list = [CGSSLive]()
        execute({ (db) in
            let selectSql = """
                SELECT
                    a.id,
                    a.event_type,
                    a.music_data_id,
                    a.start_date,
                    a.type,
                    b.bpm,
                    b.name
                FROM
                    live_data a,
                    music_data b
                WHERE
                    a.music_data_id = b.id
                    \(liveId == nil ? "" : "AND a.id = \(liveId!)")
            """
            
            let set = try db.executeQuery(selectSql, values: nil)
            while set.next() {
                let json = JSON(set.resultDictionary ?? [AnyHashable: Any]())
                
                guard let live = CGSSLive(fromJson: json) else { continue }
                
                // not valid if count == 0
                if live.beatmapCount == 0 { continue }
                
                // 去掉一些无效数据
                // 1901 - 2016-4-1 special live
                // 1902 - 2017-4-1 special live
                // 90001 - DJ Pinya live
                if [1901, 1902, 90001].contains(live.musicDataId) { continue }
                
                let selectSql = """
                    SELECT
                        a.id,
                        a.live_data_id,
                        a.difficulty_type,
                        a.level_vocal stars_number,
                        b.notes_number
                    FROM
                        live_detail a
                        LEFT OUTER JOIN live_notes_number b ON a.live_data_id = b.live_id
                        AND b.difficulty = a.difficulty_type
                    WHERE
                        a.live_data_id = \(live.id)
                    ORDER BY
                        a.difficulty_type ASC
                """
                var details = [CGSSLiveDetail]()
                let subSet = try db.executeQuery(selectSql, values: nil)
                
                var count = 0
                while subSet.next() && count < live.beatmapCount {
                    let json = JSON(subSet.resultDictionary ?? [AnyHashable: Any]())
                    
                    guard let detail = CGSSLiveDetail(fromJson: json) else { continue }
                    
                    details.append(detail)
                    count += 1
                }
                
                if details.count > live.beatmapCount {
                    print("aaa")
                }
                
                if details.count == 0 { continue }
                
                live.details = details
                
                if let anotherLive = list.first(where: { $0.musicDataId == live.musicDataId }) {
                    anotherLive.merge(anotherLive: live)
                } else {
                    list.append(live)
                }
            }
        }) {
            callback(list)
        }
    }
    
//    func getLiveDetails(liveID: Int, callback: @escaping FMDBCallBackClosure<[CGSSLiveDetail]>) {
//        var list = [CGSSLiveDetail]()
//        execute({ (db) in
//            let selectSql = """
//                SELECT
//                    a.live_data_id,
//                    a.difficulty_type,
//                    a.level_vocal stars_number,
//                    b.notes_number
//                FROM
//                    live_detail a,
//                    live_notes_number b
//                WHERE
//                    a.live_data_id = \(liveID)
//                    AND b.difficulty = a.difficulty_type
//                    AND b.live_id = a.live_data_id
//            """
//
//            let set = try db.executeQuery(selectSql, values: nil)
//            while set.next() {
//                let json = JSON(set.resultDictionary ?? [AnyHashable: Any]())
//
//                guard let detail = CGSSLiveDetail(fromJson: json) else { continue }
//
//                list.append(detail)
//            }
//        }) {
//            callback(list)
//        }
//    }
    
    func getVocalistsBy(musicDataId: Int, callback: @escaping FMDBCallBackClosure<[Int]>) {
        var list = [Int]()
        execute({ (db) in
            let selectSql = "select chara_id from music_vocalist where a.id = \(musicDataId)"
            let set = try db.executeQuery(selectSql, values: nil)
            while set.next() {
                let vocalist = Int(set.int(forColumn: "chara_id"))
                list.append(vocalist)
            }
        }) {
            callback(list)
        }
    }
    
    func getGuaranteedCardIds(gacha: CGSSGachaPool, callback: @escaping FMDBCallBackClosure<[Int]>) {
        var list = [Int]()
        execute({ (db) in
            let selectSql = "select reward_id from gacha_l_e_list a, gacha_l_group b where a.g_id = b.id and b.start_date <= '\(gacha.startDate)' and b.end_date >= '\(gacha.endDate)'"
            let set = try db.executeQuery(selectSql, values: nil)
            while set.next() {
                let id = Int(set.int(forColumn: "reward_id"))
                list.append(id)
            }
        }) {
            callback(list)
        }
    }
}

class Manifest: FMDatabase {
    
    func selectByName(_ string: String) -> [String] {
        let selectSql = "select * from manifests where name = \"\(string)\""
        var hashTable = [String]()
        do {
            let set = try self.executeQuery(selectSql, values: nil)
            while set.next() {
                hashTable.append(set.string(forColumn: "hash") ?? "")
            }
        } catch {
            print(self.lastErrorMessage())
        }
        
        return hashTable
    }
    
    func getMusicScores() -> [String: String] {
        let selectSql = "select * from manifests where name like \"musicscores_m%.bdb\""
        var hashTable = [String: String]()
        do {
            let set = try self.executeQuery(selectSql, values: nil)
            while set.next() {
                if let name = set.string(forColumn: "name")?.match(pattern: "m([0-9]*)\\.", index: 1).first {
                    let hash = set.string(forColumn: "hash") ?? ""
                    // 去除一些无效数据
                    if ["901", "000"].contains(name) { continue }
                    hashTable[name] = hash
                }
            }
        }
        catch {
            print(self.lastErrorMessage())
        }
        return hashTable
    }
}

class CGSSGameResource: NSObject {
    
    static let shared = CGSSGameResource()
    
    static let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + "/GameResource"
    
    static let masterPath = path + "/master.db"
    
    static let manifestPath = path + "/manifest.db"
    
    lazy var master: Master = {
        let dbQueue = Master.init(path: CGSSGameResource.masterPath)
        return dbQueue
    }()
    
    lazy var manifest: Manifest = {
        let db = Manifest.init(path: CGSSGameResource.manifestPath)
        return db
    }()
    
    fileprivate override init() {
        super.init()
        self.prepareFileDirectory()
        self.prepareGachaList(callback: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateEnd(notification:)), name: .updateEnd, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    func prepareFileDirectory() {
        if !FileManager.default.fileExists(atPath: CGSSGameResource.path) {
            do {
                try FileManager.default.createDirectory(atPath: CGSSGameResource.path, withIntermediateDirectories: true, attributes: nil)
                
            } catch {
                // print(error)
            }
        }
    }
    
    func saveManifest(_ data: Data) {
        prepareFileDirectory()
        try? data.write(to: URL(fileURLWithPath: CGSSGameResource.manifestPath), options: [.atomic])
    }
    func saveMaster(_ data: Data) {
        prepareFileDirectory()
        try? data.write(to: URL(fileURLWithPath: CGSSGameResource.masterPath), options: [.atomic])
    }
    
    func checkMasterExistence() -> Bool {
        let fm = FileManager.default
        return fm.fileExists(atPath: CGSSGameResource.masterPath) && (NSData.init(contentsOfFile: CGSSGameResource.masterPath)?.length ?? 0) > 0
    }
    
    func checkManifestExistence() -> Bool {
        let fm = FileManager.default
        return fm.fileExists(atPath: CGSSGameResource.manifestPath) && (NSData.init(contentsOfFile: CGSSGameResource.manifestPath)?.length ?? 0) > 0
    }
    
    func getMasterHash() -> String? {
        guard manifest.open(withFlags: SQLITE_OPEN_READONLY) else {
            return nil
        }
        defer {
            manifest.close()
        }
        return manifest.selectByName("master.mdb").first
    }
    
    func getScoreHash() -> [String: String] {
        guard manifest.open(withFlags: SQLITE_OPEN_READONLY) else {
            return [String: String]()
        }
        defer {
            manifest.close()
        }
        return manifest.getMusicScores()
    }
    
    func getBeatmaps(liveId: Int) -> [CGSSBeatmap]? {
        let path = String.init(format: DataPath.beatmap, liveId)
        let fm = FileManager.default
        var result: [CGSSBeatmap]?
        let semaphore = DispatchSemaphore.init(value: 0)
        let dbQueue = MusicScoreDBQueue.init(path: path)
        if fm.fileExists(atPath: path) {
            dbQueue.getBeatmaps(callback: { (beatmaps) in
                result = beatmaps
                semaphore.signal()
            })
        } else {
            semaphore.signal()
        }
        semaphore.wait()
        return result
    }
    
    func getBeatmapCount(liveId: Int) -> Int {
        let semaphore = DispatchSemaphore.init(value: 0)
        var result = 0
        
        let path = String.init(format: DataPath.beatmap, liveId)
        let fm = FileManager.default
        let dbQueue = MusicScoreDBQueue.init(path: path)
        if fm.fileExists(atPath: path) {
            dbQueue.getBeatmapCount(callback: { (count) in
                result = count
                semaphore.signal()
            })
        } else {
            semaphore.signal()
        }
        semaphore.wait()
        return result
    }
    
    func checkExistenceOfBeatmap(liveId: Int) -> Bool {
        let path = String.init(format: DataPath.beatmap, liveId)
        let fm = FileManager.default
        return fm.fileExists(atPath: path)
    }
    
    @objc func updateEnd(notification: Notification) {
        if let types = notification.userInfo?[CGSSUpdateDataTypesName] as? CGSSUpdateDataTypes {
            if types.contains(.master) || types.contains(.card) {
                prepareGachaList {
                    let list = CGSSDAO.shared.cardDict.allValues as! [CGSSCard]
                    for item in list {
                        item.availableType = nil
                    }
                    NotificationCenter.default.post(name: .gameResoureceProcessedEnd, object: self)
                }
            }
        }
    }
    
    // MARK: 卡池数据部分
    var eventAvailabelList = [Int]()
    var gachaAvailabelList = [Int]()
    var timeLimitAvailableList = [Int]()
    var fesAvailabelList = [Int]()
    func prepareGachaList(callback: (() -> Void)?) {
        let group = DispatchGroup.init()
        group.enter()
        master.getEventAvailableList { (result) in
            self.eventAvailabelList = result
            group.leave()
        }
        group.enter()
        master.getGachaAvailableList { (result) in
            self.gachaAvailabelList = result
            group.leave()
        }
        group.enter()
        master.getTimeLimitAvailableList { (result) in
            self.timeLimitAvailableList = result
            group.leave()
        }
        group.enter()
        master.getFesAvailableList { (result) in
            self.fesAvailabelList = result
            group.leave()
        }
        group.notify(queue: DispatchQueue.main, work: DispatchWorkItem.init(block: { 
            callback?()
        }))
    }
}
