//
//  MessageAvatarButton.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/3/10.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit

import SnapKit
import SDWebImage

final class MessageAvatarButton: UIButton {
    
    var showMultiAvatar: Bool = true
    
    var firstAvatar: UIImageView?
    var secondAvatar: UIImageView?
    
    var avatarSize: CGSize = CGSize(width: 26, height: 26)
    
    var isSystemMessage: Bool = false
    
    private var placeholderName: String {
        return isSystemMessage ? "avatar_placeholder" : "placeholder_head_40x40"
    }
    
    func resetToNormal() {
        firstAvatar?.isHidden = true
        secondAvatar?.isHidden = true
        clipsToBounds = true
        layer.borderWidth = 0.5
    }
    
    /// 多个头像合并显示
    func updateAvatars(_ actors: [MessageDetailInfo.Actor]) {
        guard actors.count > 1, showMultiAvatar else {
            resetToNormal()
            sd_setImage(with: URL(string: actors.first?.avatarUrl ?? ""),
                        for: .normal,
                        placeholderImage: UIImage(named: placeholderName),
                        completed: nil)
            backgroundColor = UIColor(0xF8F8F8FF)
            return
        }
        
        clipsToBounds = false
        layer.borderWidth = 0
        backgroundColor = .clear
        
        if firstAvatar == nil {
            firstAvatar = UIImageView().ss.prepare { (view) in
                addSubview(view)
                view.clipsToBounds = true
                view.layer.cornerRadius = avatarSize.width / 2
                view.layer.borderWidth = 0.5
                view.layer.borderColor = UIColor(0xCCCCCCFF).cgColor
                view.snp.makeConstraints { (make) in
                    make.leading.top.equalToSuperview()
                    make.size.equalTo(avatarSize)
                }
            }
        }
        
        if secondAvatar == nil {
            secondAvatar = UIImageView().ss.prepare { (view) in
                addSubview(view)
                view.clipsToBounds = true
                view.layer.cornerRadius = avatarSize.width / 2
                view.layer.borderWidth = 0.5
                view.layer.borderColor = UIColor(0xCCCCCCFF).cgColor
                view.snp.makeConstraints { (make) in
                    make.trailing.bottom.equalToSuperview()
                    make.size.equalTo(avatarSize)
                }
            }
        }
        
        firstAvatar?.isHidden = false
        secondAvatar?.isHidden = false
        
        let ap = UIImage(named: placeholderName)
        sd_setImage(with: nil, for: .normal, completed: nil)
        firstAvatar?.sd_setImage(with: URL(string: actors[0].avatarUrl ?? ""), placeholderImage: ap)
        secondAvatar?.sd_setImage(with: URL(string: actors[1].avatarUrl ?? ""), placeholderImage: ap)
    }
}
