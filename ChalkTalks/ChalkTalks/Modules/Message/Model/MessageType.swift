//
//  MessageType.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/23.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import Foundation

/// 消息tab分类
enum MessageType: String, CaseIterable {
    case information, invite, reply, like, follower, system
    
    var title: String {
        switch self {
        case .information:
            return "消息"
        case .reply:
            return "评论与回复"
        case .like:
            return "靠谱"
        case .invite:
            return "邀请"
        case .follower:
            return "粉丝"
        case .system:
            return "系统通知"
        }
    }
    
    var imageName: String {
        switch self {
        case .information:
            return ""
        case .reply:
            return "icon_msg_reply"
        case .like:
            return "icon_msg_like"
        case .invite:
            return "icon_msg_invite"
        case .follower:
            return "icon_msg_follower"
        case .system:
            return "icon_msg_system"
        }
    }
    
    var itemEvent: String {
        switch self {
        case .information, .reply:
            return "message_replymeitem"
        case .like:
            return "message_upitem"
        case .invite:
            return "message_inviteitem"
        case .follower:
            return "message_fansitem"
        case .system:
            return "message_informitem"
        }
    }
    
    static var tabs: [MessageType] {
        return [.information, .system]
    }
}
