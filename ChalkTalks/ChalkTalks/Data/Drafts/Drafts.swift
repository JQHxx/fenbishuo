
//
//  Drafts.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/3/4.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import Foundation
import AVFoundation

import SQLite
import AliyunOSSiOS
import SDWebImage

import DKImagePickerController

@objc(CTDrafts)
final class Drafts: NSObject {
    
    @objc static let share = Drafts()
    
    @objc let kStoredNotification = "com.fenbishuo.drafts.db.stored.noti.key"
    @objc let kDeleteDraftNotification = "com.fenbishuo.drafts.db.delete.noti.key"

    fileprivate let dbPath: String
    fileprivate let createDraftTableKey = "com.fenbishuo.drafts.db.create.key"
    
    fileprivate var db: Connection?
    fileprivate let queue = DispatchQueue(label: "com.fenbishuo.drafts.db")
    
    fileprivate var userId: String {
        return UserCache.getCurrentUserID()
    }
    
    fileprivate var draftsCache: [DraftAnswer] = []
        
    // MARK: - 初始化
    
    fileprivate override init() {
        dbPath = DraftsConfig.rootDirectory + "/drafts.db"

        super.init()
        
        let dbExists = FileManager.default.fileExists(atPath: dbPath)

        do {
            db = try SQLite.Connection(dbPath)
            Logger.debug("[Drafts] db path: \(dbPath)")
        } catch {
            Logger.error("[Drafts] 数据库链接失败：\(error)")
            #if DEBUG
            #else
            return
            #endif
        }
        
        if !dbExists || !UserDefaults.standard.bool(forKey: createDraftTableKey) {
            // create tables
            do {
                try db?.run(AnswerColumns.create())
                try db?.run(AnswerItemColumns.create())
                try db?.run(CommentColumns.create())
                UserDefaults.standard.set(true, forKey: createDraftTableKey)
                UserDefaults.standard.set(currentDBVersion, forKey: dbVersionKey)
                UserDefaults.standard.synchronize()
            } catch {
                Logger.error("[Drafts] 数据库建表失败: \(error)")
            }
        } else {
            checkDBVersion()
        }
    }
    
    fileprivate let currentDBVersion: Int = 1
    fileprivate let dbVersionKey: String = "com.fenbishuo.drafts.db.version.key"
    
    fileprivate func checkDBVersion() {
        do {
            let oldVersion = UserDefaults.standard.integer(forKey: dbVersionKey)
            
            // add comment table
            if oldVersion < 1 {
                try db?.run(CommentColumns.create())
            }
            
            UserDefaults.standard.set(currentDBVersion, forKey: dbVersionKey)
            UserDefaults.standard.synchronize()
        } catch {
            Logger.error("[Draft] 更新数据库失败 \(error)")
        }
    }
    
    fileprivate func postStoredNotication() {
        draftsCache = []
        NotificationCenter.default.post(name: Notification.Name(rawValue: kStoredNotification), object: nil)
    }
    
    fileprivate func postDeleteNotication() {
        draftsCache = []
        NotificationCenter.default.post(name: Notification.Name(rawValue: kDeleteDraftNotification), object: nil)
    }
    
    // MARK: - 查询
    
    /// 获取图片
    /// - Parameter withPath: imagePath
    @objc func image(withPath: String) -> UIImage? {
        let path = DraftsConfig.imageDirectory + (withPath as NSString).lastPathComponent
        if FileManager.default.fileExists(atPath: path) {
            return UIImage(contentsOfFile: path)
        } else {
            return nil
        }
    }
    
    /// 获取草稿数量
    @objc func draftsCount() -> Int {
        if let answer = draftsCache.first, answer.userId == userId {
            return draftsCache.count
        }
        
        guard let db = db else { return 0 }
        
        let query = AnswerColumns.table.filter(AnswerColumns.userId == userId).count
        do {
            return try db.scalar(query)
        } catch {
            Logger.error("[Drafts] 获取草稿数量失败: \(error)")
            return 0
        }
    }
    
    /// 获取当前用户的所有草稿
    @objc func allDrafts() -> [DraftAnswer] {
        if let answer = draftsCache.first, answer.userId == userId {
            return draftsCache
        }
        
        guard let db = db else { return [] }
        
        let query: Table = AnswerColumns.table.filter(AnswerColumns.userId == userId)
        do {
            let answers: [DraftAnswer] = try db.prepare(query).compactMap({ DraftAnswer($0) })
            try fetchItems(answers)
            draftsCache = answers
            return answers
        } catch {
            Logger.error("[Drafts] 获取所有草稿失败: \(error)")
            return []
        }
    }
    
