//
//  VideoUploader.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/1/9.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit
import Foundation
import Photos

import SnapKit
import MBProgressHUD
import AliyunOSSiOS

import DKImagePickerController

#if arch(x86_64)
#else
import PLShortVideoKit
#endif

@objc(CTVideoUploaderDelegate) protocol VideoUploaderDelegate {
    
    @objc optional func uploadProgress(percent: Float)
    
    @objc optional func didFinishedUpload(isSuccess: Bool, videoId: String?, error: Error?)
}

// MARK: - VideoUploader

@objc(CTVideoUploader)
class VideoUploader: NSObject {
    
    weak var delegate: VideoUploaderDelegate?
    
    fileprivate var filePath: URL!
    
    fileprivate var videoId: String?
    
    @objc init(filePath: URL, delegate: VideoUploaderDelegate? = nil) {
        super.init()
        self.delegate = delegate
        self.filePath = filePath
    }
    
    @objc func startUploadVideo(md5: String?, width: Int, height: Int, rotate: Int) {
        upload(md5, width: width, height: height, rotate: rotate)
    }
        
    fileprivate func upload(_ md5: String?, width: Int, height: Int, rotate: Int) {
        
        var _md5: String?
        if let m = md5 {
            _md5 = m
        } else if let m = OSSUtil.fileMD5String(filePath.path) {
            _md5 = m // iOS 10 权限不够，计算错误
        } else {
            // M5计算错误
            delegate?.didFinishedUpload?(isSuccess: false, videoId: nil, error: nil)
            return
        }
        
        let request = CTFFileApi.getVideoToken(_md5!, width: width, height: height, rotate: rotate)
        request.requstApiSuccess({ [weak self] (data) in
            guard
                let json = data as? [String: Any],
                let token = json["token"] as? String,
                let video = json["video"] as? [String: Any],
                let videoId = video["idString"] as? String,
                let videoKey = video["objectKey"] as? String else {
                    // JSON解析错误
                    Logger.error("视频上传失败 \(String(describing: data))")
                    self?.delegate?.didFinishedUpload?(isSuccess: false, videoId: nil, error: nil)
                    return
            }
            if token.isEmpty {
                // 视频已上传
                self?.delegate?.didFinishedUpload?(isSuccess: true, videoId: videoId, error: nil)
            } else {
                self?.videoId = videoId
                self?.uploadVideo(token: token, videoKey: videoKey)
            }
        }) { (error) in
            Logger.error("视频上传失败 \(String(describing: error))")
            self.delegate?.didFinishedUpload?(isSuccess: false, videoId: nil, error: error)
        }
    }
    
#if arch(x86_64)
    fileprivate func uploadVideo(token: String, videoKey: String) {
        Logger.debug("模拟器不支持七牛云上传")
        self.delegate?.didFinishedUpload?(isSuccess: false, videoId: nil, error: nil)
    }
    
    @objc func cancelUpload() {}
#else
    fileprivate var uploader: PLShortVideoUploader?
    
    fileprivate func uploadVideo(token: String, videoKey: String) {
        let config = PLSUploaderConfiguration(token: token, videoKey: videoKey, https: true, recorder: nil)
        uploader = PLShortVideoUploader(configuration: config!)
        uploader?.delegate = self
        uploader?.uploadVideoFile(filePath.path)
    }
    
    @objc func cancelUpload() {
        uploader?.cancelUploadVidoFile()
    }
#endif
}
#if arch(x86_64)

#else

extension VideoUploader: PLShortVideoUploaderDelegate {
    
    func shortVideoUploader(_ uploader: PLShortVideoUploader, uploadKey: String?, uploadPercent: Float) {
        self.delegate?.uploadProgress?(percent: uploadPercent)
    }
    
    func shortVideoUploader(_ uploader: PLShortVideoUploader, complete info: PLSUploaderResponseInfo, uploadKey: String, resp: [AnyHashable : Any]?) {
        if info.isOK, let vid = self.videoId {
            // 上传完毕
            self.delegate?.didFinishedUpload?(isSuccess: true, videoId: vid, error: nil)
        } else {
            // 上传失败
            Logger.error("视频上传失败 \(String(describing: info.error)) \(String(describing: resp))")
            self.delegate?.didFinishedUpload?(isSuccess: false, videoId: nil, error: nil)
        }
    }
}

#endif

// MARK: - VideoUploaderProgress

@objc(CTVideoUploaderProgress)
class VideoUploaderProgress: BaseView {
    
    @objc weak var hud: MBProgressHUD?
    
    @objc var progress: Float = 0 {
        didSet {
            progressView.progress = progress
            let value = Int(progress * 100)
            progressLabel.text = "\(value)%"
        }
    }
    
    @objc var cancelBlock: (() -> Void)?
    
    private let progressView = MBRoundProgressView()
    private let titleLabel = UILabel()
    private let progressLabel = UILabel()
    private let loadingView = BaseView()
    
    private let closeButton = UIButton(type: .custom)
    
    @objc class func showInView(_ view: UIView) -> VideoUploaderProgress {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        return VideoUploaderProgress(hud: hud)
    }
    
    convenience init(hud: MBProgressHUD) {
        self.init(frame: .zero)
        self.hud = hud
        
        hud.mode = .customView
        hud.customView = self
        hud.bezelView.style = .solidColor
        hud.bezelView.color = .clear
        
        snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: Utils.screenPortraitWidth, height: Utils.screenPortraitHeight))
        }
    }
    
    override func setup() {
        super.setup()
        
        backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        
        configLoadingView()
        
        addSubview(closeButton)
        closeButton.setImage(UIImage(named: "video_upload_cancel"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeAction(_:)), for: .touchUpInside)
        closeButton.snp.makeConstraints { (make) in
            make.top.equalTo(loadingView.snp.bottom).offset(68)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 54, height: 54))
        }
    }
    
    private func configLoadingView() {
        addSubview(loadingView)
        loadingView.backgroundColor = .black
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 12
        loadingView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 140, height: 140))
        }
        
        progressView.progressTintColor = UIColor.ctMain()
        progressView.backgroundTintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        progressView.isAnnular = true
        
        loadingView.addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 63, height: 63))
            make.top.equalToSuperview().offset(25)
            make.centerX.equalToSuperview()
        }
        
        loadingView.addSubview(titleLabel)
        titleLabel.text = "视频上传中"
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
        }
        
        loadingView.addSubview(progressLabel)
        progressLabel.text = "0%"
        progressLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        progressLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        progressLabel.snp.makeConstraints { (make) in
            make.center.equalTo(progressView)
        }
    }
    
    @objc func closeAction(_ btn: UIButton) {
        cancelBlock?()
        hide()
    }
    
    @objc func hide() {
        hud?.hide(animated: true)
    }
}
