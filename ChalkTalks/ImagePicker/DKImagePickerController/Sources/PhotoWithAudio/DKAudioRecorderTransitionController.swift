//
//  DKAudioRecorderTransitionController.swift
//  DKImagePickerController
//
//  Created by lizhuojie on 2020/1/15.
//

import UIKit

class DKAudioRecorderTransitionController: UIPresentationController, UIViewControllerTransitioningDelegate {
    
    var recorderVC: DKPhotoWithAudioRecorder!
    
    init(recorderVC: DKPhotoWithAudioRecorder, presentedViewController: UIViewController, presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.recorderVC = recorderVC
    }
    
    // TODO: 手势操作
    func prepareInteractiveGesture() {}
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let presentAnimator = DKAudioRecorderTransition()
        presentAnimator.recorderVC = recorderVC
        presentAnimator.isPresenting = true
        return presentAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let dismissAnimator = DKAudioRecorderTransition()
        dismissAnimator.recorderVC = recorderVC
        dismissAnimator.isPresenting = false
        return dismissAnimator
    }
}

// MARK: - DKAudioRecorderTransitionPresent

fileprivate class DKAudioRecorderTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var recorderVC: DKPhotoWithAudioRecorder!
    var isPresenting: Bool = true
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromView = fromVC.view,
            let toView = toVC.view else {

                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                return
        }
        
        if self.isPresenting {
            transitionContext.containerView.addSubview(toView)
        }

        let presentVC = isPresenting ? toVC : fromVC
        let presentView = isPresenting ? toView : fromView

        let onScreenFrame: CGRect = transitionContext.finalFrame(for: presentVC)
        let offScreenFrame: CGRect = onScreenFrame.offsetBy(dx: 0, dy: onScreenFrame.size.height)

        let initialFrame: CGRect = isPresenting ? offScreenFrame : onScreenFrame
        let finalFrame: CGRect = isPresenting ? onScreenFrame : offScreenFrame

        presentView.frame = initialFrame
        
        let fromColor: CGFloat = isPresenting ? 0 : 0.5
        let toColor: CGFloat = isPresenting ? 0.5 : 0
        transitionContext.containerView.backgroundColor = UIColor.black.withAlphaComponent(fromColor)
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0.0,
            options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseInOut],
            animations: {
                presentView.frame = finalFrame
                transitionContext.containerView.backgroundColor = UIColor.black.withAlphaComponent(toColor)
        }) { (finished) in
            if !self.isPresenting && !transitionContext.transitionWasCancelled {
                fromView.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
