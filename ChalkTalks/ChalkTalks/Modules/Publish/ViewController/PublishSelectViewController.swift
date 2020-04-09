//
//  PublishSelectViewController.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/1/19.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit
import AVFoundation

import SnapKit
import RxSwift
import RxCocoa

#if DEBUG
import MLeaksFinder
#endif

@objc(CTPublishContentType)
enum PublishContentType: Int, CaseIterable {
    case photo = 1, video, photoWithAudio
    
    var select_item_bg: String {
        return "publish_select_bg\(rawValue)"
    }
    
    var select_item_sample: String {
        return "publish_select_sample\(rawValue)"
    }
    
    var select_title: String {
        switch self {
        case .photo:
            return "图文"
        case .video:
            return "视频"
        case .photoWithAudio:
            return "图文+语音"
        }
    }
    
    var select_subTitle: String {
        switch self {
        case .photo:
            return "传统图文形式，适合小白新手"
        case .video:
            return "上传视频回答能收获更多粉丝哦～"
        case .photoWithAudio:
            return "粉笔说特色功能，让回答更有趣"
        }
    }
}

// MARK: - PublishSelectViewController

@objc(CTPublishSelectViewController)
class PublishSelectViewController: BaseViewController {
    
    fileprivate let questionId: Int
    fileprivate let questionTitle: String
    
    /// 修改回答
    /// - Parameter model: 当前回答model
    @objc class func changeAnswer(_ model: AnswerModel) {
        let vc = CTFPublishImageViewpointVC()
        
        vc.schemaArgu = [
            "questionId": model.question.questionId,
            "quesionTitle": model.question.title,
            "answerModel": model
        ]
        
        vc.modalPresentationStyle = .fullScreen
        Utils.topVC?.present(vc, animated: true, completion: nil)
    }
    
    @objc
    init(questionId: Int, questionTitle: String) {
        self.questionId = questionId
        self.questionTitle = questionTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #if DEBUG
    override func willDealloc() -> Bool {
        return false
    }
    #endif
    
    override func setup() {
        super.setup()
        showNavBar = false
        modalPresentationStyle = .fullScreen
    }
    
    override func prepareUI() {
        super.prepareUI()
        
        let bg = UIImageView(image: UIImage(named: "publish_select_bg"))
        contentView.addSubview(bg)
        bg.snp.makeConstraints({ $0.edges.equalToSuperview() })
        
        let margin: CGFloat = 22
        
        let header = PublishSelectHeaderView()
        contentView.addSubview(header)
        header.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(margin)
            make.trailing.equalToSuperview().offset(-margin)
            let offset: CGFloat = UIScreen.main.bounds.width > 320 ? 36 : 32
            make.top.equalToSuperview().offset(offset + Utils.statusHeight)
            make.height.equalTo(52)
        }
        
        header.closeButton
            .rx
            .tap
            .subscribe(onNext: { [weak self] (_) in
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        let rate: CGFloat = 280 / 668.0
        let height: CGFloat = rate * (UIScreen.main.bounds.width - 2 * margin)
        let video = PublishSelectItemView(.video).ss.prepare { (view) in
            contentView.addSubview(view)
            let tap = UITapGestureRecognizer()
            tap.rx.event
                .subscribe(onNext: { [weak self] (_) in
                    self?.publishNewContent(.video)
                }).disposed(by: disposeBag)
            view.addGestureRecognizer(tap)
            view.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().offset(margin)
                make.trailing.equalToSuperview().offset(-margin)
                make.centerY.equalToSuperview()
                make.height.equalTo(height)
            }
        }
        
        PublishSelectItemView(.photo).ss.prepare { (view) in
            contentView.addSubview(view)
            let tap = UITapGestureRecognizer()
            tap.rx.event
                .subscribe(onNext: { [weak self] (_) in
                    self?.publishNewContent(.photo)
                }).disposed(by: disposeBag)
            view.addGestureRecognizer(tap)
            view.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().offset(margin)
                make.trailing.equalToSuperview().offset(-margin)
                make.bottom.equalTo(video.snp.top).offset(-12)
                make.height.equalTo(height)
            }
        }
        
        PublishSelectItemView(.photoWithAudio).ss.prepare { (view) in
            contentView.addSubview(view)
            let tap = UITapGestureRecognizer()
            tap.rx.event
                .subscribe(onNext: { [weak self] (_) in
                    self?.publishNewContent(.photoWithAudio)
                }).disposed(by: disposeBag)
            view.addGestureRecognizer(tap)
            view.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().offset(margin)
                make.trailing.equalToSuperview().offset(-margin)
                make.top.equalTo(video.snp.bottom).offset(12)
                make.height.equalTo(height)
            }
        }
        
