//
//  DKVideoCaptureRecordingView.swift
//  DKImagePickerController
//
//  Created by lizhuojie on 2020/1/7.
//

import Foundation

/// 录制动画，由主工程实现
open class DKVideoCaptureRecordingView: UIView {
    
    open var isAnimationPlaying: Bool = false
    
    // 平滑停止动画
    public var isStoping: Bool = false
    
    open func play() {}
    
    open func stop(completion: @escaping (Bool) -> Void) {}
    
    open func pause() {}
}
