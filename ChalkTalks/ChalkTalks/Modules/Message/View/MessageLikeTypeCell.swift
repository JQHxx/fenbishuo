//
//  MessageLikeTypeCell.swift
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

class MessageLikeTypeCell: MessageBaseCell {
    
    override func setup() {
        super.setup()
        
        leftReddot = true
        
        btmLineInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        
        avatarImageView.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(18)
        }
        
        titleLabel.ss.prepare { (label) in
            contentView.addSubview(label)
            label.numberOfLines = 1
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = UIColor(0x999999FF)
            label.snp.makeConstraints { (make) in
                make.top.equalTo(avatarImageView)
                make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
                make.trailing.lessThanOrEqualToSuperview().offset(-10)
            }
        }
        
        dateLabel.ss.prepare { (label) in
            label.font = UIFont.systemFont(ofSize: 11)
            label.textColor = UIColor(0xCCCCCCFF)
            contentView.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.leading.equalTo(titleLabel)
                make.bottom.equalTo(avatarImageView)
            }
        }
        
        contentLabel.ss.prepare { (label) in
            contentView.addSubview(label)
            label.font = UIFont.systemFont(ofSize: 16)
            label.numberOfLines = 0
            label.textColor = UIColor(0x333333FF)
            label.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
                make.top.equalTo(avatarImageView.snp.bottom).offset(8)
                make.bottom.equalToSuperview().offset(-12)
                make.trailing.equalToSuperview().offset(-16)
            }
        }
    }
    
    override func prepare(_ data: MessageDetailInfo) {
        super.prepare(data)
        
        guard let _ = data.actor.first else { return }
        
        updateTitle()
        
        switch data.contentType {
        case .comment:
            contentLabel.cnText = data.comment?.content
        case .answer:
            contentLabel.cnText = data.answer?.question?.title
        case .question:
            contentLabel.text = data.question?.title
        default:
            contentLabel.text = data.question?.title
        }
    }
}
