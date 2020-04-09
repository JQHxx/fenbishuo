//
//  PublishVideoViewpointController.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/1/6.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit
import Photos

import RxSwift
import RxCocoa

import DKImagePickerController

@objc(CTPublishVideoViewpointController)
final class PublishVideoViewpointController: PublishViewpointController {
    
    override func setup() {
        super.setup()
        
        navItem.title = "发布观点"
        showBackButton = true
    }
    
    override func prepareUI() {
        super.prepareUI()
        
        headerView.titleLabel.text = questionTitle
        
        let addVideo = UIButton(type: .custom)
        addVideo.setTitle("选择视频", for: .normal)
        addVideo.setTitleColor(.blue, for: .normal)
        addVideo.rx
            .tap
            .subscribe(onNext: { [weak self] (_) in
                self?.showVideoPicker()
            }).disposed(by: disposeBag)
        contentView.addSubview(addVideo)
        addVideo.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    fileprivate func showVideoPicker() {
        let imagePicker = ImagePickerController { [weak self] (videoPath, asset) in
            if let path = videoPath {
                // 新拍摄视频路径，需上传后写入相册
                Logger.debug("show video path \(path).")
                self?.videoPath = path
                self?.saveToPhotoLibraryIfNeed()
            } else if let asset = asset {
                // 从相册选取视频资源，DKAsset实例
                Logger.debug("show video asset \(asset).")
            }
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    fileprivate func getUrl(from asset: DKAsset, completion: @escaping (URL?) -> Void) {
        asset.fetchAVAsset { (avAsset, info) in
            if let urlAsset = avAsset as? AVURLAsset {
                Logger.debug("相册视频路径 \(urlAsset.url)")
                completion(urlAsset.url)
            } else {
                completion(nil)
            }
        }
    }
    
    fileprivate var videoPath: URL?
    
    fileprivate func saveToPhotoLibraryIfNeed() {
        guard let url = videoPath else { return }
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { (success, error) in
            if let error = error {
                Logger.debug("录制视频写入相册失败: \(error)")
            }
        }
    }
}
