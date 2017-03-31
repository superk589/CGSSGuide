//
//  CGSSLiveCoordinator.swift
//  CGSSGuide
//
//  Created by zzk on 16/8/8.
//  Copyright © 2016年 zzk. All rights reserved.
//

import Foundation


fileprivate let difficultyFactor: [Int: Double] = [
    5: 1.0,
    6: 1.025,
    7: 1.05,
    8: 1.075,
    9: 1.1,
    10: 1.2,
    11: 1.225,
    12: 1.25,
    13: 1.275,
    14: 1.3,
    15: 1.4,
    16: 1.425,
    17: 1.45,
    18: 1.475,
    19: 1.5,
    20: 1.6,
    21: 1.65,
    22: 1.7,
    23: 1.75,
    24: 1.8,
    25: 1.85,
    26: 1.9,
    27: 1.95,
    28: 2,
    29: 2.1,
    30: 2.2,
]

fileprivate let skillBoostValue = [1: 1200]

fileprivate let comboFactor: [Double] = [1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.7, 2.0]

fileprivate let criticalPercent: [Int] = [0, 5, 10, 25, 50, 70, 80, 90]


class LSCoordinator {
    var team: CGSSTeam
    var live: CGSSLive
    var diff: Int
    var simulatorType: CGSSLiveSimulatorType
    var grooveType: CGSSGrooveType?
    var fixedAppeal: Int?
    var appeal: Int {
        if grooveType != nil {
            return team.getAppealBy(simulatorType: simulatorType, liveType: CGSSLiveTypes.init(grooveType: grooveType!)).total + team.supportAppeal
        } else {
            return team.getAppealBy(simulatorType: simulatorType, liveType: live.filterType).total + team.supportAppeal
        }
    }
    
    lazy var beatmap: CGSSBeatmap = {
        return self.live.getBeatmapByDiff(self.diff)!
    }()
    
    init(team: CGSSTeam, live: CGSSLive, simulatorType: CGSSLiveSimulatorType, grooveType: CGSSGrooveType?, diff: Int, fixedAppeal: Int?) {
        self.team = team
        self.live = live
        self.diff = diff
        self.simulatorType = simulatorType
        self.grooveType = grooveType
        self.fixedAppeal = fixedAppeal
    }
    
    
    func getBaseScorePerNote() -> Double {
        let diffStars = self.live.getStarsForDiff(diff)
        if let fixedAppeal = fixedAppeal {
            return Double(fixedAppeal / beatmap.numberOfNotes) * (difficultyFactor[diffStars] ?? 1)
        } else {
            return Double(self.appeal) / Double(beatmap.numberOfNotes) * (difficultyFactor[diffStars] ?? 1)
        }
    }
    
    func getCriticalPointNoteIndexes(total: Int) -> [Int] {
        var arr = [Int]()
        for i in criticalPercent {
            arr.append(Int(floor(Float(total * i) / 100)))
        }
        return arr
    }
    
    func getComboFactor(of combo: Int, criticalPoints: [Int]) -> Double {
        var result: Double = 1
        for i in 0..<criticalPoints.count {
            if combo >= criticalPoints[i] {
                result = comboFactor[i]
            } else {
                break
            }
        }
        return result
    }
    
    fileprivate func generateScoreDistributions(notes: [CGSSBeatmapNote], contents: [LSScoreBonus], options: LSCoordinatorOptions) -> [LSNote] {

        var lsNotes = [LSNote]()
        
        let baseScore = self.getBaseScorePerNote()
        let criticalPoints = getCriticalPointNoteIndexes(total: notes.count)
        for i in 0..<notes.count {
            let note = notes[i]
            let comboFactor = getComboFactor(of: i + 1, criticalPoints: criticalPoints)
            
            var validContents = [LSScoreBonus]()
            for content in contents {
                if options.contains(.perfectTolerence) {
                    if note.sec >= content.range.begin - 0.06 && note.sec <= content.range.end + 0.06 {
                        validContents.append(content)
                    }
                } else {
                    if note.sec >= content.range.begin && note.sec <= content.range.end {
                        validContents.append(content)
                    }
                }
            }
            
            let comboBonusDistribution = LSDistribution.init(validContents.filter({ $0.type == .comboBonus }))
            let perfectBonusDistribution = LSDistribution.init(validContents.filter({ $0.type == .perfectBonus }))
            let skillBoostBonusDistribution = LSDistribution.init(validContents.filter({ $0.type == .skillBoost }), defaultValue: 1000)
            
            let lsNote = LSNote.init(comboBonusDistribution: comboBonusDistribution, perfectBonusDistribution: perfectBonusDistribution, skillBoostDistribution: skillBoostBonusDistribution, comboFactor: comboFactor, baseScore: baseScore)
            
            lsNotes.append(lsNote)
        }
        return lsNotes
    }
    
    fileprivate func generateScoreBonuses() -> [LSScoreBonus] {
        var result = [LSScoreBonus]()
        
        let leaderSkillUpContent = team.getLeaderSkillUpContentBy(simulatorType: simulatorType)
        
        for i in 0...4 {
            if let member = team[i], let skill = team[i]?.cardRef?.skill {
                let rankedSkill = CGSSRankedSkill.init(skill: skill, level: (member.skillLevel)!)
                if let type = LSScoreBonusTypes.init(type: skill.skillFilterType),
                    let cardType = member.cardRef?.cardType {
                    // 计算同属性歌曲 技能发动率的提升数值(groove活动中是同类型的groove类别)
                    var rateBonus = 0
                    if grooveType != nil {
                        if member.cardRef!.cardType == CGSSCardTypes.init(grooveType: grooveType!) {
                            rateBonus += 30
                        }
                    } else {
                        if member.cardRef!.cardType == live.filterType || live.filterType == .allType {
                            rateBonus += 30
                        }
                    }
                    // 计算触发几率提升类队长技
                    if let leaderSkillBonus = leaderSkillUpContent[cardType]?[.proc] {
                        rateBonus += leaderSkillBonus
                    }
                    
                    // 生成所有可触发范围
                    let ranges = rankedSkill.getUpRanges(lastNoteSec: beatmap.secondOfLastNote)
                    for range in ranges {
                        
                        switch type {
                        case LSScoreBonusTypes.deep:
                            let content1 = LSScoreBonus.init(range: range, value: skill.value, type: .perfectBonus, rate: rankedSkill.procChance, rateBonus: rateBonus)
                            let content2 = LSScoreBonus.init(range: range, value: skill.value2, type: .comboBonus, rate: rankedSkill.procChance, rateBonus: rateBonus)
                            result.append(content1)
                            result.append(content2)
                        case LSScoreBonusTypes.skillBoost:
                            let content = LSScoreBonus.init(range: range, value: skillBoostValue[skill.value] ?? 1000, type: .skillBoost, rate: rankedSkill.procChance, rateBonus: rateBonus)
                            result.append(content)
                        default:
                            let content = LSScoreBonus.init(range: range, value: skill.value, type: type, rate: rankedSkill.procChance, rateBonus: rateBonus)
                            result.append(content)
                        }
                    }
                }
            }
        }
        return result
    }
    
    func generateLiveSimulator(options: LSCoordinatorOptions) -> CGSSLiveSimulator {
        let bonuses = self.generateScoreBonuses()
        let scoreDistributions = self.generateScoreDistributions(notes: self.beatmap.validNotes, contents: bonuses, options: options)
        return CGSSLiveSimulator.init(distributions: scoreDistributions, bonuses: bonuses, notes: self.beatmap.validNotes)
    }
}
