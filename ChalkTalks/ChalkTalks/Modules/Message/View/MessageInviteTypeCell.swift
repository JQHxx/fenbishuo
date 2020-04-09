//
//  MessageInviteCell.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/3/6.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit

import SnapKit
import SDWebImage
import RxSwift
import RxCocoa

class MessageInviteTypeCell: MessageBaseCell {
    
    override func setup() {
        super.setup()
        
        reddotType = .invite
        leftReddot = true
        
        btmLineInset = .zero
        btmLineHeight = 8
        btmLine.backgroundColor = UIColor(0xF6F6F6FF)
        
        let margin: CGFloat = 16
        
        avatarImageView.showMultiAvatar = false
        avatarImageView.layer.cornerRadius = 9
        avatarImageView.layer.borderWidth = 0.5
        avatarImageView.layer.borderColor = UIColor(0xEEEEEEFF).cgColor
        avatarImageView.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview().offset(margin)
            make.top.equalToSuperview().offset(12)
            make.size.equalTo(CGSize(width: 18, height: 18))
        }
        
        titleLabel.ss.prepare { (label) in
            contentView.addSubview(label)
            label.numberOfLines = 1
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = UIColor(0x999999FF)
            label.snp.makeConstraints { (make) in
                make.centerY.equalTo(avatarImageView)
                make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
                make.trailing.lessThanOrEqualToSuperview().offset(-10)
            }
        }
        
        contentLabel.ss.prepare { (label) in
            contentView.addSubview(label)
            label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
            label.numberOfLines = 0
            label.textColor = UIColor(0x333333FF)
            label.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().offset(margin)
                make.top.equalTo(avatarImageView.snp.bottom).offset(11)
                make.trailing.equalToSuperview().offset(-margin)
            }
        }
        
        dateLabel.ss.prepare { (label) in
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = UIColor(0x999999FF)
            contentView.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().offset(margin)
                make.top.equalTo(contentLabel.snp.bottom).offset(20)
                make.bottom.equalToSuperview().offset(-14 - btmLineHeight)
            }
        }
        
        ImageButton(position: .left, spacing: 5).ss.prepare { (button) in
            button.setTitle("我来回答", for: .normal)
            button.setImage(UIImage(named: "icon_msg_edit"), for: .normal)
            button.setTitleColor(UIColor(0xFF6885FF), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            contentView.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.trailing.equalToSuperview().offset(-margin)
                make.bottom.equalToSuperview().offset(-12 - btmLineHeight)
            }
//            button.addTarget(self, action: #selector(inviteAction(_:)), for: .touchUpInside)
            button.isUserInteractionEnabled = false
        }
    }
    
//    @objc func inviteAction(_ btn: ImageButton) {
//        guard let question = data?.question else { return }
//        let vc = PublishSelectViewController(questionId: question.id, questionTitle: question.title ?? "")
//        Utils.topVC?.present(vc, animated: true, completion: nil)
//    }
    
    override func prepare(_ data: MessageDetailInfo) {
        super.prepare(data)
        
        guard let question = data.question else { return }
        
        updateTitle()
        contentLabel.text = question.title
    }
}
