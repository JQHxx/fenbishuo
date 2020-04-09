//
//  UIView+Extensions.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/24.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import UIKit

import Lottie

@objc(CTLottieAnimationType)
public enum LottieAnimationType: Int {
    
    case like
    case voteCare
    case voteStep
    case loading
    case invite_loading
    
    var name: String {
        switch self {
        case .like:
            return "like"
        case .voteCare:
            return "voteCare"
        case .voteStep:
            return "voteStep"
        case .loading:
            return "loading"
        case .invite_loading:
            return "invite_loading"
        }
    }
}

extension UIView {
    
    public var top: CGFloat {
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin.y
        }
    }

    public var left: CGFloat {
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
        get {
            return self.frame.origin.x
        }
    }

    public var right: CGFloat {
        set {
            var frame = self.frame
            frame.origin.x = newValue - frame.size.width
            self.frame = frame
        }
        get {
            return self.frame.origin.x + self.frame.size.width
        }
    }

    public var bottom: CGFloat {
        set {
            var frame = self.frame
            frame.origin.y = newValue - frame.size.height
            self.frame = frame
        }
        get {
            return self.frame.origin.y + self.frame.size.height
        }
    }

    public var height: CGFloat {
        set {
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.width, height: newValue)
        }
        get {
            return self.frame.height
        }
    }

    public var width: CGFloat {
        set {
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: newValue, height: self.frame.height)
        }
        get {
            return self.frame.width
        }
    }

    public var x: CGFloat {
        set {
            self.frame = CGRect(x: newValue, y: self.frame.origin.y, width: self.frame.width, height: self.frame.height)
        }
        get {
            return self.frame.origin.x
        }
    }

    public var y: CGFloat {
        set {
            self.frame = CGRect(x: self.frame.origin.x, y: newValue, width: self.frame.width, height: self.frame.height)
        }
        get {
            return self.frame.origin.y
        }
    }

    public var centerY: CGFloat {
        set {
            self.center = CGPoint(x: self.center.x, y: newValue)
        }
        get {
            return self.center.y
        }
    }

    public var centerX: CGFloat {
        set {
            self.center = CGPoint(x: newValue, y: self.center.y)
        }
        get {
            return self.center.x
        }
    }

    @objc public var viewController: UIViewController? {

        var nextResponder: UIResponder? = self

        repeat {
            nextResponder = nextResponder?.next

            if let viewController = nextResponder as? UIViewController {
                return viewController
            }

        } while nextResponder != nil

        return nil
    }
    
    @objc var isLottiePlaying: Bool {
        for v in subviews {
            if let av = v as? AnimationView {
                return av.isAnimationPlaying
            }
        }
        return false
    }
        
    @objc public func showLottieAnimation(_ type: LottieAnimationType, completion: ((Bool) -> Void)?) {
        let av = AnimationView(name: type.name)
        clipsToBounds = false
        addSubview(av)
        let offset: CGFloat = 150
        av.frame = CGRect(x: width - offset,
                          y: -offset,
                          width: offset + width,
                          height: offset + height)
        av.play { [weak av] (finished) in
            av?.removeFromSuperview()
            completion?(finished)
        }
    }
    
    @objc public func showVoteSuccessedCareAnimation(_ type: LottieAnimationType, completion: ((Bool) -> Void)?)->(AnimationView){
        let av = AnimationView(name: "voteCare")
        av.loopMode = .playOnce
        addSubview(av)
        av.frame = CGRect(x:0, y: 0, width: UIScreen.main.bounds.width - 32 - 40, height: 137)
        av.play { [weak av] (finished) in
            av?.removeFromSuperview()
            completion?(finished)
        }
        return av;
    }
    
    @objc public func showVoteSuccessedStepAnimation(_ type: LottieAnimationType, completion: ((Bool) -> Void)?)->(AnimationView){
        let av = AnimationView(name: "voteStep")
        av.loopMode = .playOnce
        addSubview(av)
        av.frame = CGRect(x:0, y: 0, width: 80, height: 80)
        av.play { [weak av] (finished) in
            av?.removeFromSuperview()
            completion?(finished)
        }
        return av;
    }
    
    @objc public func showLoadingAnimation(_ type: LottieAnimationType, completion: ((Bool) -> Void)?)->(AnimationView){
        let av = AnimationView(name: "loading")
        av.loopMode = .loop
        addSubview(av)
        av.frame = CGRect(x:-25, y: -25, width: 50, height: 50)
        av.play { [weak av] (finished) in
//            av?.play()
            av?.removeFromSuperview()
            completion?(finished)
        }
        return av;
    }
    
    @objc public func stopAnimation(_ animationView: AnimationView){
        if animationView.isAnimationPlaying {
            animationView.stop();
        }
    }
    
    @objc public func showInviteLoadingAnimation(_ type: LottieAnimationType, completion: ((Bool) -> Void)?)->(AnimationView){
        let av = AnimationView(name: "invite_loading")
        av.loopMode = .loop
        addSubview(av)
        av.frame = CGRect(x:100, y: 247, width: 156, height: 133)
        av.play { [weak av] (finished) in
//            av?.play()
            av?.removeFromSuperview()
            completion?(finished)
        }
        return av;
    }
    
}
