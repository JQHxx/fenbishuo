//
//  NotificationAlert.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/3/24.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit

import SnapKit
import SwiftEntryKit

// MARK: - Alert

class NotificationAlert {
    
    /// 通知授权
    static func showAuthReq() {
        let authReqView = AuthReqView()
        
        var attributes = EKAttributes()
        attributes.name = "AuthReqAlert"
        attributes.position = .center
        attributes.displayDuration = .infinity

        attributes.positionConstraints.size = .init(width: .constant(value: 305), height: .constant(value: 357 + 56))
        attributes.positionConstraints.maxSize = .init(width: .constant(value: Utils.screenPortraitWidth),
                                                   height: .constant(value: Utils.screenPortraitHeight))

        attributes.screenBackground = .color(color: .init(UIColor.black.withAlphaComponent(0.618)))
        attributes.popBehavior = .overridden

        attributes.entryInteraction = .absorbTouches
        attributes.screenInteraction = .absorbTouches

        SwiftEntryKit.display(entry: authReqView, using: attributes, presentInsideKeyWindow: true)
    }
    
    static func show(_ type: PushType, resource: String, subTitle: String, title: String, payload: [AnyHashable : Any]) {
//        if SwiftEntryKit.isCurrentlyDisplaying(entryNamed: "NotificationAlert") {
//            return
//        }
//        产品需求，进部分页面展示应用内PUSH：
//        1、粉笔说首页
//        2、投票列表页
//        3、我的
//        4、话题详情页
//        5、回答详情页
//        多条push同时弹出时，直接覆盖显示最后一条
        let allowsController: [String] = [
            "MainPageViewController",
            "VoteViewController",
            "MineViewController",
            "CTFTopicDetailsVC",
        ]
        guard
            let vcName = Utils.topVC?.ss.className,
            allowsController.contains(vcName) else {
                Logger.info("[InApp] \(String(describing: Utils.topVC?.ss.className)) \(payload)")
                PushManager.share.handleNotification(payload, inApp: true)
                return
        }
        
        let notificationView = NotificationView()
        notificationView.followsLabel.text = subTitle
        notificationView.titleLabel.text = title
        
        var attributes = EKAttributes()
        attributes.name = "NotificationAlert"
        attributes.position = .top
        attributes.displayDuration = 3
        
        attributes.entryBackground = .color(color: .white)
        let shadowColor = UIColor(0x999999FF)
        attributes.shadow = .active(with: .init(color: .init(shadowColor), opacity: 1, radius: 8, offset: CGSize(width: 0, height: 1)))
        attributes.positionConstraints.safeArea = .overridden// .empty(fillSafeArea: false)
        attributes.entryInteraction.customTapActions.append {
            self.handleNotificationAction(type, resource: resource, payload: payload)
        }
        SwiftEntryKit.display(entry: notificationView, using: attributes, presentInsideKeyWindow: false)
    }
    
    private static func handleNotificationAction(_ type: PushType, resource: String, payload: [AnyHashable : Any]) {
        PushManager.share.handleNotification(payload, inApp: false)
    }
}

// MARK: - NotificationView

fileprivate class NotificationView: BaseView {
    
    let iconView = UIImageView()
    let followsLabel = UILabel()
    
    let titleLabel = UILabel()
    let viewDetail = UILabel()
    
    override func setup() {
        super.setup()
        
        backgroundColor = .white
        
        viewDetail.ss.prepare { (label) in
            label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            label.textColor = .white
            label.backgroundColor = UIColor(0xFF6885FF)
            label.layer.cornerRadius = 14
            label.text = "查看详情"
            label.clipsToBounds = true
            label.textAlignment = .center
            addSubview(label)
            label.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().offset(-16)
                make.trailing.equalToSuperview().offset(-12)
                make.size.equalTo(CGSize(width: 72, height: 24))
            }
        }
        
        titleLabel.ss.prepare { (label) in
            label.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
            label.textColor = UIColor(0x333333FF)
            label.numberOfLines = 2
            label.text = "木质餐椅和塑料餐椅靠不靠谱木木质餐椅靠不靠谱？"
            addSubview(label)
            label.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().offset(-16)
                make.leading.equalToSuperview().offset(12)
                make.trailing.equalTo(viewDetail.snp.leading).offset(-18)
            }
        }
        
        iconView.ss.prepare { (view) in
            view.image = UIImage(named: "notification_follow_count")
            addSubview(view)
            view.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(Utils.statusHeight > 0 ? Utils.statusHeight : 18)
                make.leading.equalToSuperview().offset(12)
                make.bottom.equalTo(titleLabel.snp.top).offset(-8)
                make.height.greaterThanOrEqualTo(12)
            }
        }
        
        followsLabel.ss.prepare { (label) in
            label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            label.textColor = UIColor(0x666666FF)
            label.text = "2.2k人关注"
            addSubview(label)
            label.snp.makeConstraints { (make) in
                make.leading.equalTo(iconView.snp.trailing).offset(4)
                make.centerY.equalTo(iconView)
            }
        }
    }
}

