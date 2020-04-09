//
//  MessageDetailInfo.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/23.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

final class MessageDetailInfo {
    
    enum ContentType: String {
        case question, answer, user, comment, system
    }
    class Base {
        var id: Int
        var status: String? // normal blocked
        init?(_ data: [String : Any]) {
            guard let id = data["id"] as? Int else { return nil }
            self.id = id
            self.status = data["status"] as? String
        }
        var isBlocked: Bool { status == "blocked" }
    }
    
    final class Question: Base {
        var title: String?
        override init?(_ data: [String : Any]) {
            super.init(data)
            title = data["title"] as? String
        }
    }
    
    final class Answer: Base {
        var summary: String?
        var questionId: Int?
        var question: Question?
        override init?(_ data: [String : Any]) {
            super.init(data)
            summary = data["summary"] as? String
            questionId = data["questionId"] as? Int
            question = Question(data["question"] as? [String: Any] ?? [:])
        }
    }
    
    final class User: Base {
        var name: String?
        var avatarUrl: String?
    }
    
    final class Comment: Base {
        var content: String?
        var answerId: Int?
        var questionId: Int?
        var question: Question?
        override init?(_ data: [String : Any]) {
            super.init(data)
            content = data["content"] as? String
            answerId = data["answerId"] as? Int
            questionId = data["questionId"] as? Int
            question = Question(data["question"] as? [String: Any] ?? [:])
        }
    }
    
    final class Actor: Base {
        var name: String
        var gender: String?
        var avatarUrl: String?
        override init?(_ data: [String : Any]) {
            guard let name = data["name"] as? String else { return nil }
            self.name = name
            self.avatarUrl = data["avatarUrl"] as? String
            self.gender = data["gender"] as? String
            super.init(data)
        }
    }
    
    let id: Int
    let taskId: Int
    var isRead: BehaviorRelay<Bool>
    let resourceType: String
    let action: String
    let actionText: String
    let createdAt: Double
    let contentType: ContentType
    
    var question: Question?
    var answer: Answer?
    var user: User?
    var comment: Comment?
    var actor: [Actor] = []
    
    var url: URL?
    var imageUrl: URL?
    var content: String?
    
    var itemType: MessageType?
//    weak var cell: MessageBaseCell?
    
    init?(_ json: [String: Any]) {
        guard
            let id = json["id"] as? Int,
            let resourceType = json["resourceType"] as? String,
            let contentType = ContentType(rawValue: resourceType),
            let action = json["action"] as? String,
            let actionText = json["actionText"] as? String,
            let createdAt = json["createdAt"] as? Double,
            let isRead = json["isRead"] as? Int
            else { return nil }
        self.id = id
        self.taskId = json["taskId"] as? Int ?? 0
        self.resourceType = resourceType
        self.contentType = contentType
        self.action = action
        self.actionText = actionText
        self.createdAt = createdAt
        self.isRead = BehaviorRelay<Bool>(value: isRead != 0)
        
        if let qData = json["question"] as? [String: Any], let question = Question(qData) {
            self.question = question
        }
        
        if let aData = json["answer"] as? [String: Any], let answer = Answer(aData) {
            self.answer = answer
        }
        
        if let uData = json["user"] as? [String: Any], let user = User(uData) {
            user.name = uData["name"] as? String
            user.avatarUrl = uData["avatarUrl"] as? String
            self.user = user
        }
        
        if let cData = json["comment"] as? [String: Any], let comment = Comment(cData) {
            self.comment = comment
        }
        
        if let actorsData = json["actors"] as? [[String: Any]] {
            for aData in actorsData {
                if let actor = Actor(aData) {
                    self.actor.append(actor)
                }
            }
        }
        
        if let data = json["url"] as? String, let url = URL(string: data) {
            self.url = url
        }
        
        if let data = json["imageUrl"] as? String, let url = URL(string: data) {
            self.imageUrl = url
        }
        
        if let data = json["content"] as? String, !data.isEmpty {
            self.content = data
        }
        
        if let data = json["itemType"] as? String {
            self.itemType = MessageType(rawValue: data)
        }
    }
}
