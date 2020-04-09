//
//  DKPhotoWithAudioEditor.swift
//  DKImagePickerController
//
//  Created by lizhuojie on 2020/1/14.
//

import UIKit
import AVFoundation

import CropViewController
import SnapKit
import RxSwift
import RxCocoa
import MBProgressHUD
import SDWebImage

/// 图片+音频 编辑
open class DKPhotoWithAudioEditor: UIViewController {
    
    weak var ipc: DKImagePickerController?
    
    var transitionController: DKAudioEditorTransitionController?
    
    fileprivate lazy var indexView: UICollectionView = {
        let layout = DKPhotoWithAudioIndexLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(DKPhotoWithAudioIndexCell.self, forCellWithReuseIdentifier: DKPhotoWithAudioIndexCell.reuseIdentifier)
        cv.register(DKPhotoWithAudioAddCell.self, forCellWithReuseIdentifier: DKPhotoWithAudioAddCell.reuseIdentifier)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    fileprivate lazy var contentView: UICollectionView = {
        let layout = DKPhotoWithAudioContentLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(DKPhotoWithAudioContentCell.self, forCellWithReuseIdentifier: DKPhotoWithAudioContentCell.reuseIdentifier)
        cv.backgroundColor = .clear
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    fileprivate let bottomView: DKPhotoWithAudioEditorBottomView = DKPhotoWithAudioEditorBottomView()
    
    fileprivate var assets: [DKAsset] = []
    
    fileprivate let currentIndex: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 0)
    
    fileprivate let bag: DisposeBag = DisposeBag()
    
    convenience init(assets: [DKAsset]) {
        self.init(nibName: nil, bundle: nil)
        
        self.assets = assets
        self.modalPresentationStyle = .fullScreen
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        prepareRx()
        showAddGuideIfNeed()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        indexView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .left)
    }
    
    fileprivate let countLabel = UILabel()
    
    private func prepareUI() {
        view.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1)

        var statusBarHeight: CGFloat = max(DKUtils.statusBarHeight, 20)
        var bottomSafaOffset: CGFloat = DKUtils.safaAreaBottom
        let indexHeight: CGFloat = UIScreen.main.bounds.width * 88 / 375.0
        let navBarHeight: CGFloat = 44
        let topHeight: CGFloat = statusBarHeight + indexHeight + navBarHeight
        let topContentView = UIView()
        topContentView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        view.addSubview(topContentView)
        topContentView.snp.makeConstraints { (make) in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(topHeight)
        }
        
        // navbar: cancelBtn nextBtn countLabel
        
