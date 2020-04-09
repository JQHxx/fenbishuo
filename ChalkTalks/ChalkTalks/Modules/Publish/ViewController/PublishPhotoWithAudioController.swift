//
//  PublishPhotoWithAudioController.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/1/19.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit

import DKImagePickerController
import DKPhotoGallery

import RxSwift
import RxCocoa
import MBProgressHUD

fileprivate class PublishPhotoWithAudioLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        scrollDirection = .vertical
        sectionInset = UIEdgeInsets(top: 9, left: 16, bottom: 28, right: 16)
        let spacing: CGFloat = 2
        minimumInteritemSpacing = spacing - 0.001
        minimumLineSpacing = spacing - 0.001
        
        guard let bounds = collectionView?.bounds, bounds != .zero else { return }
        
        headerReferenceSize = CGSize(width: bounds.width, height: 70)
        footerReferenceSize = CGSize(width: bounds.width, height: PublishPhotoWithAudioInputView.viewHeight)
        
        let width: CGFloat = (bounds.width - 32 - spacing * 3) / 4
        itemSize = CGSize(width: width, height: width)
    }
}

@objc(CTPublishPhotoWithAudioController)
class PublishPhotoWithAudioController: BaseViewController {
        
    fileprivate lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: PublishPhotoWithAudioLayout())
        cv.register(PublishPhotoWithAudioCell.self, forCellWithReuseIdentifier: PublishPhotoWithAudioCell.reuseIdentifier)
        cv.register(PublishPhotoWithAudioAddCell.self, forCellWithReuseIdentifier: PublishPhotoWithAudioAddCell.reuseIdentifier)
        cv.register(PublishPhotoWithAudioHeaderView.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: PublishPhotoWithAudioHeaderView.reuseIdentifier)
        cv.register(PublishPhotoWithAudioFooterView.self,
                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                    withReuseIdentifier: PublishPhotoWithAudioFooterView.reuseIdentifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    fileprivate lazy var inputTextView: PublishPhotoWithAudioInputView = PublishPhotoWithAudioInputView()
    
    fileprivate let viewModel: PublishPhotoWithAudioViewModel
    
    fileprivate let publishButton: BaseButton = BaseButton(type: .custom)
    
    fileprivate var draft: DraftAnswer?
    
    @objc
    init(questionId: Int, questionTitle: String, assets: [DKAsset]) {
        self.viewModel = PublishPhotoWithAudioViewModel(questionId, title: questionTitle, assets: assets)
        super.init(nibName: nil, bundle: nil)
        viewModel.parent = self
    }
    
    @objc
    init(draft: DraftAnswer) {
        var assets: [DKAsset] = []
        for item in draft.items {
//            guard let image = UIImage(contentsOfFile: item.imagePath) else { continue }
            let asset = DKAsset(imagePath: item.imagePath)
//            asset.audioImage.accept(image)
            asset.imagePath.accept(item.imagePath)
            asset.audioPath.accept(item.audioPath)
            asset.audioDuration = item.audioDuration
            asset.fromDraft = true
            
            if let imgKey = item.objectKey, let imgId = item.imageId {
                asset.imageUploadInfo = OSSUploadInfo(objectKey: imgKey, objectId: imgId)
                asset.uploadState.accept(.success)
            }
            
            if let audioKey = item.audioKey, let audioId = item.audioId {
                asset.audioUploadInfo = OSSUploadInfo(objectKey: audioKey, objectId: audioId)
            }
            assets.append(asset)
        }
        self.viewModel = PublishPhotoWithAudioViewModel(
            draft.questionId,
            title: draft.questionTitle,
            assets: assets
        )
        self.draft = draft
        super.init(nibName: nil, bundle: nil)
        viewModel.parent = self
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        showBackButton = true
        navBar.showLine = true
        navItem.title = "我来回答"
        fd_interactivePopDisabled = true
    }

    override func prepareUI() {
        super.prepareUI()
        
        contentView.addSubview(collectionView)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.snp.makeConstraints({ $0.edges.equalToSuperview() })
        
        contentView.addSubview(inputTextView)
        
        publishButton.ss.prepare { (button) in
            button.setTitle("发布", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            button.addTarget(self, action: #selector(publishAction(_:)), for: .touchUpInside)
            button.hitTestInset = UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8)
            button.sizeToFit()
        }
        
        navItem.rightBarButtonItem = UIBarButtonItem(customView: publishButton)
    }
    
    override func prepareRx() {
        super.prepareRx()
        
        collectionView.rx
            .contentOffset
            .subscribe(onNext: { [weak self] (offset) in
                self?.layoutInputView()
            }).disposed(by: disposeBag)
        
        viewModel.contentValidity
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (valid) in
                guard let self = self else { return }
                if valid && self.inputTextView.textValidity {
                    self.publishButton.setTitleColor(UIColor(0xFF6885FF), for: .normal)
                    self.publishButton.isEnabled = true
                } else {
                    self.publishButton.setTitleColor(UIColor(0xFF6885FF).withAlphaComponent(0.3), for: .normal)
                    self.publishButton.isEnabled = false
                }
            }).disposed(by: disposeBag)
        
        inputTextView.textView.rx.text
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                if self.viewModel.contentValidity.value && self.inputTextView.textValidity {
                    self.publishButton.setTitleColor(UIColor(0xFF6885FF), for: .normal)
                    self.publishButton.isEnabled = true
                } else {
                    self.publishButton.setTitleColor(UIColor(0xFF6885FF).withAlphaComponent(0.3), for: .normal)
                    self.publishButton.isEnabled = false
                }
            }).disposed(by: disposeBag)
    }
    
    override func backAction(_ btn: UIButton) {
        guard viewModel.contentValidity.value || inputTextView.text != nil else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        let alert = UIAlertController(title: nil, message: "是否退出编辑？", preferredStyle: .alert)
        let exitAction = UIAlertAction(title: "保存并退出", style: .default) { [weak self] (action) in
            self?.storeToDraft()
            self?.navigationController?.popViewController(animated: true)
        }
        exitAction.setValue(UIColor(0x999999FF), forKey: "titleTextColor")
        
        let continueAction = UIAlertAction(title: "继续编辑", style: .default, handler: nil)
        continueAction.setValue(UIColor(0xFF6885FF), forKey: "titleTextColor")
        
        alert.addAction(exitAction)
        alert.addAction(continueAction)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func storeToDraft() {
        Drafts.share.addPhotoWithAudio(
            content: inputTextView.text,
            questionId: viewModel.id,
            questionTitle: viewModel.title,
            assets: viewModel.assets
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let content = draft?.content {
            inputTextView.textView.text = content
            inputTextView.textView.textColor = .black
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutInputView()
    }
    
    fileprivate func layoutInputView() {
        let inputHeight = PublishPhotoWithAudioInputView.viewHeight
        if collectionView.frame.height > collectionView.contentSize.height {
            let y = collectionView.frame.minY + collectionView.contentSize.height - PublishPhotoWithAudioInputView.viewHeight
            inputTextView.frame = CGRect(x: 0,
                                         y: y,
                                         width: contentView.bounds.width,
                                         height: inputHeight)
        } else {
            var offset: CGFloat = collectionView.frame.height + collectionView.contentOffset.y - collectionView.contentSize.height
            offset = max(offset, 0)
            inputTextView.frame = CGRect(x: 0,
                                         y: contentView.bounds.height - inputHeight - offset,
                                         width: contentView.bounds.width,
                                         height: inputHeight)
        }
    }
    
    @objc func publishAction(_ button: BaseButton) {
        
        guard viewModel.assetsDidUpload else {
            let alert = UIAlertController(title: nil, message: "请等待图片语音上传完毕", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        Logger.debug("Publish photoWithAudio viewpoint.")
        
        var audioImages: [String] = []
        for (idx, asset) in viewModel.assets.enumerated() {
            guard let info = asset.imageUploadInfo as? OSSUploadInfo else {
                continue
            }
            
            var format = "\(idx)-\(info.objectId)"
            
            if let audio = asset.audioUploadInfo as? OSSUploadInfo {
                format += "-\(audio.objectId)"
            } else {
                format += "-0"
            }
            audioImages.append(format)
        }
        
        guard !audioImages.isEmpty else {
            Logger.debug("图片音频为空！")
            return
        }
        
        Logger.debug("param: \(audioImages)")
        
        var param: [String: Any] = [
            "type": "audioImage",
            "audioImages": audioImages
        ]
        
        if let content = inputTextView.text {
            param["content"] = content
        }
        
        let hud = MBProgressHUD.ctfShowLoading(navigationController!.view, title: "发布中...")
        let request = CTFTopicApi.createAnswer(viewModel.id, withParameters: param)
        let questionId = viewModel.id
        request.requstApiSuccess({ [weak self] (data) in
            hud?.hide(animated: true)
            // 删除草稿
            Drafts.share.removeDraft(questionId: questionId)
            // 跳转到我的回答
            NotificationCenter.default.post(name: Notification.Name(rawValue: kPublishAnswerSuccessNotification), object: nil)
            self?.navigationController?.popViewController(animated: true)
        }) { (error) in
            Logger.error("发布视频失败 \(String(describing: error))")
            hud?.hide(animated: true)
        }
    }
    
    func deleteItem(_ idx: Int) {
        if idx == viewModel.assets.count || viewModel.assets.count >= 49 {
            collectionView.reloadData()
            layoutInputView()
        } else {
            collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [IndexPath(row: idx, section: 0)])
            }) { (_) in
                self.layoutInputView()
            }
        }
    }
    
    func reloadCollectionView() {
        UIView.animate(withDuration: 0, animations: {
            self.collectionView.reloadData()
        }) { (_) in
            self.layoutInputView()
        }
    }
    
    fileprivate func showPhotoGallery(idx: Int) {
        guard let cell = collectionView.cellForItem(at: IndexPath(row: idx, section: 0)) as? PublishPhotoWithAudioCell else {
            return
        }
        
        let gallery = PhotoWithAudioGallery(viewModel.assets)
        gallery.presentingFromImageView = cell.imageView
        gallery.presentationIndex = idx
        present(photoGallery: gallery)
    }
}

// MARK: - DKPhotoGalleryController Delegate

extension PublishPhotoWithAudioController: DKPhotoGalleryDelegate {
    
    func photoGallery(_ gallery: DKPhotoGallery, didShow index: Int) {
        //
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension PublishPhotoWithAudioController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(viewModel.assets.count + 1, 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: PublishPhotoWithAudioHeaderView.reuseIdentifier,
                                                                         for: indexPath) as! PublishPhotoWithAudioHeaderView
            header.titleLabel.text = viewModel.title
            return header
        case UICollectionView.elementKindSectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: PublishPhotoWithAudioFooterView.reuseIdentifier,
                                                                         for: indexPath) as! PublishPhotoWithAudioFooterView
            return footer
        default:
            break
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < viewModel.assets.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PublishPhotoWithAudioCell.reuseIdentifier, for: indexPath) as! PublishPhotoWithAudioCell
            cell.prepare(asset: viewModel.assets[indexPath.row])
            cell.viewModel = viewModel
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PublishPhotoWithAudioAddCell.reuseIdentifier, for: indexPath) as! PublishPhotoWithAudioAddCell
            cell.backgroundColor = .white
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < viewModel.assets.count {
            let asset = viewModel.assets[indexPath.row]
            // 重传
            if asset.uploadState.value == .failure {
                viewModel.uploadAsset(asset)
            } else {
                showPhotoGallery(idx: indexPath.row)
            }
        } else {
            let imagePicker = ImagePickerController(selectedAssets: viewModel.assets) { [weak self] (assets) in
                self?.viewModel.add(assets: assets)
            }
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        inputTextView.textView.resignFirstResponder()
    }
}
