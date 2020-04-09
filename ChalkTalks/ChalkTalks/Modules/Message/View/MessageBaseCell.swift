//
//  MessageBaseCell.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/2/15.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit

import SnapKit
import SDWebImage
import RxSwift
import RxCocoa

fileprivate let invalidCodes: [String] = [
    "SYSTEM_VIDEO_ENCODE_FAILED",
    "SYSTEM_BLOCK_QUESTION",
    "SYSTEM_BLOCK_ANSWER",
    "SYSTEM_BLOCK_COMMENT",
    "SYSTEM_BLOCK_VIDEO",
]

class MessageBaseCell: BaseTableViewCell {
    
    let avatarImageView = MessageAvatarButton()
    var avatarActionEnable: Bool = true
    
    let titleLabel = UILabel()
    let contentLabel = UILabel()
    let dateLabel = UILabel()
    
    fileprivate var reddotView: UIView?
    
    var reddotType: ReddotView.DotType = .normal
    var enableReddot: Bool = true
    var leftReddot: Bool = false // 左侧显示红点
    var showReddot: Bool {
        set {
            if newValue && reddotView == nil {
                reddotView = ReddotView(reddotType).ss.prepare({ (view) in
                    contentView.addSubview(view)
                    view.snp.makeConstraints { (make) in
                        make.top.equalTo(avatarImageView)
                        if leftReddot {
                            make.leading.equalTo(avatarImageView)
                        } else {
                            make.trailing.equalTo(avatarImageView)
                        }
                        make.size.equalTo(reddotType.size)
                    }
                })
            } else {
                reddotView?.isHidden = !newValue
            }
        }
        get {
            reddotView?.isHidden ?? true
        }
    }
    
    var data: MessageDetailInfo?
    
    let disposeBag: DisposeBag = DisposeBag()
    fileprivate var readBag: DisposeBag!
    
    weak var parentController: MessageViewBaseController?
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        guard let data = data, data.itemType == nil else { return }
        
        if highlighted {
            backgroundColor = UIColor(0xFAFAFAFF)
            contentView.backgroundColor = UIColor(0xFAFAFAFF)
        } else {
            backgroundColor = .white
            contentView.backgroundColor = .white
        }
    }
    
    override func setup() {
        super.setup()
        
        btmLine.isHidden = false
        btmLineInset = UIEdgeInsets(top: 0, left: 66, bottom: 0, right: 0)
        
        avatarImageView.contentMode = .scaleAspectFill
        contentView.addSubview(avatarImageView)
        avatarImageView.rx
            .tap
            .subscribe(onNext: { [weak self] (_) in
                guard
                    let self = self,
                    self.avatarActionEnable,
                    self.data?.itemType == nil,
                    let vc = self.parentController,
                    // 头像合并不跳转个人页
                    !self.avatarImageView.showMultiAvatar || self.data?.actor.count == 1,
                    let data = self.data?.actor.first
                    else { return }
                let user = CTFHomePageVC()
                user.schemaArgu = [
                    "userId": data.id
                ]
                user.hidesBottomBarWhenPushed = true
                vc.navigationController?.pushViewController(user, animated: true)
            }).disposed(by: disposeBag)
        avatarImageView.ss.prepare { (view) in
            view.clipsToBounds = true
            view.layer.cornerRadius = 18
            view.layer.borderWidth = 0.5
            view.layer.borderColor = UIColor(0xEEEEEEFF).cgColor
        }
        avatarImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
            make.size.equalTo(CGSize(width: 36, height: 36))
        }
    }
    
    func isValidMessage(_ data: MessageDetailInfo) -> Bool {
        return !invalidCodes.contains(data.action)
    }

    func prepare(_ data: MessageDetailInfo) {
        self.data = data
        
        if let itemType = data.itemType {
            avatarImageView.setImage(UIImage(named: itemType.imageName), for: .normal)
            avatarImageView.resetToNormal()
        } else if isValidMessage(data) {
            avatarImageView.updateAvatars(data.actor)
        } else if data.action == "SYSTEM_VIDEO_ENCODE_FAILED" {
            // 视频转码失败
            avatarImageView.setImage(UIImage(named: "icon_msg_video"), for: .normal)
            avatarImageView.resetToNormal()
            titleLabel.text = "视频转码失败"
            contentLabel.text = "文件内容已损坏"
        } else if data.action.hasPrefix("SYSTEM_BLOCK_") {
            // Block Message
            avatarImageView.setImage(UIImage(named: "icon_msg_block"), for: .normal)
            avatarImageView.resetToNormal()
            titleLabel.text = "内容限制"
            contentLabel.text = data.actionText
        }
        
        dateLabel.text = DateUtils.formatTimeAgoWith(timestamp: data.createdAt)
        
        guard enableReddot else { return }
        
        readBag = DisposeBag()
        data.isRead
            .subscribe(onNext: { [weak self] (isRead) in
                self?.showReddot = !isRead
            }).disposed(by: readBag)
    }
    
    func updateTitle() {
        
        guard let data = data, let actor = data.actor.first else {
            titleLabel.attributedText = nil
            return
        }
        
        var name = actor.name.nameFormat(data.actor.count)
        var action = data.actionText
        if data.actor.count > 1 {
            let a2 = data.actor[1]
            name += "、" + a2.name.nameFormat(data.actor.count)
            if data.actor.count > 2 {
                action = "等\(data.actor.count)人" + action
            }
        }
        
        let nameAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(0x333333FF),
            .font: UIFont.systemFont(ofSize: 14),
        ]
        
        let actionAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(0x999999FF),
            .font: UIFont.systemFont(ofSize: 14),
        ]
        
        let attrText = NSMutableAttributedString(string: name, attributes: nameAttr)
        attrText.append(NSMutableAttributedString(string: action, attributes: actionAttr))
        
        titleLabel.attributedText = attrText
    }
    
    func updateCategoryContent(_ itemType: MessageType) {
        guard let data = data, let actor = data.actor.first else {
            contentLabel.text = nil
            return
        }
        
        var name = actor.name.nameFormat(data.actor.count)
        var action = data.actionText
        if data.actor.count > 1 {
            let a2 = data.actor[1]
            name += "、" + a2.name.nameFormat(data.actor.count)
            if data.actor.count > 2 {
                action = "等\(data.actor.count)人" + action
            }
        }
        
        contentLabel.text = name + action
    }
}

fileprivate extension String {
    
    func nameFormat(_ actorCount: Int) -> String {
        if actorCount > 2 && count > 3 {
            let value = self[0..<2]
            return value + "..."
        } else if actorCount <= 2 && count > 4 {
            let value = self[0..<3]
            return value + "..."
        } else {
            return self
        }
    }
}
