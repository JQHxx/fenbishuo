//
//  MessageSystemTypeCell.swift
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

class MessageSystemTypeCell: MessageBaseCell {
    
    fileprivate let systemContentView = ContentView()
    fileprivate let coverImageView = CoverImageView()
    fileprivate let moreImageView = UIImageView()
        
    override func setup() {
        super.setup()
        
        btmLine.isHidden = true
        avatarActionEnable = false
        avatarImageView.isSystemMessage = true
        
        dateLabel.ss.prepare { (label) in
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = UIColor(0x999999FF)
            label.text = " "
            label.setContentHuggingPriority(.required, for: .vertical)
            label.setContentCompressionResistancePriority(.required, for: .vertical)
            contentView.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(2)
                make.centerX.equalToSuperview()
            }
        }
        
        avatarImageView.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(dateLabel.snp.bottom).offset(10).priority(.required)
            make.size.equalTo(CGSize(width: 36, height: 36))
        }
        
        systemContentView.ss.prepare { (view) in
//            view.clipsToBounds = false
//            view.layer.masksToBounds = false
//            view.layer.cornerRadius = 6
//            view.layer.borderColor = UIColor(0xDDDDDDFF).cgColor
//            view.layer.borderWidth = 0.5
            contentView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.top.equalTo(avatarImageView)
                make.leading.equalTo(avatarImageView.snp.trailing).offset(13 - ContentView.contentOffset)
                make.trailing.equalToSuperview().offset(-16)
                make.bottom.equalToSuperview().offset(-28)
            }
        }
        
        coverImageView.ss.prepare { (view) in
            view.backgroundColor = .clear
            view.contentMode = .scaleAspectFill
            systemContentView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.top.trailing.equalToSuperview()
                make.leading.equalToSuperview().offset(ContentView.contentOffset)
                make.height.equalTo(0.001)
            }
        }
        
        titleLabel.ss.prepare { (label) in
            label.font = UIFont.boldSystemFont(ofSize: 15)
            label.textColor = UIColor(0x333333FF)
            label.numberOfLines = 0
            label.setContentHuggingPriority(.required, for: .vertical)
            label.setContentCompressionResistancePriority(.required, for: .vertical)
            label.lineBreakMode = .byCharWrapping
            systemContentView.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.top.equalTo(coverImageView.snp.bottom).offset(12)
                make.leading.equalToSuperview().offset(14)
                make.trailing.equalToSuperview().offset(-14)
                make.bottom.lessThanOrEqualToSuperview().offset(-10)
            }
        }
        
        contentLabel.ss.prepare { (label) in
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = UIColor(0x999999FF)
            label.numberOfLines = 0
            label.setContentHuggingPriority(.required, for: .vertical)
            label.setContentCompressionResistancePriority(.required, for: .vertical)
            label.lineBreakMode = .byCharWrapping
            systemContentView.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.leading.equalTo(titleLabel)
                make.trailing.lessThanOrEqualTo(titleLabel)
                make.top.equalTo(titleLabel.snp.bottom).offset(5)
                make.bottom.equalToSuperview().offset(-12)
            }
        }
        
        moreImageView.ss.prepare { (view) in
            view.image = UIImage(named: "icon_msg_more")
            view.isHidden = true
            systemContentView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.leading.equalTo(contentLabel.snp.trailing).offset(-1)
                make.centerY.equalTo(contentLabel)
            }
        }
    }
    
    override func prepare(_ data: MessageDetailInfo) {
        super.prepare(data)
        
        if let imageUrl = data.imageUrl {
            coverImageView.sd_setImage(with: imageUrl, completed: nil)
            coverImageView.snp.remakeConstraints { (make) in
                make.top.trailing.equalToSuperview()
                make.leading.equalToSuperview().offset(ContentView.contentOffset)
                // 16 : 9
                let width = UIScreen.main.bounds.width - (375 - 291) - ContentView.contentOffset
                make.height.equalTo(width * 9.0 / 16).priority(999)
            }
        } else {
            coverImageView.image = nil
            coverImageView.snp.remakeConstraints { (make) in
                make.top.trailing.equalToSuperview()
                make.leading.equalToSuperview().offset(ContentView.contentOffset)
                make.height.equalTo(0.001)
            }
        }
        
        titleLabel.cnText = data.content ?? data.actionText
        moreImageView.isHidden = true
        
        if data.question?.isBlocked ?? false {
            contentLabel.text = data.question?.title
            systemContentView.backgroundColor = .clear
            systemContentView.layer.borderColor = UIColor(0xDDDDDDFF).cgColor
        } else if data.contentType != .system || data.url != nil {
            contentLabel.text = "查看详情"
            moreImageView.isHidden = false
            systemContentView.backgroundColor = .clear
            systemContentView.layer.borderColor = UIColor(0xDDDDDDFF).cgColor
        } else {
            contentLabel.text = nil
            systemContentView.backgroundColor = UIColor(0xF8F8F8FF)
            systemContentView.layer.borderColor = UIColor.clear.cgColor
            parentController?.readMessage(data: data)
        }
        contentLabel.snp.updateConstraints { (make) in
            make.bottom.equalToSuperview().offset(contentLabel.text == nil ? 10 : -12)
        }
        dateLabel.text = DateUtils.formatTimeAgoWith(timestamp: data.createdAt)
    }
}

fileprivate final class ContentView: UIView {
    
    static let contentOffset: CGFloat = 7
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let width: CGFloat = Utils.splitWidth * 0.6
        let color: UIColor = UIColor(0xDDDDDDFF)
        let marginY: CGFloat = 12
        let offset: CGFloat = ContentView.contentOffset
        
        let borderRect = rect.inset(by: UIEdgeInsets(top: width, left: offset, bottom: width, right: width))
        let border = UIBezierPath(roundedRect: borderRect, cornerRadius: 6)
        color.setStroke()
        border.lineWidth = width
        border.stroke()
        
        let context: CGContext = UIGraphicsGetCurrentContext()!
        UIGraphicsPushContext(context)
        
        context.setStrokeColor(color.cgColor)
        context.setFillColor(color.cgColor)
        
        context.setLineWidth(width)
        context.setLineCap(.round)
        context.setLineJoin(.round)

        context.move(to: CGPoint(x: offset, y: marginY))
        context.addLine(to: CGPoint(x: 0, y: marginY + offset * 0.45))
        context.addLine(to: CGPoint(x: offset, y: marginY + offset * 0.9))
        
        context.drawPath(using: .stroke)
        context.strokePath()
        
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(width * 3)
        context.move(to: CGPoint(x: offset, y: marginY))
        context.addLine(to: CGPoint(x: offset, y: marginY + offset * 0.9))
        context.drawPath(using: .stroke)
        context.strokePath()

        UIGraphicsPopContext()
    }
}

fileprivate final class CoverImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.topLeft, .topRight], radius: 6)
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
