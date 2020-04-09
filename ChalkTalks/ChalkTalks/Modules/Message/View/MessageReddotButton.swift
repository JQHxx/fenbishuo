//
//  MessageReddotButton.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/26.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import UIKit

import SnapKit

final class MessageReddotButton: ImageButton {
    
    var reddotInset: UIEdgeInsets = UIEdgeInsets(top: -1, left: 0, bottom: 0, right: -1) {
        didSet {
            reddotView?.snp.remakeConstraints({ (make) in
                make.top.equalToSuperview().offset(reddotInset.top)
                make.trailing.equalToSuperview().offset(-reddotInset.right)
                make.size.equalTo(ReddotView.DotType.normal.size)
            })
        }
    }
    
    var showReddot: Bool {
        set {
            if newValue && reddotView == nil {
                reddotView = ReddotView(.normal).ss.prepare({ (view) in
                    addSubview(view)
                    view.snp.makeConstraints { (make) in
                        make.top.equalToSuperview().offset(reddotInset.top)
                        make.trailing.equalToSuperview().offset(-reddotInset.right)
                        make.size.equalTo(ReddotView.DotType.normal.size)
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
    
    fileprivate var reddotView: UIView?
    
    let type: MessageType
    
    init(_ type: MessageType) {
        self.type = type
        super.init(position: .top, spacing: 10)
        
        setImage(UIImage(named: type.imageName), for: .normal)
        setTitle(type.title, for: .normal)
        setTitleColor(.black, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 12)
        titleLabel?.textAlignment = .center
        titleLabel?.numberOfLines = 1
        titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
