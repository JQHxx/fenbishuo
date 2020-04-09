//
//  VideoCaptureRecordingView.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/1/7.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit

import SnapKit
import Lottie
import DKImagePickerController

class VideoCaptureRecordingView: DKVideoCaptureRecordingView {
    
    public var recordingView: AnimationView!
    
    override var isAnimationPlaying: Bool {
        get {
            recordingView.isAnimationPlaying
        }
        set {
            
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
        recordingView = AnimationView(name: "video_recording", animationCache: LRUAnimationCache.sharedCache)
        recordingView.animationSpeed = 1
        setup()
    }
    
    func setup() {
        addSubview(recordingView)
        recordingView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private let heartbeatBegin: AnimationProgressTime = 0.1
    private let heartbeatEnd: AnimationProgressTime = 2.35/3.0
    
    // 0.1心跳开始，2.35心跳结束
    override func play() {
        recordingView.play(fromProgress: 0, toProgress: heartbeatBegin, loopMode: .playOnce) { [weak self] (finished) in
            if let self = self, finished {
                self.recordingView.play(fromProgress: self.heartbeatBegin,
                                        toProgress: self.heartbeatEnd,
                                        loopMode: .loop,
                                        completion: nil)
            }
        }
    }
    
    // 平滑收起动画
    override func stop(completion: @escaping (Bool) -> Void) {
        recordingView.stop()
        completion(true)
//        isStoping = true
//        recordingView.play(fromProgress: heartbeatEnd,
//                           toProgress: 1,
//                           loopMode: .playOnce,
//                           completion: { [weak self] finished in
//                            completion(finished)
//                            self?.isStoping = false
//        })
    }
    
    override func pause() {
        recordingView.pause()
    }
}