    /// 获取草稿箱
    /// - Parameter questionId: 话题Id
    @objc func getDraft(questionId: Int) -> DraftAnswer? {
        guard let db = db else { return nil }
        
        var answer: DraftAnswer?
        let semaphore = DispatchSemaphore(value: 0)
        
        queue.async {
            let predicate = AnswerColumns.userId == self.userId && AnswerColumns.questionId == questionId
            let query = AnswerColumns.table.filter(predicate)
            do {
                guard let row = try db.pluck(query), let _answer = DraftAnswer(row) else {
                    semaphore.signal()
                    return
                }
                try self.fetchItems([_answer])
                answer = _answer
            } catch {
                Logger.error("[Drafts] 获取草稿失败 \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        return answer
    }
    
    fileprivate func fetchItems(_ answers: [DraftAnswer]) throws {
        guard let db = db else { return }
        
        for answer in answers {
            let query: Table = AnswerItemColumns.table.filter(AnswerItemColumns.draftId == answer.draftId)
            let items = try db.prepare(query).compactMap({ DraftAnswerItem($0) })
            if answer.type == .photo {
                // 从imageCacheKey获取
                answer.items = items
//                    .filter({ self.imageCache.diskImageDataExists(withKey: $0.imagePath)})
                    .sorted(by: { $0.index < $1.index })
            } else {
                // 从image路径获取
                answer.items = items.sorted(by: { $0.index < $1.index })
            }
        }
    }
    
    // MARK: - 增删
    
    /// 添加图文回答草稿
    /// - Parameters:
    ///   - questionId: 问题ID
    ///   - questionTitle: 问题标题
    ///   - content: 回答内容
    ///   - images: 回答图片
    @objc func addDraft(questionId: Int, questionTitle: String, content: String?, images: [UploadImageFileModel]) {
        queue.async {
            guard let db = self.db else { return }
            
            do {
                var setters: [SQLite.Setter] = [
                    AnswerColumns.userId <- self.userId,
                    AnswerColumns.type <- DraftAnswerType.photo.rawValue,
                    AnswerColumns.questionId <- questionId,
                    AnswerColumns.questionTitle <- questionTitle,
                    AnswerColumns.content <- content,
                    AnswerColumns.updateAt <- Date().timeIntervalSince1970
                ]
                
                let predicate = AnswerColumns.userId == self.userId && AnswerColumns.questionId == questionId
                let query: Table = AnswerColumns.table.filter(predicate)
                var draftId: Int = 0
                if let oldId = try db.pluck(query)?.get(AnswerColumns.draftId) {
                    draftId = oldId
                    setters += [AnswerColumns.draftId <- oldId]
                }
                
                let insert: Insert = AnswerColumns.table.insert(or: .replace, setters)
                let lastRowId = try db.run(insert)
                                
                let delete = AnswerItemColumns.table.filter(AnswerItemColumns.draftId == draftId).delete()
                try db.run(delete)
                
                guard !images.isEmpty else {
                    Logger.info("[Drafts] 图文草稿箱保存成功，questionId: \(questionId), draftId: \(draftId)")
                    self.postStoredNotication()
                    return
                }
                
                if draftId == 0 {
                    draftId = Int(lastRowId)
                }
                
                var idx = 0
                for image in images {
                    guard let md5 = self.storeToDisk(image) else {
                        Logger.error("[Drafts] 图片保存失败，questionId:\(questionId) index:\(idx)")
                        continue
                    }
                    let itemInsert: Insert = AnswerItemColumns.table.insert(or: .replace, [
                        AnswerItemColumns.draftId <- draftId,
                        AnswerItemColumns.index <- idx,
                        AnswerItemColumns.imagePath <- md5,
                        AnswerItemColumns.objectKey <- image.objectKey,
                        AnswerItemColumns.imageId <- image.imageId
                    ])
                    try db.run(itemInsert)
                    idx += 1
                }
                Logger.info("[Drafts] 图文草稿保存成功，questionId: \(questionId), draftId: \(draftId)")
                self.postStoredNotication()
            } catch {
                Logger.error("[Drafts] 新增草稿失败，questionId: \(questionId) \(error)")
            }
        }
    }
    
    /// 添加视频回答草稿（本地拍摄）
    @objc func addVideoDraft(
        path: URL,
        content: String?,
        questionId: Int,
        questionTitle: String,
        coverImageIndex: Int,
        coverImage: UIImage?) {
        do {
            let targetPath = try copyVideo(fromPath: path)
            addVideoDraftToDB(
                targetPath,
                content: content,
                questionId: questionId,
                questionTitle: questionTitle,
                coverImageIndex: coverImageIndex,
                coverImage: coverImage
            )
        } catch {
            Logger.error("[Drafts] 复制视频失败 \(path) \(error)")
        }
    }
    
    ///  添加视频回答草稿（相册选取）
    @objc func addVideoDraft(
        asset: AVURLAsset,
        content: String?,
        questionId: Int,
        questionTitle: String,
        coverImageIndex: Int,
        coverImage: UIImage?) {
        do {
            let targetPath = try copyVideo(fromPath: asset.url)
            addVideoDraftToDB(
                targetPath,
                content: content,
                questionId: questionId,
                questionTitle: questionTitle,
                coverImageIndex: coverImageIndex,
                coverImage: coverImage
            )
        } catch {
            Logger.error("[Drafts] 复制视频失败 \(asset.url) \(error)")
        }
    }
    
    fileprivate func addVideoDraftToDB(
        _ path: String,
        content: String?,
        questionId: Int,
        questionTitle: String,
        coverImageIndex: Int,
        coverImage: UIImage?) {
                
        queue.async {
            guard let db = self.db else { return }
            
            do {
                var setters: [SQLite.Setter] = [
                    AnswerColumns.userId <- self.userId,
                    AnswerColumns.type <- DraftAnswerType.video.rawValue,
                    AnswerColumns.questionId <- questionId,
                    AnswerColumns.questionTitle <- questionTitle,
                    AnswerColumns.content <- content,
                    AnswerColumns.videoPath <- path,
                    AnswerColumns.updateAt <- Date().timeIntervalSince1970
                ]
                
                // 保存图片
                if let cover = coverImage, let md5 = self.storeToDisk(cover) {
                    setters += [
                        AnswerColumns.videoCoverPath <- md5,
                        AnswerColumns.videoCoverIndex <- coverImageIndex
                    ]
                }
                
                // 确定新增还是更新
                let predicate = AnswerColumns.userId == self.userId && AnswerColumns.questionId == questionId
                let query = AnswerColumns.table.filter(predicate)
                if let oldId = try db.pluck(query)?.get(AnswerColumns.draftId) {
                    setters += [AnswerColumns.draftId <- oldId]
                }
                
                let insert: Insert = AnswerColumns.table.insert(or: .replace, setters)
                let lastRowid = try db.run(insert)
                
                Logger.info("[Drafts] 视频草稿保存成功，questionId: \(questionId), draftId: \(lastRowid)")
                self.postStoredNotication()
            } catch {
                Logger.error("[Drafts] 添加视频草稿失败 \(error)")
            }
        }
    }
    
    /// 添加图语回答草稿
    /// - Parameters:
    ///   - content: 文本内容
    ///   - questionId: 话题ID
    ///   - questionTitle: 话题Title
    ///   - assets: 图语资源
    func addPhotoWithAudio(
        content: String?,
        questionId: Int,
        questionTitle: String,
        assets: [DKAsset]) {
                
        queue.async {
            guard let db = self.db else { return }
            
            do {
                var setters: [SQLite.Setter] = [
                    AnswerColumns.userId <- self.userId,
                    AnswerColumns.type <- DraftAnswerType.photoWithAudio.rawValue,
                    AnswerColumns.questionId <- questionId,
                    AnswerColumns.questionTitle <- questionTitle,
                    AnswerColumns.content <- content,
                    AnswerColumns.updateAt <- Date().timeIntervalSince1970
                ]
                
                let predicate = AnswerColumns.userId == self.userId && AnswerColumns.questionId == questionId
                let query = AnswerColumns.table.filter(predicate)
                var draftId: Int = 0
                if let oldId = try db.pluck(query)?.get(AnswerColumns.draftId) {
                    draftId = oldId
                    setters += [AnswerColumns.draftId <- oldId]
                }
                
                let insert: Insert = AnswerColumns.table.insert(or: .replace, setters)
                let lastRowId = try db.run(insert)
                                
                let delete = AnswerItemColumns.table.filter(AnswerItemColumns.draftId == draftId).delete()
                try db.run(delete)
                
                guard !assets.isEmpty else {
                    Logger.info("[Drafts] 语音草稿箱保存成功，questionId: \(questionId), draftId: \(draftId)")
                    self.postStoredNotication()
                    return
                }
                
                if draftId == 0 {
                    draftId = Int(lastRowId)
                }
                
                var idx = 0
                for asset in assets {
                    var newPath: String?
                    if let oldPath = asset.imagePath.value {
                        if let sdPath = SDImageCache.shared.cachePath(forKey: oldPath),
                            FileManager.default.fileExists(atPath: sdPath) {
                            newPath = try self.copyImage(fromPath: sdPath) // 是否为SDImageCache
                        } else if FileManager.default.fileExists(atPath: oldPath) {
                            newPath = try self.copyImage(fromPath: oldPath)
                        }
                    }
                    
                    if newPath == nil, let image = asset.image, let path = self.storeToDisk(image) {
                        newPath = path
                    }

                    guard let imagePath = newPath else {
                        Logger.error("[Drafts] 图语草稿 图片不存在。 index: \(idx)")
                        continue
                    }
                    
                    var setters: [SQLite.Setter] = [
                        AnswerItemColumns.draftId <- draftId,
                        AnswerItemColumns.index <- idx,
                        AnswerItemColumns.imagePath <- imagePath,
                    ]
                    
                    // 已上传图片和音频
                    if asset.uploadState.value == .success, let info = asset.imageUploadInfo as? OSSUploadInfo {
                        setters += [
                            AnswerItemColumns.objectKey <- info.objectKey,
                            AnswerItemColumns.imageId <- info.objectId
                        ]
                        
                        if let info = asset.audioUploadInfo as? OSSUploadInfo {
                            setters += [
                                AnswerItemColumns.audioKey <- info.objectKey,
                                AnswerItemColumns.audioId <- info.objectId
                            ]
                        }
                    }
                    
                    if let audioPath = asset.audioPath.value {
                        let path = try self.copyAudio(fromPath: audioPath)
                        setters += [
                            AnswerItemColumns.audioPath <- path,
                            AnswerItemColumns.audioDuration <- asset.audioDuration
                        ]
                    }
                    let itemInsert: Insert = AnswerItemColumns.table.insert(or: .replace, setters)
                    try db.run(itemInsert)
                    idx += 1
                    self.postStoredNotication()
                }
                Logger.info("[Drafts] 图语草稿保存成功，questionId: \(questionId), draftId: \(draftId)")
            } catch {
                Logger.error("[Drafts] 添加图语草稿失败 \(error)")
            }
        }
    }
    
    /// 删除草稿
    /// - Parameter id: draftId
    @objc func removeDraft(id: Int) {
        queue.async {
            guard let db = self.db else { return }
            
            let delete: Delete = AnswerColumns.table.filter(AnswerColumns.draftId == id).delete()
            do {
                try db.run(delete)
                self.removeItems(db: db, draftId: id)
                Logger.debug("[Draft] 删除草稿成功")
                self.postDeleteNotication()
            } catch {
                Logger.error("[Draft] 删除草稿失败 \(error)")
            }
        }
    }
    
    /// 删除草稿
    /// - Parameter questionId: 话题ID
    @objc func removeDraft(questionId: Int) {
        queue.async {
            guard let db = self.db else { return }
            
            let predicate = AnswerColumns.userId == self.userId && AnswerColumns.questionId == questionId
            let query: QueryType = AnswerColumns.table.filter(predicate)
            do {
                guard let draftId = try db.pluck(query)?.get(AnswerColumns.draftId) else {
                    Logger.error("[Draft] 未找到待删除草稿 \(questionId)")
                    return
                }
                try db.run(query.delete())
                // TODO: remove local video resource
                self.removeItems(db: db, draftId: draftId)
                Logger.debug("[Draft] 删除草稿成功")
                self.postDeleteNotication()
            } catch {
                Logger.error("[Draft] 删除草稿失败 \(error)")
            }
        }
    }
    
    fileprivate func removeItems(db: Connection, draftId: Int) {
        do {
            let delete: Delete = AnswerItemColumns.table.filter(AnswerItemColumns.draftId == draftId).delete()
            try db.run(delete)
            // TODO: remove local resource
        } catch {
            Logger.error("[Draft] 删除草稿关联资源失败 \(error)")
        }
    }
    
    // MARK: - Comment
    
    @objc func getComment(answerId: Int) -> String? {
        return getComment(answerId: answerId, commentId: 0)
    }
    
    /// 获取评论草稿
    /// - Parameters:
    ///   - answerId: 回答ID
    ///   - commentId: 可选，回复评论ID
    @objc func getComment(answerId: Int, commentId: Int) -> String? {
        guard let db = db else { return nil }
        
        var comment: String?
        let semaphore = DispatchSemaphore(value: 0)
        
        queue.async {
            let predicate = CommentColumns.userId == self.userId
                && CommentColumns.answerId == answerId
                && CommentColumns.commentId == commentId
            let query = CommentColumns.table.filter(predicate)
            do {
                let row = try db.pluck(query)
                let content = try row?.get(CommentColumns.content)
                comment = content
            } catch {
                Logger.error("[Drafts] 获取评论草稿失败 \(error)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        return comment
    }
    
    @objc func storeComment(answerId: Int, content: String) {
        storeComment(answerId: answerId, commentId: 0, content: content)
    }
    
    /// 保存评论草稿
    /// - Parameters:
    ///   - answerId: 回答ID
    ///   - commentId: 可选，所回复评论ID
    ///   - content: 评论内容
    @objc func storeComment(answerId: Int, commentId: Int, content: String) {
        queue.async {
            guard let db = self.db else { return }
            
            do {
                var setters: [SQLite.Setter] = [
                    CommentColumns.userId <- self.userId,
                    CommentColumns.answerId <- answerId,
                    CommentColumns.commentId <- commentId,
                    CommentColumns.content <- content,
                    CommentColumns.updateAt <- Date().timeIntervalSince1970
                ]
                
                let predicate = CommentColumns.userId == self.userId
                    && CommentColumns.answerId == answerId
                    && CommentColumns.commentId == commentId
                let query = CommentColumns.table.filter(predicate)
                if let oldId = try db.pluck(query)?.get(CommentColumns.id) {
                    setters += [CommentColumns.id <- oldId]
                }
                
                let insert: Insert = CommentColumns.table.insert(or: .replace, setters)
                try db.run(insert)
            } catch {
                Logger.error("[Drafts] 保存评论草稿失败 \(error)")
            }
        }
    }
    
    @objc func removeComment(answerId: Int) {
        removeComment(answerId: answerId, commentId: 0)
    }
    
    /// 移除评论草稿
    @objc func removeComment(answerId: Int, commentId: Int) {
        queue.async {
            guard let db = self.db else { return }
            
            let predicate = CommentColumns.userId == self.userId
                && CommentColumns.answerId == answerId
                && CommentColumns.commentId == commentId
            let delete = CommentColumns.table.filter(predicate).delete()
            do {
                try db.run(delete)
            } catch {
                Logger.error("[Drafts] 移除评论草稿失败 \(error)")
            }
        }
    }
    
    // MARK: - Media Manager
    
    fileprivate func storeToDisk(_ image: UploadImageFileModel) -> String? {
        var md5: String
        var data: Data
        if !image.imgMD5String.isEmpty && !image.localImgData.isEmpty {
            md5 = image.imgMD5String
            data = image.localImgData
        } else if let d = image.localImage.jpegData(compressionQuality: 1),
            let m = OSSUtil.dataMD5String(d) {
            md5 = m
            data = d
        } else {
            return nil
        }
        
        let fileName = md5 + ".jpeg"
        let path = DraftsConfig.imageDirectory + fileName
        if !FileManager.default.fileExists(atPath: path) {
            try? data.write(to: URL(fileURLWithPath: path))
        }

        return fileName
    }
    
    fileprivate func storeToDisk(_ image: UIImage) -> String? {
        guard
            let data = image.jpegData(compressionQuality: 1),
            let md5 = OSSUtil.dataMD5String(data) else {
            return nil
        }
        
        let fileName = md5 + ".jpeg"
        let path = DraftsConfig.imageDirectory + fileName
        if !FileManager.default.fileExists(atPath: path) {
            try? data.write(to: URL(fileURLWithPath: path))
        }

        return fileName
    }
    
    fileprivate func copyVideo(fromPath: URL) throws -> String {
        let filename = fromPath.lastPathComponent
        let targetPath = URL(fileURLWithPath: DraftsConfig.videoDirectory + filename)
        if !FileManager.default.fileExists(atPath: DraftsConfig.videoDirectory + filename) {
            try FileManager.default.copyItem(at: fromPath, to: targetPath)
        }
        return filename
    }
    
    fileprivate func copyImage(fromPath: String) throws -> String {
        let filename = (fromPath as NSString).lastPathComponent
        let targetPath = DraftsConfig.imageDirectory + filename
        if !FileManager.default.fileExists(atPath: targetPath) {
            try FileManager.default.copyItem(atPath: fromPath, toPath: targetPath)
        }
        return filename
    }
    
    fileprivate func copyAudio(fromPath: String) throws -> String {
        let filename = (fromPath as NSString).lastPathComponent
        let targetPath = DraftsConfig.audioDirectory + filename
        if !FileManager.default.fileExists(atPath: targetPath) {
            try FileManager.default.copyItem(atPath: fromPath, toPath: targetPath)
        }
        return filename
    }
}
