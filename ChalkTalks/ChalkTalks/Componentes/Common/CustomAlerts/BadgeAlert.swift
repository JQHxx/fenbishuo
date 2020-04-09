//
//  BadgeAlert.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/3/23.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit

import SnapKit
import SwiftEntryKit

// MARK: - Type

enum BadgeType: Int {
    /// 粉笔说常客
    case changeke = 1
    /// 小有收获
    case shouhuo
    /// 靠谱星人
    case kaopu
    /// 呼朋唤友
    case hupeng
    /// 爱互动
    case hudong
    
    private var imageName: String {
        switch self {
        case .changeke:
            return "changeke"
        case .shouhuo:
            return "shouhuo"
        case .kaopu:
            return "kaopu"
        case .hupeng:
            return "hupeng"
        case .hudong:
            return "hudong"
        }
    }
    
    var title: String {
        switch self {
        case .changeke:
            return "粉笔说常客"
        case .shouhuo:
            return "小有收获"
        case .kaopu:
            return "靠谱星人"
        case .hupeng:
            return "呼朋唤友"
        case .hudong:
            return "爱互动"
        }
    }
    
    func imageName(_ level: Int) -> String {
        return "badge_" + imageName + "_\(level)_light"
    }
}

// MARK: - Alert

class BadgeAlert {
    
    static func show(_ type: BadgeType, level: Int) {
        if SwiftEntryKit.isCurrentlyDisplaying(entryNamed: "BadgeAlert") {
            return
        }
        
        let width: CGFloat = min(Utils.screenPortraitWidth - 70, 400)
        let height: CGFloat = width * 5.0 / 3.0

        let badgeView = BadgeView(type: type, level: level).ss.prepare { (view) in
            view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        }

        var attributes = EKAttributes()
        attributes.name = "BadgeAlert"
        attributes.position = .center
        attributes.displayDuration = .infinity
        
        attributes.positionConstraints.size = .init(width: .offset(value: 35), height: .constant(value: height))
        attributes.positionConstraints.maxSize = .init(width: .constant(value: Utils.screenPortraitWidth),
                                                       height: .constant(value: Utils.screenPortraitHeight))

        attributes.screenBackground = .color(color: .init(UIColor.black.withAlphaComponent(0.618)))
//        attributes.entranceAnimation
        attributes.popBehavior = .overridden
        
        attributes.entryInteraction = .absorbTouches
        attributes.screenInteraction = .absorbTouches

        SwiftEntryKit.display(entry: badgeView, using: attributes, presentInsideKeyWindow: true)
    }
}

// MAKR: - View

fileprivate class BadgeView: BaseView {
    
    let type: BadgeType
    let level: Int
    
    let contentView = UIView()
    
    let backgroudView = UIImageView()
    
    let imageView = UIImageView()
    let contentLabel = UILabel()
    let titleLabel = UILabel()
    let actionButton = ActionButton()
    
    let closeButton = BaseButton()
    
    init(type: BadgeType, level: Int) {
        self.type = type
        self.level = level
        super.init(frame: .zero)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
                
        backgroundColor = .clear
        
        contentView.ss.prepare { (view) in
            view.backgroundColor = .white
            view.layer.cornerRadius = 12
            addSubview(view)
            view.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                make.centerY.equalToSuperview()//.offset(26)
                make.height.equalTo(snp.width).multipliedBy(7.0/8.0)
            }
        }
        
        backgroudView.ss.prepare { (view) in
            view.image = UIImage(named: "badge_alert_backgroud")
            contentView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.leading.top.trailing.equalToSuperview()
                make.height.equalTo(91)
//                make.height.equalTo(contentView.snp.width).multipliedBy(128.0 / 304)
            }
        }
        
        imageView.ss.prepare { (view) in
            view.image = UIImage(named: type.imageName(level))
            addSubview(view)
            view.snp.makeConstraints { (make) in
                make.centerY.equalTo(contentView.snp.top)
                make.centerX.equalToSuperview()
            }
        }
        
        actionButton.ss.prepare { (view) in
            view.setTitle("查看徽章", for: .normal)
            view.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            view.setTitleColor(.white, for: .normal)
            view.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            view.gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
            view.gradientLayer.locations = [0.05, 0.95]
            view.gradientLayer.colors = [UIColor(0xFF6885FF).cgColor, UIColor(0xF9384AFF).cgColor]
            view.addTarget(self, action: #selector(action(_:)), for: .touchUpInside)
            addSubview(view)
            view.layer.cornerRadius = 21
            view.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(contentView.snp.bottom).offset(-15)
                make.size.equalTo(CGSize(width: 220, height: 42))
            }
        }
        
        titleLabel.ss.prepare { (view) in
            let textColor = UIColor(0xFF6885FF)
            let titleText = NSAttributedString(
                string: "\(type.title)",
                attributes: [
                    .foregroundColor: textColor,
                    .font: UIFont.boldSystemFont(ofSize: 30),
                    .baselineOffset: 0
            ])
            let lvText = NSAttributedString(
                string: "·LV\(level)",
                attributes: [
                    .foregroundColor: textColor,
                    .font: UIFont.boldSystemFont(ofSize: 24),
                    .baselineOffset: 0
            ])
            
            let fullText = NSMutableAttributedString()
            fullText.append(titleText)
            fullText.append(lvText)
            view.attributedText = fullText
           
            contentView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.bottom.lessThanOrEqualTo(actionButton.snp.top).offset(-28)
            }
        }
        
        contentLabel.ss.prepare { (view) in
            view.text = "恭喜你获得徽章"
            view.textColor = UIColor(0x999999FF)
            view.font = UIFont.systemFont(ofSize: 16)
            contentView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalTo(titleLabel.snp.top).offset(-10)
            }
        }
        
        closeButton.ss.prepare { (view) in
            view.setImage(UIImage(named: "badge_close"), for: .normal)
            view.hitTestInset = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
            view.addTarget(self, action: #selector(close(_:)), for: .touchUpInside)
            addSubview(view)
            view.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(contentView.snp.bottom).offset(21)
            }
        }
    }
    
    @objc func action(_ btn: ActionButton) {
        SwiftEntryKit.dismiss(.all) {
            guard UserCache.isUserLogined() != .notLogin else { return }
            let vc = BadgeWebViewController(userId: UserCache.getCurrentUserID())
            Utils.topVC?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func close(_ btn: BaseButton) {
        SwiftEntryKit.dismiss()
    }
}

fileprivate class ActionButton: BaseButton {
    
    override class var layerClass: AnyClass { CAGradientLayer.self }
    
    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }
}
