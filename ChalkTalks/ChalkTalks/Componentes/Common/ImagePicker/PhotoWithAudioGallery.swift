//
//  PhotoWithAudioGallery.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/1/30.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit

import DKImagePickerController
import DKPhotoGallery

import SDWebImage
import SnapKit

/// 自定义DKPhotoGallery
class PhotoWithAudioGallery: DKPhotoGallery {
    
    fileprivate var assets: [DKAsset] = []
    
    fileprivate let backButton = BaseButton(type: .custom)
    fileprivate let indexLabel = UILabel()
    
    fileprivate let playerView = PhotoWithAudioGalleryPlayerView()
    
    convenience init(_ assets: [DKAsset]) {
        self.init()
        self.assets = assets
        
        var items: [DKPhotoGalleryItem] = []
        for asset in assets {
            guard let path = asset.imagePath.value else { continue }
            var _image: UIImage?
            if asset.fromDraft {
                _image = UIImage(contentsOfFile: path)
            } else {
                _image = SDImageCache.shared.imageFromCache(forKey: path)
            }
            guard let image = _image else { return }
            let item = DKPhotoGalleryItem(image: image)
            item.audioAsset = asset
            items.append(item)
        }
        
        self.singleTapMode = .toggleControlView
        self.galleryDelegate = self
        self.items = items
        self.isPhotoWithAudio = true
    }
    
    override func viewDidLoad() {
        
        // 替换contentVC，减少对DKPhotoGallery的侵入式修改，不能直接赋值，contentVC为weak
        let newContentVC = PhotoWithAudioGalleryContentController()
        contentVC = newContentVC
        
        super.viewDidLoad()
        
        guard let contentView = contentVC?.view else { return }
        
        backButton.ss.prepare { (button) in
            button.setImage(UIImage(named: "nav_back_white"), for: .normal)
            button.hitTestInset = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
            button.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
            contentView.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().offset(16)
                make.top.equalToSuperview().offset(12 + Utils.statusBarHeight)
            }
        }
        
        indexLabel.ss.prepare { (label) in
            label.textColor = .white
            label.font = UIFont.boldSystemFont(ofSize: 17)
            label.text = "\(presentationIndex)/\(items?.count ?? 0)"
            contentView.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalTo(backButton)
            }
        }
        
        playerView.ss.prepare { (view) in
            contentView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-69 - Utils.bottomHeight)
            }
            
            let safeItems = items ?? []
            if presentationIndex < safeItems.count {
                view.prepare(item: safeItems[presentationIndex])
            }
        }
        
        isNavigationBarHidden = true
        statusBar?.alpha = 0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        playerView.removeAudioPlayer()
    }
    
    @objc func backAction(_ btn: BaseButton) {
        dismissGallery()
    }
    
    override func updateNavigation() {
        guard let items = items else { return }
        indexLabel.text = "\(contentVC!.currentIndex + 1)/\(items.count)"
        playerView.prepare(item: items[contentVC!.currentIndex])
    }
    
    @objc override func handleSingleTap() {
        // 禁用单点事件
    }
    
    override func updateContextBackground(alpha: CGFloat, animated: Bool) {
        super.updateContextBackground(alpha: alpha, animated: animated)
        backButton.alpha = alpha / 2
        indexLabel.alpha = alpha / 2
        playerView.alpha = alpha / 2
    }
}

extension PhotoWithAudioGallery: DKPhotoGalleryDelegate {
    
}
