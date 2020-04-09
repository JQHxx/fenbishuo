//
//  DKImageExtensionVideo.swift
//  DKImagePickerController
//
//  Created by lizhuojie on 2020/1/7.
//

import Foundation
import SnapKit

class DKImageExtensionVideo: DKImageBaseExtension {
    
    override class func extensionType() -> DKImageExtensionType {
        return .videoCapture
    }
    
    override func perform(with extraInfo: [AnyHashable : Any]) {
        guard let didFinishCapturingVideo = extraInfo["didFinishCapturingVideo"] as? (URL) -> Void else { return }
        
        let capture = DKVideoCaptureController()
        capture.recordingView = context.imagePickerController.UIDelegate.videoCaptureRecordingView()
        capture.didFinishCapturingVideo = didFinishCapturingVideo
        
        context.imagePickerController.present(capture)
    }
}
