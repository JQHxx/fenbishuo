//
//  PhotoWithAudioGalleryContentController.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/1/30.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import DKImagePickerController
import DKPhotoGallery

import SnapKit

class PhotoWithAudioGalleryContentController: DKPhotoGalleryContentVC {
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
