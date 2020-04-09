//
//  DraftColumns.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/3/4.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import Foundation

import SQLite

/// 回答表
struct AnswerColumns {
    
    static let table = Table("draft_answer")
    
    static let draftId = Expression<Int>("draftId")
    
    static let userId = Expression<String>("userId")
    
    static let questionId = Expression<Int>("questionId")
    
    static let questionTitle = Expression<String>("questionTitle")
    
    static let type = Expression<Int>("type")
    
    static let content = Expression<String?>("content")
    
    static let videoPath = Expression<String?>("videoPath")
    
    static let videoCoverPath = Expression<String?>("videoCoverPath")
    
    static let videoCoverIndex = Expression<Int>("videoCoverIndex")
    
    static let updateAt = Expression<TimeInterval>("updateAt")
    
    static func create() -> String {
        return table.create(ifNotExists: true) { (t) in
            t.column(draftId, primaryKey: .autoincrement)
            t.column(userId)
            t.column(questionId)
            t.column(questionTitle)
            t.column(type)
            t.column(content)
            t.column(videoPath)
            t.column(videoCoverPath)
            t.column(videoCoverIndex, defaultValue: 0)
            t.column(updateAt)
        }
    }
}

/// 回答和图片语音映射表，Many to Many
struct AnswerItemColumns {
    
    static let table = Table("draft_answer_item")
    
    static let draftId = Expression<Int>("draftId")
    
    static let index = Expression<Int>("index")
    
    static let imagePath = Expression<String>("imagePath")
    static let objectKey = Expression<String?>("objectKey")
    static let imageId = Expression<String?>("imageId")
    
    static let audioPath = Expression<String?>("audioPath")
    static let audioDuration = Expression<TimeInterval>("audioDuration")
    static let audioKey = Expression<String?>("audioKey")
    static let audioId = Expression<String?>("audioId")
    
    static func create() -> String {
        return table.create(ifNotExists: true) { (t) in
            t.column(draftId)
            t.column(index)
            t.column(imagePath)
            t.column(objectKey)
            t.column(imageId)
            t.column(audioPath)
            t.column(audioDuration, defaultValue: 0)
            t.column(audioKey)
            t.column(audioId)
            t.primaryKey(draftId, index)
        }
    }
}
