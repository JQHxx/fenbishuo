//
//  DKAssetGroupDetailCameraCell.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 07/12/2016.
//  Copyright © 2016 ZhangAo. All rights reserved.
//

import UIKit

@objcMembers
public class DKAssetGroupDetailCameraCell: DKAssetGroupDetailBaseCell {
    
    public class override func cellReuseIdentifier() -> String {
        return "DKImageCameraIdentifier"
    }
    
    private let cameraImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cameraImageView.frame = bounds
        cameraImageView.contentMode = .center
        cameraImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.contentView.addSubview(cameraImageView)
        
        self.contentView.backgroundColor = .black// UIColor(white: 0.9, alpha: 1.0)
        self.contentView.accessibilityIdentifier = "DKImageCameraAccessibilityIdentifier"
        self.contentView.isAccessibilityElement = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var imagePickerController: DKImagePickerController? {
        didSet {
            guard let ipc = imagePickerController else { return }
            if ipc.assetType == .allVideos {
                cameraImageView.image = DKImagePickerControllerResource.videoCameraIcon()
            } else {
                cameraImageView.image = DKImagePickerControllerResource.cameraImage()
            }
        }
    }
    
} /* DKAssetGroupDetailCameraCell */
