//
//  NavigationBar.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/21.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import UIKit

import SnapKit

public class NavigationBar: UINavigationBar {
    
    /// 分割线
    public let line: UIView = UIView()
    
    public var supportLandscape = false
    
    public var showLine: Bool = true {
        didSet {
            line.isHidden = !showLine
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    public var isTranslucentBackground: Bool = false {
        didSet {
            updateBackgroundImage()
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setup() {
        isTranslucent = true
        shadowImage = UIImage()
        
        addSubview(line)
        line.ss.prepare { view in
            view.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
                make.height.equalTo(Utils.splitWidth)
            }
            
            view.backgroundColor = UIColor(0xF8F8F8FF)
        }
    }
    
    public func updateBackgroundImage() {
        if isTranslucentBackground {
            backgroundColor = nil
            setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: .default)
            shadowImage = UIImage()
            line.isHidden = true
        } else {
            backgroundColor = .white
            setBackgroundImage(UIImage(), for: UIBarPosition.any, barMetrics: .default)
            shadowImage = UIImage()
            line.isHidden = !showLine
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let isLandscape = Device.isLandscape() && supportLandscape
        let iphoneX = Utils.DeviceType.isPhoneX && !isLandscape
        
        for view in subviews {
            let className = view.ss.className
            if className == "_UIBarBackground" {
                var frame = bounds
                frame.origin.y = iphoneX ? 24 : 0
                frame.size.height -= frame.origin.y
                view.frame = frame
            }
            
            if #available(iOS 11, *) {
                if className == "_UINavigationBarContentView" {
                    var frame = view.frame
                    if isLandscape {
                        frame.origin.y = (frame.height - frame.height) / 2.0
                    } else {
                        frame.origin.y = iphoneX ? 44 : 20
                    }
                    view.frame = frame
                    
                    if #available(iOS 13.0, *) {
                        // crash
                    } else {
                        view.layoutMargins = UIEdgeInsets(top: view.layoutMargins.top,
                                                          left: 8,
                                                          bottom: view.layoutMargins.bottom,
                                                          right: 8)
                    }
                }
            } else if isLandscape && ["UIButton", "UINavigationItemView"].contains(className) {
                // 横屏NavigationBar位置调整
                var _center = view.center
                _center.y = center.y
                view.center = _center
            }
            
            if className == "_UIBarBackground" {
                for v in view.subviews {
                    if v.ss.className == "UIVisualEffectView" {
                        v.isHidden = true
                    }
                }
            }
            
            if className == "_UINavigationBarBackground" {
                for v in view.subviews {
                    if v.ss.className == "_UIBackdropView" {
                        v.isHidden = true
                    }
                    if v.bounds.height < 1 && v.bounds.height > 0 {
                        v.isHidden = true
                    }
                }
            }
        }
        
        if layer.shadowRadius > 0 {
            layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        }
    }
}