// MARK: - AuthReqView

fileprivate class AuthReqView: BaseView {
    
    override func setup() {
        super.setup()
        
        let contentView: UIView = UIView().ss.prepare { (view) in
            view.clipsToBounds = true
            view.layer.cornerRadius = 12
            view.backgroundColor = .white
            addSubview(view)
            view.snp.makeConstraints { (make) in
                make.leading.top.trailing.equalToSuperview()
                make.size.equalTo(CGSize(width: 305, height: 357))
            }
        }
        
        let bg: UIImageView = UIImageView().ss.prepare { (view) in
            view.image = UIImage(named: "push_auth_req_bg")
            contentView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.leading.top.trailing.equalToSuperview()
                make.height.equalTo(126)
            }
        }
        
        let title: UILabel = UILabel().ss.prepare { (label) in
            label.text = "开启系统通知\n第一时间接收以下消息提醒哦~"
            label.numberOfLines = 2
            label.textAlignment = .center
            label.textColor = UIColor(0x333333FF)
            label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            contentView.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.top.equalTo(bg.snp.bottom)
                make.centerX.equalToSuperview()
            }
        }
        
        let contents: [ContentView] = ContentType.allCases.map { ContentView($0) }
        let stack: UIStackView = UIStackView(arrangedSubviews: contents)
        stack.alignment = .leading
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 16
        contentView.addSubview(stack)
        stack.snp.makeConstraints { (make) in
            make.top.equalTo(title.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
        }
        
        BaseButton(type: .custom).ss.prepare { (button) in
            button.clipsToBounds = true
            button.layer.cornerRadius = 20
            button.backgroundColor = UIColor(0xFF6885FF)
            button.setTitle("立即开启", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.addTarget(self, action: #selector(authAction(_:)), for: .touchUpInside)
            contentView.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview().offset(-10)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 268, height: 40))
            }
        }
        
        BaseButton(type: .custom).ss.prepare { (button) in
            button.setImage(UIImage(named: "badge_close"), for: .normal)
            button.hitTestInset = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
            button.addTarget(self, action: #selector(closeAction(_:)), for: .touchUpInside)
            addSubview(button)
            button.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(contentView.snp.bottom).offset(21)
            }
        }
    }
    
    @objc func authAction(_ btn: BaseButton) {
        PushManager.share.jumpToAuthSetting()
        SwiftEntryKit.dismiss()
    }
    
    @objc func closeAction(_ btn: BaseButton) {
        SwiftEntryKit.dismiss()
    }
    
    enum ContentType: String, CaseIterable {
        case reply, like, follow
        
        var iconName: String { "push_auth_req_\(rawValue)" }
        
        var content: String {
            switch self {
            case .reply:
                return "有人回复了你的话题"
            case .like:
                return "有人关心了你的话题"
            case .follow:
                return "你关注的人发布了新话题"
            }
        }
    }
    
    class ContentView: BaseView {
        
        let type: ContentType
        
        init(_ type: ContentType) {
            self.type = type
            super.init(frame: .zero)
        }
        
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func setup() {
            super.setup()
            
            let icon = UIImageView().ss.prepare { (view) in
                addSubview(view)
                view.image = UIImage(named: type.iconName)
                view.snp.makeConstraints { (make) in
                    make.leading.centerY.equalToSuperview()
                }
            }
            
            UILabel().ss.prepare { (label) in
                label.text = type.content
                label.textColor = UIColor(0x666666FF)
                label.font = UIFont.systemFont(ofSize: 15)
                addSubview(label)
                label.snp.makeConstraints { (make) in
                    make.trailing.top.bottom.equalToSuperview()
                    make.leading.equalTo(icon.snp.trailing).offset(8)
                }
            }
        }
    }
}
