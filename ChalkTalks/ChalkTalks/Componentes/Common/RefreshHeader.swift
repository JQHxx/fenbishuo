//
//  RefreshHeader.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/24.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import UIKit

import MJRefresh
import Lottie

@objc(CTRefreshHeader)
class RefreshHeader: MJRefreshHeader {
    
    public var loadingView: AnimationView = AnimationView(name: "loading", animationCache: LRUAnimationCache.sharedCache)
    
    private let size = CGSize(width: 100, height: MJRefreshHeaderHeight)
    
    @objc
    public init(refreshingBlock: @escaping MJRefreshComponentAction) {

        super.init(frame: CGRect(x: 0, y: 0, width: Utils.screenPortraitWidth, height: size.height))

        self.refreshingBlock = refreshingBlock
        self.height = size.height

        addSubview(loadingView)

        loadingView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        loadingView.center = CGPoint(x: centerX, y: height / 2)
        loadingView.loopMode = .loop
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        mj_h = size.height
        isAutomaticallyChangeAlpha = false
        backgroundColor = .clear
        setValue(UIEdgeInsets.zero, forKey: "scrollViewOriginalInset")
    }
    
    override func placeSubviews() {
        super.placeSubviews()
        loadingView.center = CGPoint(x: self.width / 2, y: self.height / 2)
    }
    
    override open var pullingPercent: CGFloat {
        didSet {
            if scrollView?.contentOffset != .zero && !loadingView.isAnimationPlaying {
                loadingView.play()
            }
        }
    }
    
    override func endRefreshing() {
        if loadingView.isAnimationPlaying {
            loadingView.stop()
        }
        super.endRefreshing()
    }
    
    override func beginRefreshing() {
        if !loadingView.isAnimationPlaying {
            loadingView.play()
        }
        super.beginRefreshing()
    }
}