        PublishSelectFooterView().ss.prepare { (view) in
            contentView.addSubview(view)
            view.linkButton.rx.tap
                .subscribe(onNext: { [weak view, weak self] (_) in
                    guard let view = view, let self = self else { return }
                    UIPasteboard.general.string = view.url
                    HUD.show(to: self.contentView, text: "复制成功")
                }).disposed(by: disposeBag)
            view.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-Utils.bottomHeight - 20)
                make.width.equalToSuperview()
                make.height.equalTo(50)
            }
        }
    }
    
    override func prepareRx() {
        super.prepareRx()
    }
    
    fileprivate func publishNewContent(_ type: PublishContentType) {
        Logger.debug("Publish new content \(type.select_title)")
        let questionId = self.questionId
        let questionTitle = self.questionTitle
        dismiss(animated: true) {
            switch type {
            case .photo:
                MobClick.event("answer_text")
                self.showPhotoViewpoint(questionId, questionTitle)
            case .video:
                MobClick.event("answer_video")
                self.showVideoViewpoint(questionId, questionTitle)
            case .photoWithAudio:
                self.showPhotoWithAudio(questionId, questionTitle)
            }
        }
    }
    
    fileprivate var fromVC: UIViewController? {
        return presentingViewController ?? Utils.topVC
    }
    
    /// 图文回答
    fileprivate func showPhotoViewpoint(_ id: Int, _ title: String) {
        let topVC = fromVC
//        let picker = ImagePickerController(selectedCount: 0) { (images) in
//            // CTFPublishImageViewpointVC
//            let vc = CTFPublishImageViewpointVC()
//            vc.schemaArgu = [
//                "questionId": id,
//                "quesionTitle": title
//            ]
//            vc.pickImages = images
//            vc.modalPresentationStyle = .fullScreen
//            topVC?.present(vc, animated: true, completion: nil)
//        }
//        picker.supportSkip = true
//        topVC?.present(picker, animated: true, completion: nil)
        let vc = CTFPublishImageViewpointVC()
        vc.schemaArgu = [
            "questionId": id,
            "quesionTitle": title
        ]
        vc.pickImages = []
        vc.modalPresentationStyle = .fullScreen
        topVC?.present(vc, animated: true, completion: nil)
    }
    
    /// 视频回答
    fileprivate func showVideoViewpoint(_ id: Int, _ title: String) {
        let topVC = fromVC
        let picker = ImagePickerController { (url, asset) in
            if let url = url {
                self.showPublishVideoController(with: url, id: id, title: title)
                return
            }

            guard let asset = asset else { return }
            asset.fetchAVAsset { (avAsset, _) in
                if let urlAsset = avAsset as? AVURLAsset {
                    self.showPublishVideoController(with: urlAsset, id: id, title: title)
                } else if let cpAsset = avAsset as? AVComposition {
                    self.showPublishVideoController(with: cpAsset, localId: asset.localIdentifier, id: id, title: title)
                }
            }
        }
        topVC?.present(picker, animated: true, completion: nil)
    }
    
    /// 慢视频对象处理
    func showPublishVideoController(with asset: AVComposition, localId: String, id: Int, title: String) {
        guard
            let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality),
            !localId.isEmpty,
            let data = localId.data(using: .utf8),
            let videoName = OSSUtil.dataMD5String(data) else {
            Logger.error("导出慢视频失败 \(localId)")
            return
        }

        let exportPath = NSTemporaryDirectory().appendingFormat("\(videoName).mov")
        let exportUrl = URL(fileURLWithPath: exportPath)
        if FileManager.default.fileExists(atPath: exportPath) {
            let urlAsset = AVURLAsset(url: exportUrl)
            if CMTimeGetSeconds(urlAsset.duration) > 0 {
                self.showPublishVideoController(with: exportUrl, id: id, title: title)
                return
            } else {
                try? FileManager.default.removeItem(at: exportUrl)
            }
        }
        
        var hud: MBProgressHUD?
        DispatchQueue.main.async {
            if let view = self.fromVC?.navigationController?.view {
                hud = HUD.show(to: view)
            }
        }
        
        exporter.outputURL = exportUrl
        exporter.outputFileType = .mov
        exporter.shouldOptimizeForNetworkUse = true
        exporter.exportAsynchronously(completionHandler: {() -> Void in
            DispatchQueue.main.async(execute: {() -> Void in
                hud?.hide(animated: true)
                if exporter.status == .completed, let url = exporter.outputURL {
                    self.showPublishVideoController(with: url, id: id, title: title)
                } else if exporter.status == .failed {
                    Logger.error("导出慢视频失败 \(localId) \(String(describing: exporter.error)) \(exportPath)")
                }
            })
        })
    }
    
    func showPublishVideoController(with url: URL, id: Int, title: String) {
        DispatchQueue.main.async {
            let vc = CTFPublishVideoViewpointVC()
            vc.schemaArgu = [
                "questionId": id,
                "quesionTitle": title,
                "save": "1",
                "videoUrl": url
            ]
            let nav = UINavigationController.init(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.fromVC?.present(nav, animated: true, completion: nil)
        }
    }
    
    func showPublishVideoController(with asset: AVURLAsset, id: Int, title: String) {
        guard
            let data = try? Data(contentsOf: asset.url),
            let md5 = OSSUtil.dataMD5String(data)
            else { return }
        
        DispatchQueue.main.async {
            let vc = CTFPublishVideoViewpointVC()
            vc.asset = asset
            vc.schemaArgu = [
                "questionId": id,
                "quesionTitle": title,
                "videoUrl": asset.url.absoluteURL,
                "videoMd5": md5
            ]
            let nav = UINavigationController.init(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.fromVC?.present(nav, animated: true, completion: nil)
        }
    }
    
    /// 图语回答
    fileprivate func showPhotoWithAudio(_ id: Int, _ title: String) {
        let topVC = fromVC
        let picker = ImagePickerController(selectedAssets: []) { (assets) in
            let vc = PublishPhotoWithAudioController(questionId: id, questionTitle: title, assets: assets)
            topVC?.navigationController?.pushViewController(vc, animated: false)
        }
//        picker.supportSkip = true
        topVC?.present(picker, animated: true, completion: nil)
    }
}

// MARK: - PublishSelectHeaderView

fileprivate class PublishSelectHeaderView: BaseView {
    
    let closeButton = BaseButton(type: .custom)
    
    override func setup() {
        super.setup()
        
        let contentView = UIView()
        addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(30)
        }
        
        let smileView = UIImageView()
        smileView.image = UIImage(named: "publish_select_smile")
        contentView.addSubview(smileView)
        smileView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        let titleLabel = UILabel()
        titleLabel.text = "我来回答"
        titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalTo(smileView.snp.trailing).offset(6)
        }
        
        contentView.addSubview(closeButton)
        closeButton.hitTestInset = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        closeButton.setImage(UIImage(named: "publish_select_close"), for: .normal)
        closeButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        let subTitleLabel = UILabel()
        subTitleLabel.text = "一个话题下仅支持发布一条观点"
        subTitleLabel.textColor = UIColor(0x999999FF)
        subTitleLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(subTitleLabel)
        subTitleLabel.snp.makeConstraints { (make) in
            make.leading.bottom.equalToSuperview()
        }
    }
}

