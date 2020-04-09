//
//  DKAudioEditorTransitionController.swift
//  DKImagePickerController
//
//  Created by lizhuojie on 2020/1/17.
//

import UIKit

class DKAudioEditorTransitionController: UIPresentationController, UIViewControllerTransitioningDelegate {
    
    var editorVC: DKPhotoWithAudioEditor!
    
    init(editorVC: DKPhotoWithAudioEditor, presentedViewController: UIViewController, presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.editorVC = editorVC
    }
    
    // TODO: 手势操作
    func prepareInteractiveGesture() {}
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let presentAnimator = DKAudioEditorTransition()
        presentAnimator.editorVC = editorVC
        presentAnimator.isPresenting = true
        return presentAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let dismissAnimator = DKAudioEditorTransition()
        dismissAnimator.editorVC = editorVC
        dismissAnimator.isPresenting = false
        return dismissAnimator
    }
}

// MARK: - DKAudioEditorTransitionPresent

fileprivate class DKAudioEditorTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var editorVC: DKPhotoWithAudioEditor!
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

        presentView.frame = onScreenFrame
        presentView.alpha = isPresenting ? 0 : 1

        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0.0,
            options: [.allowUserInteraction, .beginFromCurrentState, .curveEaseInOut],
            animations: {
                presentView.alpha = self.isPresenting ? 1 : 0
//                presentView.frame = finalFrame
        }) { (finished) in
            if !self.isPresenting && !transitionContext.transitionWasCancelled {
                fromView.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
