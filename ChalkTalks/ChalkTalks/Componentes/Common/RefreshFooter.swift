//
//  RefreshFooter.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/24.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import UIKit

import MJRefresh
import Lottie

@objc(CTRefreshFooter)
class RefreshFooter: MJRefreshAutoNormalFooter {
    
    public var loadingAnimationView: AnimationView = AnimationView(name: "loading", animationCache: LRUAnimationCache.sharedCache)
    
    private let size = CGSize(width: 100, height: MJRefreshFooterHeight)
    
    private var oldInsetB: CGFloat?
    
    @objc
    public init(refreshingBlock: @escaping MJRefreshComponentAction) {

        super.init(frame: CGRect(x: 0, y: 0, width: Utils.screenPortraitWidth, height: size.height))

        self.refreshingBlock = refreshingBlock
        self.height = size.height

        addSubview(loadingAnimationView)

        loadingAnimationView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        loadingAnimationView.center = CGPoint(x: centerX, y: height / 2)
        loadingAnimationView.loopMode = .loop
        
        loadingView?.isHidden = true
        loadingAnimationView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func scrollViewContentSizeDidChange(_ change: [AnyHashable : Any]?) {
        guard let scrollView = scrollView, scrollView.mj_contentH < scrollView.mj_h else {
            ignoredScrollViewContentInsetBottom = 0
            super.scrollViewContentSizeDidChange(change)
            return
        }
        ignoredScrollViewContentInsetBottom = scrollView.mj_h - scrollView.mj_contentH// - mj_h
        super.scrollViewContentSizeDidChange(change)
    }
    
    override func placeSubviews() {
        super.placeSubviews()
        loadingAnimationView.center = CGPoint(x: self.width / 2, y: self.height / 2)
    }
    
//    override func willMove(toSuperview newSuperview: UIView?) {
//        super.willMove(toSuperview: newSuperview)
//    }
    
    override func removeFromSuperview() {
        if let old = oldInsetB {
            scrollView?.mj_insetB = old
        }
        super.removeFromSuperview()
    }
    
    override open var pullingPercent: CGFloat {
        didSet {
            if state == .pulling && !loadingAnimationView.isAnimationPlaying {
                loadingAnimationView.play()
            }
        }
    }
    
    override open var state: MJRefreshState {
        didSet {
            loadingView?.isHidden = true
            switch state {
            case .idle:
                stateLabel?.isHidden = false
                stateLabel?.text = "上拉或点击加载更多"
                loadingAnimationView.isHidden = true
            case .pulling:
                // TODO: 震动反馈
                fallthrough
            case .refreshing:
                stateLabel?.isHidden = true
                loadingAnimationView.isHidden = false
                if !loadingAnimationView.isAnimationPlaying {
                    loadingAnimationView.play()
                }
            case .noMoreData:
                stateLabel?.isHidden = false
                stateLabel?.text = "木有更多啦~"
                oldInsetB = scrollView?.mj_insetB
                scrollView?.mj_insetB = 0
                loadingAnimationView.isHidden = true
                if loadingAnimationView.isAnimationPlaying {
                    loadingAnimationView.stop()
                }
            default:
                stateLabel?.isHidden = true
                loadingAnimationView.isHidden = false
            }
        }
    }
    
    override func endRefreshing() {
        if loadingAnimationView.isAnimationPlaying {
            loadingAnimationView.stop()
        }
        super.endRefreshing()
    }
}
