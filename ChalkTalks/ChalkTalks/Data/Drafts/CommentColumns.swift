//
//  CommentColumns.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/3/23.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import Foundation

import SQLite

struct CommentColumns {
    
    static let table = Table("draft_comment")
    
    static let id = Expression<Int>("id")
    
    static let userId = Expression<String>("userId")
    
    static let answerId = Expression<Int>("answerId")
    
    static let commentId = Expression<Int>("commentId")
    
    static let content = Expression<String>("content")
    
    static let updateAt = Expression<TimeInterval>("updateAt")
    
    static func create() -> String {
        return table.create(ifNotExists: true) { (t) in
            t.column(id, primaryKey: .autoincrement)
            t.column(userId)
            t.column(answerId)
            t.column(commentId, defaultValue: 0)
            t.column(content)
            t.column(updateAt)
        }
    }
}
