//
//  PublishViewpointController.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/1/6.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit

import SnapKit

class PublishViewpointController: BaseViewController {
    
    let questionId: Int
    let questionTitle: String
    
    class HeaderView: BaseView {
        
        let titleLabel: UILabel = UILabel()
        
        override func setup() {
            super.setup()
            
            backgroundColor = UIColor(0xF8F8F8FF)
            
            let content: UIView = UIView()
            content.backgroundColor = .white
            addSubview(content)
            content.snp.makeConstraints { (make) in
                make.leading.top.trailing.equalToSuperview()
                make.height.equalTo(54)
            }
            
            addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.leading.greaterThanOrEqualToSuperview().offset(16)
                make.trailing.lessThanOrEqualToSuperview().offset(-16)
            }
            titleLabel.ss.prepare { (label) in
                label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
                label.textColor = UIColor(0x333333FF)
                label.textAlignment = .center
            }
        }
    }
    
    let headerView: HeaderView = HeaderView()
    
    @objc
    init(questionId: Int, questionTitle: String) {
        self.questionId = questionId
        self.questionTitle = questionTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareUI() {
        super.prepareUI()
        
        contentView.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(68)
        }
    }
}
