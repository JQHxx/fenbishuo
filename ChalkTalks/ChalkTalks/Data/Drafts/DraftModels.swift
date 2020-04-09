//
//  DraftModels.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/3/4.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import Foundation
import SQLite

@objc
enum DraftAnswerType: Int {
    case photo, video, photoWithAudio
}

@objc(CTDraftAnswer)
class DraftAnswer: BaseModel {
    
    @objc var draftId: Int
    
    @objc var userId: String
    
    @objc var questionId: Int
    
    @objc var questionTitle: String
    
    @objc var type: DraftAnswerType
    
    @objc var content: String?
    
    @objc var videoPath: String?
    
    @objc var videoCoverPath: String?
    
    @objc var videoCoverIndex: Int
    
    /// unix timestamp
    @objc var updateAt: TimeInterval
    
    @objc var items: [DraftAnswerItem]
    
    init?(_ row: Row) {
        do {
            draftId = try row.get(AnswerColumns.draftId)
            userId = try row.get(AnswerColumns.userId)
            questionId = try row.get(AnswerColumns.questionId)
            questionTitle = try row.get(AnswerColumns.questionTitle)
            type = DraftAnswerType(rawValue: try row.get(AnswerColumns.type)) ?? .photo
            content = try row.get(AnswerColumns.content)
            
            if let path = try row.get(AnswerColumns.videoPath) {
                videoPath = DraftsConfig.videoDirectory + path
            }
            
            if let path = try row.get(AnswerColumns.videoCoverPath) {
                videoCoverPath = DraftsConfig.imageDirectory + path
            }
            videoCoverIndex = try row.get(AnswerColumns.videoCoverIndex)
            
            updateAt = try row.get(AnswerColumns.updateAt)
            items = []
        } catch {
            Logger.error("DraftAnswer读取数据失败: \(error)")
            return nil
        }
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func update() {
        
    }
}

@objc(CTDraftAnswerItem)
class DraftAnswerItem: BaseModel {
    
    @objc var draftId: Int
    @objc var index: Int
    
    @objc var imagePath: String
    @objc var objectKey: String?
    @objc var imageId: String?
    
    @objc var audioPath: String?
    @objc var audioDuration: TimeInterval
    @objc var audioKey: String?
    @objc var audioId: String?
    
    init?(_ row: Row) {
        do {
            draftId = try row.get(AnswerItemColumns.draftId)
            index = try row.get(AnswerItemColumns.index)
            imagePath = DraftsConfig.imageDirectory + (try row.get(AnswerItemColumns.imagePath))
            objectKey = try row.get(AnswerItemColumns.objectKey)
            imageId = try row.get(AnswerItemColumns.imageId)
            
            if let path = try row.get(AnswerItemColumns.audioPath) {
                audioPath = DraftsConfig.audioDirectory + path
            }
            audioDuration = try row.get(AnswerItemColumns.audioDuration)
            audioKey = try row.get(AnswerItemColumns.audioKey)
            audioId = try row.get(AnswerItemColumns.audioId)
        } catch {
            Logger.error("DraftAnswer读取数据失败: \(error)")
            return nil
        }
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
