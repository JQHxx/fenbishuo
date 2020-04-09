//
//  CTAnimationView.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/1/14.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit

import Lottie

@objc
enum CTAnimationMode: Int {
    
    case playOnce, loop, autoReverse
    
    var lottie: LottieLoopMode {
        switch self {
        case .playOnce:
            return .playOnce
        case .loop:
            return .loop
        case .autoReverse:
            return .autoReverse
        }
    }
}

@objc
open class CTAnimationView: BaseView {
    
    let animationView: AnimationView
    
    @objc var animationMode: CTAnimationMode = .playOnce {
        didSet {
            animationView.loopMode = animationMode.lottie
        }
    }
    
    @objc var speed: CGFloat = 1 {
        didSet {
            animationView.animationSpeed = speed
        }
    }
    
    @objc public init(name: String) {
        self.animationView = AnimationView(name: name, animationCache: LRUAnimationCache.sharedCache)
        super.init(frame: .zero)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func setup() {
        super.setup()
        
        addSubview(animationView)
        animationView.loopMode = animationMode.lottie
        animationView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func play() {
        animationView.play()
    }
    
    @objc func stop() {
        animationView.stop()
    }
    
    @objc func pause() {
        animationView.pause()
    }
}
