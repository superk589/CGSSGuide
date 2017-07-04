//
//  CGSSCacheManager.swift
//  CGSSGuide
//
//  Created by zzk on 2017/2/13.
//  Copyright © 2017年 zzk. All rights reserved.
//

import UIKit
import SDWebImage

class CGSSCacheManager {

    static let shared = CGSSCacheManager()
    
    private init() {
        
    }
    
    func wipeImage() {
        SDImageCache.shared().clearDisk()
        SDImageCache.shared().clearMemory()
        if let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, .userDomainMask, true).first {
            let subPath = cachePath + "/default"
            if FileManager.default.fileExists(atPath: subPath) {
                do {
                    try FileManager.default.removeItem(atPath: subPath)
                } catch {
                    
                }
            }
        }
    }
    
    func wipeCard() {
        for path in getCardFiles() {
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    
                }
            }
        }
    }
    
    func wipeLive() {
        for path in getSongFiles() {
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    
                }
            }
        }
    }
    
    func wipeUserDocuments() {
        let documentPath = NSHomeDirectory() + "/Documents"
        if let files = FileManager.default.subpaths(atPath: documentPath) {
            for file in files {
                let path = documentPath.appendingFormat("/\(file)")
                if FileManager.default.fileExists(atPath: path) {
                    do {
                        try FileManager.default.removeItem(atPath: path)
                    } catch {
                        
                    }
                }
            }
        }
    }
    
    func wipeOther() {
        if let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, .userDomainMask, true).first {
            if let files = FileManager.default.subpaths(atPath: cachePath) {
                for file in files {
                    let path = cachePath.appendingFormat("/\(file)")
                    if file.contains("default") || file.contains("Data") {
                        continue
                    }
                    if FileManager.default.fileExists(atPath: path) {
                        do {
                            try FileManager.default.removeItem(atPath: path)
                        } catch {
                            
                        }
                    }
                }
            }
        }
    }
    
    func sizeToString(size:Int) -> String {
        var postString = "KB"
        var newSize = size
        if size > 1024 * 1024 {
            newSize /= 1024 * 1024
            postString = "MB"
        } else if size > 1024 {
            newSize /= 1024
        } else {
            // 小于1KB 忽略
            newSize = 0
        }
        return String(newSize) + postString
    }
    
    func getCardFiles() -> [String] {
        var filePaths = [String]()
        if let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, .userDomainMask, true).first {
            let subPath = cachePath + "/Data"
            let files = ["card_icon.plist",
                         "card.plist",
                         "char.plist",
                         "leader_skill.plist",
                         "skill.plist",
                         "story_content.plist",
                         "story_episode.plist"]
            for file in files {
                let path = subPath.appendingFormat("/\(file)")
                filePaths.append(path)
            }
        }
        return filePaths
    }
    
    func getSongFiles() -> [String] {
        var filePaths = [String]()
        if let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, .userDomainMask, true).first {
            let subPath = cachePath + "/Data"
            let files = ["live.plist",
                         "song.plist"]
            
            for file in files {
                let path = subPath.appendingFormat("/\(file)")
                filePaths.append(path)
            }
            
            let subPath2 = cachePath + "/Data/Beatmap"
            if let files = FileManager.default.subpaths(atPath: subPath2) {
                for file in files {
                    let path = subPath2.appendingFormat("/\(file)")
                    filePaths.append(path)
                }
            }
        }
        return filePaths
    }
    
    func getCacheSizeOfCard(complete: ((String)->Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            var size = 0
            for path in self.getCardFiles() {
                if let attributes = try? FileManager.default.attributesOfItem(atPath: path) {
                    size += (attributes[FileAttributeKey.size] as! NSNumber).intValue
                }
            }
            DispatchQueue.main.async(execute: {
                complete?(self.sizeToString(size: size))
            })
        }
    }
    
    func getCacheSizeOfSong(complete: ((String)->Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            var size = 0
            for path in self.getSongFiles() {
                if let attributes = try? FileManager.default.attributesOfItem(atPath: path) {
                    size += (attributes[FileAttributeKey.size] as! NSNumber).intValue
                }
            }
            DispatchQueue.main.async(execute: {
                complete?(self.sizeToString(size: size))
            })
        }
    }
    
    func getCacheSizeAt(path: String, complete: ((String)->Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let files = FileManager.default.subpaths(atPath: path) {
                var size = 0
                for file in files {
                    let path = path.appendingFormat("/\(file)")
                    if let attributes = try? FileManager.default.attributesOfItem(atPath: path) {
                        size += (attributes[FileAttributeKey.size] as! NSNumber).intValue
                    }
                }
                DispatchQueue.main.async(execute: {
                    complete?(self.sizeToString(size: size))
                })
            }
        }
    }
    
    func getOtherSize(complete: ((String)->Void)?) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, .userDomainMask, true).first {
                if let files = FileManager.default.subpaths(atPath: cachePath) {
                    var size = 0
                    for file in files {
                        let path = cachePath.appendingFormat("/\(file)")
                        if file.contains("default") || file.contains("Data") {
                            continue
                        }
                        if let attributes = try? FileManager.default.attributesOfItem(atPath: path) {
                            size += (attributes[FileAttributeKey.size] as! NSNumber).intValue
                        }
                    }
                    DispatchQueue.main.async(execute: {
                        complete?(self.sizeToString(size: size))
                    })
                }
            }
        }
    }
    
}