// MARK: - PublishSelectFooterView

fileprivate class PublishSelectFooterView: BaseView {
    
    private let bag: DisposeBag = DisposeBag()
    
    let url = "https://www.fenbishuo.com"
    let linkButton = BaseButton(type: .custom)
    
    override func setup() {
        super.setup()
        
        let titleLabel = UILabel()
        titleLabel.text = "超大文件请使用粉笔说web端"
        titleLabel.textColor = UIColor(0x666666FF)
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        linkButton.hitTestInset = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        linkButton.setTitle(url + "（点我复制）", for: .normal)
        linkButton.setTitleColor(UIColor(0x6EB0FEFF), for: .normal)
        linkButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        addSubview(linkButton)
        linkButton.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: - PublishSelectItemView

fileprivate class PublishSelectItemView: BaseView {
    
    let type: PublishContentType
    
    init(_ type: PublishContentType) {
        self.type = type
        super.init(frame: .zero)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        
        let backgroudView: UIImageView = UIImageView()
        let sampleView: UIImageView = UIImageView()
        
        let titleLabel: UILabel = UILabel()
        let subTitleLabel: UILabel = UILabel()
        
        addSubview(backgroudView)
        backgroudView.image = UIImage(named: type.select_item_bg)
        backgroudView.contentMode = .scaleAspectFill
        backgroudView.snp.makeConstraints({ $0.edges.equalToSuperview() })
        
        addSubview(sampleView)
        sampleView.image = UIImage(named: type.select_item_sample)
        sampleView.contentMode = .center
        sampleView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-22)
            make.width.equalTo(108)
        }
        
        addSubview(titleLabel)
        titleLabel.text = type.select_title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 19)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(18)
        }
        
        addSubview(subTitleLabel)
        subTitleLabel.text = type.select_subTitle
        subTitleLabel.textColor = UIColor.white.withAlphaComponent(0.76)
        subTitleLabel.font = UIFont.systemFont(ofSize: 12)
        subTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
        }
    }
}
