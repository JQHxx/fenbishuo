//
//  ImagePickerController.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/24.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import UIKit

import DKImagePickerController
import RxSwift

@objc(CTImagePickerType)
enum ImagePickerType: Int {
    case photo, video, pwa // photo with audio
}

@objc(CTImagePickerController)
final class ImagePickerController: DKImagePickerController {
    
    var type: ImagePickerType = .photo
        
    /// 支持跳过选项
    @objc var supportSkip: Bool = false
    
    let disposeBag: DisposeBag = DisposeBag()
    
    @objc var needShowPhotoEdit: Bool {
        set {
            showPhotoEditWhenDone = newValue
        }
        get {
            showPhotoEditWhenDone
        }
    }
    
    fileprivate func normalSetup() {
        UIDelegate = ImagePickerControllerUIDelegate()
        modalPresentationStyle = .fullScreen
        showsCancelButton = true
    }
    
    /// 选取视频
    /// - Parameter didSelectVideo: fileUrl: 拍摄视频路径，asset: 从相册选取视频对象
    @objc convenience init(didSelectVideo: @escaping (_ filePath: URL?, _ asset: DKAsset?) -> Void) {
        self.init()
        
        self.didSelectVideo = { url in
            didSelectVideo(url, nil)
        }
        
        type = .video
        assetType = .allVideos
        
        didSelectAssets = { assets in
            guard let videoAsset = assets.first else { return }
            didSelectVideo(nil, videoAsset)
        }
        
        maxSelectableCount = 1
        normalSetup()
    }
    
    /// 选取图片（发布图文）
    /// - Parameters:
    ///   - selectedCount: 已选取数量
    ///   - didSelectImages: 选取回调
    @objc convenience init(selectedCount: Int, didSelectImages: @escaping ([UIImage]) -> Void) {
        self.init()
        
        type = .photo
        assetType = .allPhotos
        
        didSelectAssets = { [weak self] assets in
            guard let self = self else { return }
            
            if assets.isEmpty {
                didSelectImages([])
                return
            }
            
            // 由于原图可能储存在iCloud，本地只有缩略图，需要异步获取
            var tasks: [Observable<UIImage?>] = []
            for asset in assets {
                tasks.append(self.fetchImage(asset))
            }
            
            var hud: MBProgressHUD?
            if let view = Utils.topVC?.view {
                hud = HUD.show(to: view)
            }
            _ = Observable
                .zip(tasks)
                .take(tasks.count)
                .subscribe(onNext: { (images) in
                    didSelectImages(images.compactMap { $0 })
                    hud?.hide(animated: true)
                })
        }
        maxSelectableCount = 9 - selectedCount
        
        normalSetup()
    }
    
    /// 选取图片（发布图片+语音）
    /// - Parameters:
    ///   - selectedAssets: 已选取资源
    ///   - didSelectAssets: 选取回调
    @objc convenience init(selectedAssets: [DKAsset], didSelectAssets: @escaping ([DKAsset]) -> Void) {
        self.init()
        
        self.didSelectAssets = didSelectAssets
        
        type = .pwa
        needShowPhotoWithAudioEdit = true
        assetType = .allPhotos
        // 滑动选取，存在bug：内存泄露，页面便宜
//        allowSwipeToSelect = true
        
        maxSelectableCount = 50 - selectedAssets.count
        normalSetup()
    }
    
    func fetchImage(_ asset: DKAsset) -> Observable<UIImage?> {
        return Observable.create { observer in
            asset.fetchOriginalImage { (image, _) in
                observer.onNext(image)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
