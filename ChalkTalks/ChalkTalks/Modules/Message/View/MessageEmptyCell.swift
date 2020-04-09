//
//  MessageEmptyCell.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/23.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import UIKit

import RxSwift

final class MessageEmptyCell: BaseTableViewCell {
    
    static let height = Utils.screenPortraitHeight - Utils.navbarHeight - MessageHeaderView.height -  Utils.tabbarHeight
    
    override func setup() {
        super.setup()
        
        let emptyImageView = UIImageView(image: UIImage(named: "empty_NoMessage_120x120"))
        let contentLabel = UILabel().ss.prepare { (label) in
            label.font = UIFont.systemFont(ofSize: 15)
            label.textColor = UIColor(0x999999FF)
            label.numberOfLines = 0;
            let paraph = NSMutableParagraphStyle()
            paraph.lineSpacing = 4
            paraph.alignment = NSTextAlignment.center
            let attributes = [NSAttributedString.Key.paragraphStyle: paraph]
            label.attributedText = NSAttributedString(string: "暂无该类通知\n近期没有收到该类通知消息", attributes: attributes)
            
            
        }
        
        let stackView = UIStackView(arrangedSubviews: [emptyImageView, contentLabel])
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 22
        
        addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.8)
        }
    }
}
