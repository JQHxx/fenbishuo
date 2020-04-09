//
//  MessageNormalTypeCell.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/23.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import UIKit

import SnapKit
import SDWebImage
import RxSwift
import RxCocoa

class MessageNormalTypeCell: MessageBaseCell {
    
    override func setup() {
        super.setup()
        
        avatarImageView.layer.cornerRadius = 22
        avatarImageView.avatarSize = CGSize(width: 32, height: 32)
        avatarImageView.snp.updateConstraints { (make) in
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.ss.prepare { (label) in
            label.font = UIFont.systemFont(ofSize: 16)
            label.textColor = UIColor(0x333333FF)
            label.numberOfLines = 1
        }
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.top.equalTo(avatarImageView)
            make.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
        
        contentView.addSubview(contentLabel)
        contentLabel.numberOfLines = 2
        contentLabel.ss.prepare { (label) in
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = UIColor(0x999999FF)
        }
        contentLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
        
        contentView.addSubview(dateLabel)
        dateLabel.ss.prepare { (label) in
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = UIColor(0x999999FF)
        }
        dateLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(contentLabel.snp.bottom).offset(9)
            make.bottom.equalToSuperview().offset(-11)
        }
    }
    
    override func prepare(_ data: MessageDetailInfo) {
        super.prepare(data)
        
        dateLabel.text = DateUtils.formatTimeAgoWith(timestamp: data.createdAt)

        if let itemType = data.itemType {
            titleLabel.text = itemType.title
            titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
            contentLabel.font = UIFont.systemFont(ofSize: 14)
            contentView.backgroundColor = UIColor(0xF2F2F2FF)
            btmLine.backgroundColor = UIColor(0xDDDDDDFF)
            titleLabel.textColor = UIColor(0x333333FF)
            contentLabel.textColor = UIColor(0x666666FF)
            dateLabel.textColor = UIColor(0xCCCCCCFF)
            if itemType == .invite {
                contentLabel.text = data.question?.title
            } else {
                updateCategoryContent(itemType)
            }
            return
        }
        
        contentView.backgroundColor = .white
        btmLine.backgroundColor = UIColor(0xEEEEEEFF)
        dateLabel.textColor = UIColor(0x999999FF)
        
        if isValidMessage(data) {
            titleLabel.font = UIFont.systemFont(ofSize: 15)
            contentLabel.font = UIFont.systemFont(ofSize: 15)
            titleLabel.textColor = UIColor(0x999999FF)
            contentLabel.textColor = UIColor(0x333333FF)
        } else {
            titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
            contentLabel.font = UIFont.systemFont(ofSize: 14)
            titleLabel.textColor = UIColor(0x333333FF)
            contentLabel.textColor = UIColor(0x999999FF)
            return
        }
        
        var names: String = data.actor.map({ $0.name }).joined(separator: "、")
        if !names.isEmpty {
            names += " "
        }
        titleLabel.text = names + data.actionText
        
        contentLabel.text = ""
        switch data.contentType {
        case .question:
            guard let question = data.question else { break }
            contentLabel.text = question.title
        case .answer:
            guard let answer = data.answer else { break }
            contentLabel.text = answer.question?.title
        case .comment:
            guard let comment = data.comment else { break }
            contentLabel.text = comment.content
        default:
            break
        }
    }
}
