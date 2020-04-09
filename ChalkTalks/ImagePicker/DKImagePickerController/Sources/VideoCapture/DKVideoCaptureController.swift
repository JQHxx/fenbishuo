//
//  DKVideoCaptureController.swift
//  DKImagePickerController
//
//  Created by lizhuojie on 2020/1/7.
//

import UIKit

import SnapKit

#if arch(x86_64)
import AVFoundation
#else
import Qiniu
import PLShortVideoKit
#endif

import MBProgressHUD

class DKVideoCaptureController: UIViewController {
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        setup()
    }
    
    fileprivate var videoUrls: [URL] = []
    
    var recordingView: DKVideoCaptureRecordingView?
    
    var didFinishCapturingVideo: ((URL) -> Void)?
    
    fileprivate var beautifyModeOn: Bool = true
    
    fileprivate let captureBtn = UIButton(type: .custom)
    
    fileprivate let timeLabel = UILabel()
    fileprivate let deleteBtn = UIButton(type: .custom)
    fileprivate let doneBtn = UIButton(type: .custom)
    
    fileprivate let progressBackView = DKVideoCaptureProgressView()
    
    func setup() {
        modalPresentationStyle = .fullScreen
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkVideoPermission()
    }
    
    fileprivate var permissionView: DKVideoCapturePermissionView?
    
    fileprivate func checkVideoPermission() {
        func hasAllPermission() -> Bool {
            let capture = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
            let microPhone = AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
            return capture && microPhone
        }
        
        guard !hasAllPermission() else {
            permissionView?.removeFromSuperview()
            permissionView = nil
            #if arch(x86_64)
            #else
            setupShortVideoConfig()
            prepareUI()
            videoRecorder.startCaptureSession()
            #endif
            return
        }
        
        if permissionView == nil {
            permissionView = DKVideoCapturePermissionView(self)
            permissionView?.authUpdate = { [weak self] () -> Void in
                self?.checkVideoPermission()
            }
            view.addSubview(permissionView!)
            permissionView!.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    func prepareUI() {
        #if arch(x86_64)
        #else
        if let pv = videoRecorder.previewView {
            view.addSubview(pv)
            pv.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        #endif
        
        view.addSubview(progressBackView)
        progressBackView.layer.cornerRadius = 2
        progressBackView.clipsToBounds = true
        let phoneX: Bool = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width) >= 812
        let topOffset: CGFloat = phoneX ? 50 : 26
        progressBackView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(topOffset)
            make.leading.equalToSuperview().offset(6)
            make.trailing.equalToSuperview().offset(-6)
            make.height.equalTo(4)
        }
        
        // 返回
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(DKImagePickerControllerResource.whiteBackIcon(), for: .normal)
        backBtn.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        view.addSubview(backBtn)
        backBtn.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(progressBackView.snp.bottom).offset(27)
            make.size.equalTo(CGSize(width: 36, height: 36))
        }
        
        // 切换前后摄像头
        let rotateBtn = UIButton(type: .custom)
        rotateBtn.setImage(DKImagePickerControllerResource.rotateCamera(), for: .normal)
        rotateBtn.addTarget(self, action: #selector(rotateCamera(_:)), for: .touchUpInside)
        view.addSubview(rotateBtn)
        rotateBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(backBtn)
            make.trailing.equalToSuperview().offset(-8)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        // 美颜
        let beautiBtn = UIButton(type: .custom)
        beautiBtn.setImage(DKImagePickerControllerResource.beautifulSelect(), for: .normal)
        beautiBtn.addTarget(self, action: #selector(beautiAction(_:)), for: .touchUpInside)
        view.addSubview(beautiBtn)
        beautiBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(rotateBtn)
            make.top.equalTo(rotateBtn.snp.bottom).offset(8)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        if let rv = recordingView {
            rv.isHidden = true
            view.addSubview(rv)
            rv.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-40)
                make.size.equalTo(CGSize(width: 90, height: 90))
            }
        }
        
        // 录制开关
        captureBtn.setImage(DKImagePickerControllerResource.recordNormalIcon(), for: .normal)
        captureBtn.addTarget(self, action: #selector(captureAction(_:)), for: .touchUpInside)
        view.addSubview(captureBtn)
        captureBtn.snp.makeConstraints { (make) in
            if let rv = recordingView {
                make.center.equalTo(rv)
            } else {
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-48)
            }
            make.size.equalTo(CGSize(width: 74, height: 74))
        }
        
        timeLabel.font = UIFont.boldSystemFont(ofSize: 16)
        timeLabel.isHidden = true
        timeLabel.textColor = .white
        timeLabel.text = "0:00"
        view.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(captureBtn.snp.top).offset(-18)
        }
        
        deleteBtn.setImage(DKImagePickerControllerResource.deleteLastVideo(), for: .normal)
        deleteBtn.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
        view.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(captureBtn)
            make.trailing.equalTo(captureBtn.snp.leading).offset(-56)
            make.size.equalTo(CGSize(width: 43, height: 37))
        }
        deleteBtn.isHidden = true
        
        doneBtn.setImage(DKImagePickerControllerResource.finishCapture(), for: .normal)
        doneBtn.isHidden = true
        doneBtn.addTarget(self, action: #selector(doneAction(_:)), for: .touchUpInside)
        view.addSubview(doneBtn)
        doneBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(captureBtn)
            make.leading.equalTo(captureBtn.snp.trailing).offset(58)
            make.size.equalTo(CGSize(width: 36, height: 36))
        }
    }
    

    
    #if arch(x86_64)
    @objc func backAction(_ btn: UIButton) { dismiss(animated: true, completion: nil) }
    @objc func rotateCamera(_ btn: UIButton) {}
    @objc func beautiAction(_ btn: UIButton) {}
    @objc func captureAction(_ btn: UIButton) {}
    @objc func deleteAction(_ btn: UIButton) {}
    @objc func doneAction(_ btn: UIButton) {}
    #else
    
    @objc func backAction(_ btn: UIButton) {
        guard videoRecorder.getFilesCount() > 0 || videoRecorder.isRecording else { dismiss(animated: true, completion: nil); return }
        let alert = UIAlertController(title: nil, message: "是否放弃当前录制", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "是", style: .destructive, handler: { [weak self] (_) in
            self?.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "否", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func rotateCamera(_ btn: UIButton) {
        videoRecorder.toggleCamera { (_) in
            //
        }
    }
    
    @objc func beautiAction(_ btn: UIButton) {
        beautifyModeOn = !beautifyModeOn
        if beautifyModeOn {
            btn.setImage(DKImagePickerControllerResource.beautifulSelect(), for: .normal)
        } else {
            btn.setImage(DKImagePickerControllerResource.beautifulUnSelect(), for: .normal)
        }
        videoRecorder.setBeautifyModeOn(beautifyModeOn)
    }
    
    @objc func captureAction(_ btn: UIButton) {
        if let rv = recordingView, rv.isStoping { return }
        if videoRecorder.isRecording {
            videoRecorder.stopRecording()
        } else {
            videoRecorder.startRecording()
        }
    }
    
    @objc func deleteAction(_ btn: UIButton) {
        guard let url = videoRecorder.getAllFilesURL()?.last else { return }
        let alert = UIAlertController(title: nil, message: "确定删除“上一段录制内容”", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "删除", style: .destructive, handler: { [weak self] (_) in
            guard let self = self else { return }
            self.videoRecorder.deleteLastFile()
            self.updateTotalDuration(self.videoRecorder.getTotalDuration())
            self.progressBackView.removeDot(url)
            let needHidden = self.videoRecorder.getFilesCount() == 0
            btn.isHidden = needHidden
            self.doneBtn.isHidden = needHidden
            self.timeLabel.isHidden = needHidden
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func doneAction(_ btn: UIButton) {
        if videoRecorder.getTotalDuration() > 5 {
            videoCompose()
        } else {
            showVideoAlert("拍摄时间不能少于5s")
        }
    }
    #endif
    
    private func showVideoAlert(_ msg: String) {
        let alert = UIAlertController(title: "", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "我知道了", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func updateTotalDuration(_ value: CGFloat) {
        progressBackView.progress = value / DKVideoCaptureProgressView.maxDuration
        let minute: Int = Int(floor(value / 60))
        let second: Int = Int(floor(value)) % 60
        timeLabel.text = String(format: "%d:%02d", minute, second)
        timeLabel.isHidden = false
    }
    
    fileprivate func showError(message: String, error: Error?) {
        
    }
    
    // MARK: - Qiniu
    #if arch(x86_64)
    func setupShortVideoConfig() {}
    fileprivate func videoCompose() {}
    #else
    fileprivate let videoConfig: PLSVideoConfiguration! = PLSVideoConfiguration.default()
    fileprivate let audioConfig: PLSAudioConfiguration! = PLSAudioConfiguration.default()
    
    fileprivate var videoRecorder: PLShortVideoRecorder!
    
    func setupShortVideoConfig() {
        
        PLShortVideoRecorder.checkAuthentication { [weak self] (result) in
            print("七牛未授权状态 \(result)")
        }
        
        videoConfig.videoFrameRate = 30
        videoConfig.position = .back
        
        videoRecorder = PLShortVideoRecorder(videoConfiguration: videoConfig, audioConfiguration: audioConfig)
        videoRecorder.maxDuration = DKVideoCaptureProgressView.maxDuration
        videoRecorder.minDuration = DKVideoCaptureProgressView.minDuration
        videoRecorder.setBeautifyModeOn(beautifyModeOn)
        videoRecorder.outputFileType = PLSFileTypeMPEG4
        videoRecorder.delegate = self
        videoRecorder.adaptationRecording = true
        videoRecorder.deviceOrientationBlock = {(deviceOrientation) in
            if deviceOrientation == PLSPreviewOrientationPortrait {
                self.videoRecorder.videoOrientation = .portrait
            } else if deviceOrientation == PLSPreviewOrientationPortraitUpsideDown {
                self.videoRecorder.videoOrientation = .portraitUpsideDown
            } else if deviceOrientation == PLSPreviewOrientationLandscapeRight {
                self.videoRecorder.videoOrientation = .landscapeLeft
            } else if deviceOrientation == PLSPreviewOrientationLandscapeLeft {
                self.videoRecorder.videoOrientation = .landscapeRight
            }
        }
    }
    
    // 视频拼接
    fileprivate func videoCompose() {
      let urls = videoRecorder.getAllFilesURL() ?? []
      guard !urls.isEmpty else { return }
      
      let assets: [AVAsset] = urls.map({ AVAsset(url: $0) }).reversed()
      let composition = AVMutableComposition()
      
      do {
          // 视频
          let compositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
          
          for asset in assets {
              let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
              try compositionTrack?.insertTimeRange(timeRange, of: asset.tracks(withMediaType: .video).first!, at: .zero)
          }
          
          // 声音
          let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
          
          for asset in assets {
              let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
              try audioTrack?.insertTimeRange(timeRange, of: asset.tracks(withMediaType: .audio).first!, at: .zero)
          }
          
          guard let cache = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last else {
              return
          }
          
          let cacheName = "/\(Int(Date().timeIntervalSince1970) * 1000).mp4"
          let filePath = URL(fileURLWithPath: cache + cacheName)
          try? FileManager.default.removeItem(at: filePath)
          
          exporterSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
          exporterSession?.outputFileType = .mp4
          exporterSession?.outputURL = filePath
          exporterSession?.shouldOptimizeForNetworkUse = true
            // 总时长大于60秒显示hud
            if videoRecorder.getTotalDuration() > 60 {
                startTimer()
            }
          exporterSession?.exportAsynchronously(completionHandler: { [weak exporterSession, weak self] () -> Void in
              
            guard let ex = exporterSession else { self?.endTimer(); return }
              switch ex.status {
              case .completed:
                  DispatchQueue.main.async {
                      self?.didFinishCapturingVideo?(filePath)
                      self?.endTimer()
                  }
              default:
                  self?.showError(message: "视频文件导出失败: \(ex.status)", error: nil)
                  self?.endTimer()
              }
            
          })
      } catch {
          showError(message: "视频文件合并失败", error: error)
      }
    }
    #endif
    
    fileprivate var exporterSession: AVAssetExportSession?
    
    fileprivate var timer: Timer?
    
    fileprivate func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] (_) in
            DispatchQueue.main.async {
                self?.updateProgressView()
            }
        })
    }
    
    fileprivate func endTimer() {
        timer?.invalidate()
        timer = nil
        DispatchQueue.main.async {
            self.hud?.hide(animated: true)
        }
    }
    
    fileprivate weak var hud: MBProgressHUD?
    
    fileprivate func updateProgressView() {
        guard let progress = exporterSession?.progress else { return }
        if progress < 100 && hud == nil {
            hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud?.mode = .customView
            hud?.customView = HUDCustomView()
            hud?.customView?.clipsToBounds = true
            hud?.customView?.layer.cornerRadius = 12
            hud?.customView?.snp.makeConstraints({ (make) in
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: 140, height: 140))
            })
            
            hud?.bezelView.style = .solidColor
            hud?.bezelView.color = .clear
        }
        
        if progress < 100 {
            (hud?.customView as? HUDCustomView)?.progress = progress
        } else {
            hud?.hide(animated: true)
        }
    }
}

#if arch(x86_64)
#else
// MARK: - PLShortVideoRecorderDelegate

extension DKVideoCaptureController: PLShortVideoRecorderDelegate {
    
    // 开始录制回调
    func shortVideoRecorder(_ recorder: PLShortVideoRecorder, didStartRecordingToOutputFileAt fileURL: URL) {
        recordingView?.isHidden = false
        recordingView?.play()
        captureBtn.setImage(nil, for: .normal)
        deleteBtn.isHidden = true
        doneBtn.isHidden = true
    }
    
    // 录制中回调
    func shortVideoRecorder(_ recorder: PLShortVideoRecorder, didRecordingToOutputFileAt fileURL: URL, fileDuration: CGFloat, totalDuration: CGFloat) {
        updateTotalDuration(totalDuration)
    }
    
    // 完成录制
    func shortVideoRecorder(_ recorder: PLShortVideoRecorder, didFinishRecordingToOutputFileAt fileURL: URL, fileDuration: CGFloat, totalDuration: CGFloat) {
        recordingView?.stop(completion: { [weak self] (finished) in
            guard let self = self else { return }
            self.recordingView?.isHidden = true
            self.captureBtn.setImage(DKImagePickerControllerResource.recordNormalIcon(), for: .normal)
            self.doneBtn.isHidden = false
            self.deleteBtn.isHidden = false
            self.progressBackView.addDot(fileURL)
        })
    }
    
    // 在达到指定的视频录制时间 maxDuration 后，如果再调用 [PLShortVideoRecorder startRecording]，那么会立即执行该回调。该回调功能是用于页面跳转
    func shortVideoRecorder(_ recorder: PLShortVideoRecorder, didFinishRecordingMaxDuration maxDuration: CGFloat) {
        //
    }
}

#endif

fileprivate class HUDCustomView: UIView {
    
    let progressView = MBRoundProgressView()
    let titleLabel = UILabel()
    let progressLabel = UILabel()
    
    var progress: Float = 0 {
        didSet {
            progressView.progress = progress
            let value = Int(progress * 100)
            progressLabel.text = "\(value)%"
        }
    }
    convenience init() {
        self.init(frame: .zero)
        setup()
    }
    
    func setup() {
        backgroundColor = .black
        
        progressView.progressTintColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1)
        progressView.backgroundTintColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        progressView.isAnnular = true
        
        addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 63, height: 63))
            make.top.equalToSuperview().offset(25)
            make.centerX.equalToSuperview()
        }
        
        addSubview(titleLabel)
        titleLabel.text = "视频转码中"
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
        }
        
        addSubview(progressLabel)
        progressLabel.text = "0%"
        progressLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        progressLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        progressLabel.snp.makeConstraints { (make) in
            make.center.equalTo(progressView)
        }
    }
}
