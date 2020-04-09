//
//  PublishPhotoWithAudioViewModel.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/1/21.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import Foundation

import DKImagePickerController

import RxSwift
import RxCocoa
import SDWebImage
import AliyunOSSiOS

class PublishPhotoWithAudioViewModel {
    
    fileprivate(set) var assets: [DKAsset]
    
    fileprivate let assetsLock: NSLock = NSLock()
    
    var id: Int
    var title: String
    
    weak var parent: PublishPhotoWithAudioController?
        
    fileprivate let scheduler: ConcurrentDispatchQueueScheduler
    fileprivate let bag: DisposeBag = DisposeBag()
    
    var contentValidity: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    
    var assetsDidUpload: Bool {
        for asset in assets {
            if asset.uploadState.value != .success {
                return false
            }
        }
        return true
    }
    
    init(_ id: Int, title: String, assets: [DKAsset]) {
        self.id = id
        self.title = title
        self.assets = assets
        
        let queue = DispatchQueue(label: "com.douya.PublishPhotoWithAudioViewModel.upload.queue")
        self.scheduler = ConcurrentDispatchQueueScheduler(queue: queue)
        
        if !assets.isEmpty {
            uploadResourceIfNeed()
            contentValidity.accept(true)
        }
    }
    
    func delete(asset: DKAsset) {
        guard let idx = assets.firstIndex(where: { $0.imagePath.value == asset.imagePath.value }) else { return }
        uploadLock.lock()
        let asset = assets.remove(at: idx)
        uploadLock.unlock()
        parent?.deleteItem(idx)
        contentValidity.accept(!self.assets.isEmpty)
        Logger.debug("remove asset \(idx)")
        (asset.uploadObject as? OSSPutObjectRequest)?.cancel()
        asset.uploadBag = DisposeBag()
        uploadResourceIfNeed()
    }
    
    func add(assets: [DKAsset]) {
        uploadLock.lock()
        self.assets += assets
        uploadLock.unlock()
        contentValidity.accept(!self.assets.isEmpty)
        uploadResourceIfNeed()
        parent?.reloadCollectionView()
    }
    
    // MARK: - Upload
    fileprivate let uploadLock = NSLock()
    
    // 上传并发数
    fileprivate var uploadCount: Int {
        uploadLock.lock(); defer { uploadLock.unlock() }
        return assets.reduce(0,  { $0 + ($1.uploadState.value == .uploading ? 1 : 0) })
    }
    
    // 并发限制
    fileprivate let uploadLimit: Int = 5
    
    // 上传所有音频图片
    func uploadResourceIfNeed() {
        for asset in assets {
            guard asset.uploadState.value == .wait else {
                continue
            }
            
            guard uploadCount < uploadLimit else { return }
            
            uploadAsset(asset)
        }
    }
    
    // 上传单个资源
    func uploadAsset(_ asset: DKAsset) {
        asset.uploadState.accept(.uploading)
        asset.uploadBag = DisposeBag()
        
        var uploadTask: Observable<CGFloat> = getImageToken(asset)
            .flatMap({ [weak asset] info -> Observable<CGFloat> in
                if let asset = asset {
                    return OSSUploader.upload(info: info, asset: asset, isAudio: false).startWith(0)
                    .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                } else {
                    return Observable<CGFloat>.create { (observer) -> Disposable in
                        observer.onCompleted()
                        return Disposables.create()
                    }
                }
            })
        
        if asset.audioPath.value != nil {
            let audioTask: Observable<CGFloat> = getAudioToken(asset)
                .flatMap({ [weak asset] info -> Observable<CGFloat> in
                    if let asset = asset {
                        return OSSUploader.upload(info: info, asset: asset, isAudio: true).startWith(0)
                        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                    } else {
                        return Observable<CGFloat>.create { (observer) -> Disposable in
                            observer.onCompleted()
                            return Disposables.create()
                        }
                    }
                })
            uploadTask = Observable.combineLatest(uploadTask, audioTask) { $0 * 0.5 + $1 * 0.5 }
        }
        
        uploadTask
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak asset] (progress) in
                asset?.uploadProgress.accept(progress)
            }, onError: { [weak self, weak asset] (error) in
                Logger.debug("upload error: \(error)")
                asset?.uploadState.accept(.failure)
                asset?.imageUploadInfo = nil
                asset?.audioUploadInfo = nil
                asset?.uploadBag = DisposeBag()
                self?.uploadResourceIfNeed()
            }, onCompleted: { [weak self, weak asset] in
                Logger.debug("upload success.")
                asset?.uploadState.accept(.success)
                asset?.uploadBag = DisposeBag()
                self?.uploadResourceIfNeed()
            }, onDisposed: {
                Logger.debug("Disposed asset upload task.")
            }).disposed(by: asset.uploadBag)
    }
    
    /// 获取image上传token
    fileprivate func getImageToken(_ asset: DKAsset) -> Observable<OSSUploadInfo> {
        return Observable.create { [weak asset] observer in
            autoreleasepool {
                guard let asset = asset, let imagePath = asset.imagePath.value else {
                    observer.onError(CTError("[Upload Image] 图片路径错误"))
                    return Disposables.create()
                }
                
                var _imageData: Data?
                var _hash: String?
                
                if asset.fromDraft {
                    if let image = UIImage(contentsOfFile: imagePath) {
                        _imageData = SDImageIOCoder.shared.encodedData(with: image, format: .JPEG, options: nil)
                        _hash = OSSUtil.dataMD5String(_imageData)
                    }
                } else {
                    if let image = SDImageCache.shared.imageFromCache(forKey: imagePath) {
                        _imageData = SDImageIOCoder.shared.encodedData(with: image, format: .JPEG, options: nil)
                        _hash = OSSUtil.dataMD5String(_imageData)
                    }
                }
                
                guard let _ = _imageData, let hash = _hash else {
                    observer.onError(CTError("[Upload Image] 图片数据错误"))
                    return Disposables.create()
                }

                let upload = CTFFileApi.checkUploadImage(hash)
                upload.requstApiSuccess({ (data) in
                    guard
                        let json = data as? [String: Any],
                        let info = OSSUploadInfo(json) else {
                            observer.onError(CTError("服务端数据错误"))
                            return
                    }
                    observer.onNext(info)
                    observer.onCompleted()
                }) { (error) in
                    observer.onError(error ?? CTError("未知错误"))
                }
                return Disposables.create()
            }
        }
    }
    
    /// 获取image上传token
    fileprivate func getAudioToken(_ asset: DKAsset) -> Observable<OSSUploadInfo> {
        return Observable.create { [weak asset] observer in
            
            guard
                let audioPath = asset?.audioPath.value,
                let hash = OSSUtil.fileMD5String(audioPath) else {
                    observer.onError(CTError("音频数据错误"))
                    return Disposables.create()
            }
            
            let upload = CTFFileApi.checkUploadAudio(hash)
            upload.requstApiSuccess({ (data) in
                guard
                    let json = data as? [String: Any],
                    let info = OSSUploadInfo(json) else {
                        observer.onError(CTError("服务端数据错误"))
                        return
                }
                observer.onNext(info)
                observer.onCompleted()
            }) { (error) in
                observer.onError(error ?? CTError("未知错误"))
            }
            return Disposables.create()
        }
    }
}
