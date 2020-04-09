//
//  UIView+SkeletonView.swift
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/1/15.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import Foundation

extension UIView {
    
    @objc public func ctf_skeletonable(_ able: Bool) {
        self.isSkeletonable = able
    }
    
    @objc public func ctf_showSkeleton() {
        self.showSkeleton(usingColor: UIColor(0xF8F8F8FF))
    }
    
    @objc public func ctf_showGradientSkeleton() {
        self.showGradientSkeleton()
    }
    
    @objc public func ctf_showAnimatedSkeleton() {
        self.showAnimatedSkeleton()
    }
    
    @objc public func ctf_showAnimatedGradientSkeleton() {
        self.showAnimatedGradientSkeleton()
    }
    
    @objc public func ctf_updateSkeleton() {
        self.updateSkeleton()
    }
    
    @objc public func ctf_updateGradientSkeleton() {
        self.updateGradientSkeleton()
    }
    
    @objc public func ctf_updateAnimatedSkeleton() {
        self.updateAnimatedSkeleton()
    }
    
    @objc public func ctf_updateAnimatedGradientSkeleton() {
        self.updateAnimatedGradientSkeleton()
    }
    
    @objc public func ctf_hideSkeleton() {
        self.hideSkeleton()
    }
    
    @objc public func ctf_stopSkeletonAnimation() {
        self.stopSkeletonAnimation()
    }
    
}

