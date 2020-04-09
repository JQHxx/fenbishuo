//
//  DraftsResourceType.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/3/13.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import Foundation

struct DraftsConfig {
    
    static let rootDirectory: String = {
        return subDirectory("/drafts/")
    }()
    
    static let imageDirectory: String = {
        return subDirectory("/drafts/images/")
    }()
    
    static let videoDirectory: String = {
        return subDirectory("/drafts/videos/")
    }()
    
    static let audioDirectory: String = {
        return subDirectory("/drafts/audios/")
    }()
    
    fileprivate static func subDirectory(_ dir: String) -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let directory = documentsPath + dir
        guard !FileManager.default.fileExists(atPath: directory, isDirectory: nil) else {
            return directory
        }
        do {
            try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            Logger.error("创建drafts文件夹失败 \(dir) \(error)")
        }
        return directory
    }
}
