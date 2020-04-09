//
//  HUD.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/2/6.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit

import MBProgressHUD
import Lottie
import SnapKit

struct HUD {
    
    enum LoadingType {
        case normal, lottie
    }
    
    static func show(to view: UIView, text: String, delay: TimeInterval = 1.2) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .text
        hud.label.text = text
        hud.label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        hud.label.textColor = .white
        hud.bezelView.backgroundColor = .black
        hud.margin = 8
        hud.hide(animated: true, afterDelay: delay)
    }
    
    @discardableResult
    static func show(to view: UIView, loadingType: LoadingType = .normal) -> MBProgressHUD {
        // TODO: add lottie loading
        switch loadingType {
        case .normal:
            return showNormalLoading(to: view)
        case .lottie:
            return showLottieLoading(to: view)
        }
    }
    
    fileprivate static func showNormalLoading(to view: UIView) -> MBProgressHUD {
        UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [MBProgressHUD.self]).color = .white
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.bezelView.backgroundColor = .black
        return hud
    }
    
    fileprivate static func showLottieLoading(to view: UIView) -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        let loadingView = LottieLoadingView()
        
        hud.customView = loadingView
        hud.mode = .customView
        hud.bezelView.backgroundColor = .clear
        
        loadingView.animation.play()
        return hud
    }
    
    static func hide(for view: UIView) {
        MBProgressHUD.hide(for: view, animated: true)
    }
}

fileprivate class LottieLoadingView: BaseView {
    
    let animation = AnimationView(name: "loading", animationCache: LRUAnimationCache.sharedCache)
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 68, height: 68)
    }
    
    override func setup() {
        animation.loopMode = .loop
        addSubview(animation)
        animation.snp.makeConstraints({ $0.edges.equalToSuperview() })
    }
}
