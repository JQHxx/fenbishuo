//
//  CTBlurEffectView.swift
//  ChalkTalks
//
//  Created by vision on 2020/3/31.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit

open class CTBlurEffectView: UIVisualEffectView {

    /// 模糊等级 （0 ~ 1）
   @objc open var blurLevel: Float = 1 {
        didSet {
            self.resumeAnimation()
            
            var blurEffect: UIVisualEffect
            if let effect = self.effect {
                blurEffect = effect
            } else {
                blurEffect = UIBlurEffect(style: .light)
            }
            self.effect = blurEffect
            UIView.animate(withDuration: TimeInterval(1 - blurLevel), delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.effect = nil
            }, completion: nil)
            
            self.pauseAnimation(delay: 0.3)
        }
    }
}

extension UIView {
    
    /// 暂停动画
    fileprivate func pauseAnimation(delay: Double) {
    
        let time = delay + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, time, 0, 0, 0, { timer in
            let layer = self.layer
            let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
            layer.speed = 0
            layer.timeOffset = pausedTime
        })
        
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, CFRunLoopMode.commonModes)
    }
    
    /// 继续动画
    fileprivate func resumeAnimation() {
        let pausedTime  = layer.timeOffset
        
        layer.speed = 1.0
        layer.timeOffset = 0
        layer.beginTime = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
    }
    
}