        let navBarView = UIView()
        navBarView.backgroundColor = .clear
        topContentView.addSubview(navBarView)
        navBarView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(statusBarHeight)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(navBarHeight)
        }
        
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(.white, for: .normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelBtn.addTarget(self, action: #selector(cancelAction(_:)), for: .touchUpInside)
        navBarView.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 38, height: 38))
        }
        
        let nextBtn = UIButton(type: .custom)
        nextBtn.setTitle("下一步", for: .normal)
        nextBtn.setTitleColor(.white, for: .normal)
        nextBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        nextBtn.backgroundColor = UIColor(red: 1, green: 0.41, blue: 0.52, alpha: 1)
        nextBtn.clipsToBounds = true
        nextBtn.layer.cornerRadius = 16
        nextBtn.addTarget(self, action: #selector(nextAction(_:)), for: .touchUpInside)
        navBarView.addSubview(nextBtn)
        nextBtn.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 82, height: 32))
        }
        
        countLabel.font = UIFont.boldSystemFont(ofSize: 17)
        countLabel.textColor = .white
        countLabel.textAlignment = .center
        navBarView.addSubview(countLabel)
        countLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        updateCountLabel()
        
        topContentView.addSubview(indexView)
        indexView.snp.makeConstraints { (make) in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(indexHeight)
        }
        
        view.addSubview(contentView)
        let width: CGFloat = UIScreen.main.bounds.width - 32
        let height: CGFloat = width * 4 / 3.5
        contentView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(topContentView.snp.bottom).offset(10)
            make.height.equalTo(height)
        }
        
        view.addSubview(bottomView)
        bottomView.audioEditor = self
        bottomView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-DKUtils.safaAreaBottom)
            make.top.equalTo(contentView.snp.bottom)
        }
        bottomView.update(with: self.assets[currentIndex.value])
    }
    
    fileprivate func prepareRx() {
        currentIndex
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (index) in
                guard let self = self else { return }
                for cell in self.indexView.visibleCells {
                    guard let ic = cell as? DKPhotoWithAudioIndexCell else { continue }
                    ic.showBorder = false
                }
                if let cell = self.indexView.cellForItem(at: IndexPath(row: index, section: 0)) as? DKPhotoWithAudioIndexCell {
                    cell.showBorder = true
                }
                self.bottomView.update(with: self.assets[index])
                self.updateCountLabel()
            }).disposed(by: bag)
        
        contentView.rx.contentOffset
            .subscribe(onNext: { [weak self] (offset) in
                guard let self = self, self.contentView.bounds.width != 0 else { return }
                var index: Int = Int(round(offset.x / self.contentView.bounds.width))
                index = min(self.assets.count - 1, max(0, index))
                if index != self.currentIndex.value {
                    self.currentIndex.accept(index)
                    self.indexView.scrollToItem(at: IndexPath(row: index, section: 0),
                                                at: .centeredHorizontally,
                                                animated: true)
                }
            }).disposed(by: bag)
    }
    
    // MARK: - Audio Add Guide
    
    fileprivate var addGuideButton: UIButton?
    fileprivate let kDidShowAddGuide: String = "com.fenbishuo.ios.audio.add.guide"
    
    fileprivate func showAddGuideIfNeed() {
        if !UserDefaults.standard.bool(forKey: kDidShowAddGuide) {
            showAddGuide()
            UserDefaults.standard.set(true, forKey: kDidShowAddGuide)
            UserDefaults.standard.synchronize()
        }
    }
    
    fileprivate func showAddGuide() {
        guard addGuideButton == nil else {
            return
        }
        
        // 184x116
        let gb = UIButton(type: .custom)
        gb.setImage(DKImagePickerControllerResource.audioAddGuide(), for: .normal)
        gb.addTarget(self, action: #selector(guideAction(_:)), for: .touchUpInside)
        view.addSubview(gb)
        gb.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(bottomView.addAudioView.snp.top)
            make.size.equalTo(CGSize(width: 184, height: 116))
        }
        addGuideButton = gb
    }
    
    fileprivate func hideAddGuide() {
        addGuideButton?.removeFromSuperview()
        addGuideButton = nil
    }
    
    @objc fileprivate func guideAction(_ btn: UIButton) {
        hideAddGuide()
    }
    
    // MARK: -
    
    fileprivate var coverView: UIView?
    // 【ID1002514】
    fileprivate func updateCoverView(_ isShow: Bool) {
        guard isShow else {
            coverView?.isHidden = true
            return
        }
        
        if coverView == nil {
            let cv = UIView()
            cv.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            view.addSubview(cv)
            cv.snp.makeConstraints({ $0.edges.equalToSuperview() })
            coverView = cv
        }
        coverView?.isHidden = false
    }
    
    // MARK: - Actions
    
    @objc func cancelAction(_ btn: UIButton) {
        // 【ID1001637】
        updateCoverView(true)
        hideAddGuide()
        let alert = UIAlertController(title: nil,
                                      message: "现在退出，内容将全部丢失是否继续退出？",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "继续退出", style: .destructive, handler: { [weak self] (_) in
            self?.updateCoverView(false)
            self?.dismiss()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { [weak self] (_) in
            self?.updateCoverView(false)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func needShowTips() -> Bool {
        for asset in assets {
            if asset.isResized {
                return true
            } else if asset.audioPath.value != nil {
                return true
            }
        }
        return false
    }
    
    @objc func nextAction(_ btn: UIButton) {
        hideAddGuide()
        cropImages()
    }
    
    fileprivate func dismiss() {
        dismiss(animated: true) {
            self.transitionController = nil
        }
    }
    
    func deleteImage(_ asset: DKAsset) {
        hideAddGuide()
        assets.remove(at: currentIndex.value)
        ipc?.deselect(asset: asset)
        if assets.isEmpty {
            dismiss()
        } else {
            indexView.reloadData()
            contentView.reloadData()
            if currentIndex.value >= assets.count  {
                currentIndex.accept(assets.count - 1)
            }
            bottomView.update(with: assets[currentIndex.value])
            updateCountLabel()
        }
    }
    
    fileprivate func updateCountLabel() {
        hideAddGuide()
        countLabel.text = "\(currentIndex.value + 1)/\(assets.count)"
    }
    
    /// 总是使用原图进行裁剪
    func resizerImage(_ sourceImage: UIImage, _ asset: DKAsset) {
        hideAddGuide()
        let imageCropper = CropViewController(croppingStyle: .default, image: sourceImage)
        imageCropper.onDidCropToRect = { [weak self, weak imageCropper] image, _, _ in
            guard let self = self else { return }
            if image != sourceImage {
                print("resized image \(image)")
                asset.audioImage.accept(image)
                let path = DKUtils.imageDirectory + "\(Date().timeIntervalSince1970)-\(image.hash).png"
//                SDImageCache.shared.store(image, forKey: path, completion: nil)
                let data = SDImageIOCoder.shared.encodedData(with: image, format: .PNG, options: nil)
                SDImageCache.shared.storeImageData(toDisk: data, forKey: path)
                asset.imagePath.accept(path)
                asset.isResized = true
            }
            imageCropper?.dismiss(animated: true, completion: nil)
        }
        imageCropper.modalPresentationStyle = .fullScreen
        imageCropper.doneButtonTitle = "完成"
        imageCropper.cancelButtonTitle = "取消"
//        imageCropper.title = "调整"
        imageCropper.aspectRatioLockEnabled = true
        imageCropper.resetAspectRatioEnabled = false
        imageCropper.resetButtonHidden = true
        imageCropper.aspectRatioPickerButtonHidden = true
        let width: CGFloat = UIScreen.main.bounds.width - 32
        let height: CGFloat = width * 4 / 3.5
//        imageCropper.imageCropFrame = CGRect(x: 0, y: 0, width: width, height: height)
        imageCropper.customAspectRatio = CGSize(width: 3.5, height: 4)
        present(imageCropper, animated: true, completion: nil)
    }
    
    func showAudioRecorder(_ asset: DKAsset) {
        hideAddGuide()
        func show() {
            let recorder = DKPhotoWithAudioRecorder(asset: asset)
            recorder.transitionController = DKAudioRecorderTransitionController(recorderVC: recorder, presentedViewController: recorder, presentingViewController: self)
            recorder.transitioningDelegate = recorder.transitionController
            recorder.transitionController.prepareInteractiveGesture()
            present(recorder, animated: true, completion: nil)
        }
        
        func junmToSetting() {
            let alert = UIAlertController(title: nil, message: "录制音频需要允许麦克风权限，现在设置？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (_) in
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
        func requestPermission() {
            AVAudioSession.sharedInstance().requestRecordPermission { (allowed) in
                DispatchQueue.main.async {
                    allowed ? show() : junmToSetting()
                }
            }
        }
        
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            show()
        case .denied:
            junmToSetting()
        case .undetermined:
            requestPermission()
        }
    }
    
    private func cropImages() {
        guard !assets.isEmpty else { return }
        
        var tasks: [Observable<Bool>] = []
        
        for asset in assets {
            guard !asset.isResized else { continue }
            asset.isCroping = true
            //
            // SerialDispatchQueueScheduler(qos: .userInteractive)
            tasks.append(cropAsset(asset).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background)))
        }
        
        // 已全部裁剪
        guard !tasks.isEmpty else {
            self.ipc?.didSelectAssets?(self.assets)
            self.ipc?.dismiss()
            return
        }
        
        UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [MBProgressHUD.self]).color = .white
        let hud = MBProgressHUD.showAdded(to: parent?.view ?? view, animated: true)
        hud.bezelView.backgroundColor = .black
        
        _ = Observable
            .zip(tasks)
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .take(tasks.count)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (finished) in
                self?.ipc?.didSelectAssets?(self?.assets ?? [])
                self?.ipc?.dismiss()
                hud.hide(animated: true)
                print("Crop images finished. \(finished.count)")
            })
    }
    
    private func cropAsset(_ asset: DKAsset) -> Observable<Bool> {
        
        return Observable<Bool>.create { [weak self] observer in
            if let image = asset.audioImage.value {
//                asset.audioImage.accept(cropImage(image))
                asset.imagePath.accept(self?.cropImage(image))
                observer.onNext(true)
                observer.onCompleted()
            } else {
                asset.fetchImage(with: CGSize(width: 1080, height: 1080 * 4.0 / 3.5)) { [weak self] (image, _) in
                    asset.imagePath.accept(self?.cropImage(image))
                    observer.onNext(true)
                    observer.onCompleted()
                }
//                asset.fetchOriginalImage { [weak self] (image, _) in
////                    asset.audioImage.accept(cropImage(image))
//                    asset.imagePath.accept(self?.cropImage(image))
//                    observer.onNext(true)
//                    observer.onCompleted()
//                }
            }
            return Disposables.create()
        }
    }
    
    private func cropImage(_ image: UIImage?) -> String? {
        autoreleasepool {
            print("cropAsset Begin crop image.")
            guard let image = image else { return nil }
            
            let rate: CGFloat = 3.5 / 4
            let originRate = image.size.width / image.size.height
            
            let croppedImage: UIImage?
            
            if originRate > rate - 0.001 && originRate < rate + 0.001 {
                croppedImage = image
            } else {
                let width: CGFloat
                let height: CGFloat
                let frame: CGRect
                
                if image.size.width / image.size.height > rate {
                    height = image.size.height// + CGFloat.random(in: 0..<2) // debug
                    width = height * rate
                    frame = CGRect(x: (image.size.width - width) / 2, y: 0, width: width, height: height)
                } else {
                    width = image.size.width// + CGFloat.random(in: 0..<2) // debug
                    height = width / rate
                    frame = CGRect(x: 0, y: (image.size.height - height) / 2, width: width, height: height)
                }
                
//                let croppedImage = image.byCrop(to: frame)
                croppedImage = image.croppedImage(withFrame: frame, angle: 0, circularClip: false)
            }

//                guard let data = croppedImage.sd_imageData(as: .PNG, compressionQuality: Double(min(1080 / width, 1))) else { return nil }
            let path = DKUtils.imageDirectory + "\(Date().timeIntervalSince1970)-\(croppedImage.hashValue).png"
            let data = SDImageIOCoder.shared.encodedData(with: croppedImage, format: .PNG, options: nil)
            SDImageCache.shared.storeImageData(toDisk: data, forKey: path)
//            SDImageCache.shared.store(croppedImage, forKey: path, completion: nil)
//            SDImageCache.shared.store(croppedImage, imageData: data, forKey: path, cacheType: .all, completion: nil)
//                SDImageCache.shared.storeImage(toMemory: croppedImage, forKey: path)
            print("cropAsset End crop image.")
            return path
        }
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension DKPhotoWithAudioEditor: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func needShowAddCell() -> Bool {
        let max: Int = ipc?.maxSelectableCount ?? 0
        return max > assets.count
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == contentView {
            return assets.count
        } else {
            return needShowAddCell() ? assets.count + 1 : assets.count
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == indexView {
            if indexPath.row == assets.count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DKPhotoWithAudioAddCell.reuseIdentifier, for: indexPath) as! DKPhotoWithAudioAddCell
                return cell
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DKPhotoWithAudioIndexCell.reuseIdentifier, for: indexPath) as! DKPhotoWithAudioIndexCell
            cell.showBorder = currentIndex.value == indexPath.row
            cell.prepare(asset: assets[indexPath.row])
            return cell
        } else if collectionView == contentView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DKPhotoWithAudioContentCell.reuseIdentifier, for: indexPath) as! DKPhotoWithAudioContentCell
            cell.prepare(asset: assets[indexPath.row])
            cell.audioEditor = self
            return cell
        }
        return UICollectionViewCell()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == indexView else {
            return
        }
        hideAddGuide()
        if indexPath.row == assets.count {
            let ipc = DKImagePickerController()
            ipc.UIDelegate = self.ipc?.UIDelegate.createNew()
            ipc.modalPresentationStyle = .fullScreen
            ipc.showsCancelButton = true
            ipc.assetType = .allPhotos
            ipc.maxSelectableCount = 50 - assets.count
            ipc.didSelectAssets = { [weak self] assets in
                guard let self = self, !assets.isEmpty else { return }
                self.assets.append(contentsOf: assets)
                self.indexView.reloadData()
                self.contentView.reloadData()
                let index = self.assets.count - assets.count
                self.currentIndex.accept(index)
                self.indexView.scrollToItem(at: IndexPath(row: index, section: 0),
                                            at: .centeredHorizontally,
                                            animated: false)
                self.contentView.scrollToItem(at: IndexPath(row: index, section: 0),
                                              at: .centeredHorizontally,
                                              animated: false)
            }
            present(ipc, animated: true, completion: nil)
        } else {
            currentIndex.accept(indexPath.row)
            contentView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }
}
