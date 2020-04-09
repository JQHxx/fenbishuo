//
//  DKPhotoWithAudioRecorder.swift
//  DKImagePickerController
//
//  Created by lizhuojie on 2020/1/15.
//

import UIKit
import AVFoundation

import MBProgressHUD
import Lottie
import SnapKit
import RxSwift
import RxRelay
import RxCocoa

class DKPhotoWithAudioRecorder: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    let asset: DKAsset
    let contentView: UIView = UIView()
    
    var transitionController: DKAudioRecorderTransitionController!
    
    let animationView: AnimationView = AnimationView(name: "audio_recording",
                                                     bundle: Bundle.main,
                                                     animationCache: LRUAnimationCache.sharedCache)
    /// 录制中
    fileprivate let isRecording: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    /// 试听中
    fileprivate let isPlaying: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    fileprivate var prepareRecord: Bool = false // 录制初始化状态
    
    fileprivate var displayLink: CADisplayLink?
    fileprivate let bag: DisposeBag = DisposeBag()
    
    init(asset: DKAsset) {
        self.asset = asset
        if let oldPath = asset.audioPath.value {
            self.audioPath = oldPath
        } else {
            self.audioPath = DKUtils.newAudioPath()
        }
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .custom
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Deinit audio recorder \(error)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        prepareRx()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if asset.audioPath.value == nil || asset.audioDuration < 3 {
            prepareRecordAtOnce()
        }
    }
    
    private let tipsLabel: UILabel = UILabel()
    private let playerProgressView = MBRoundProgressView()
    private let recordButton: UIButton = UIButton(type: .custom)
    private let recordTipsLabel: UILabel = UILabel()
    private let deleteButton: UIButton = ImageButton(spacing: 4, position: .top)
    private let doneButton: UIButton = ImageButton(spacing: 2, position: .top)
    private let timeLabel: UILabel = UILabel()
        
    private func prepareUI() {
        view.backgroundColor = .clear
        
        view.addSubview(contentView)
        contentView.backgroundColor = UIColor(red: 0.16, green: 0.16, blue: 0.17, alpha: 1)
        contentView.clipsToBounds = true
//        contentView.layer.cornerRadius = 20
        contentView.snp.makeConstraints { (make) in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(234 + DKUtils.safaAreaBottom)
        }
        
        let textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        
        contentView.addSubview(tipsLabel)
        tipsLabel.text = "说说你对这张图的想法或见解"
        tipsLabel.textColor = textColor
        tipsLabel.font = UIFont.systemFont(ofSize: 14)
        tipsLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(18)
        }
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:)))
        longPressGesture.minimumPressDuration = 0.2
        recordButton.addGestureRecognizer(longPressGesture)
        recordButton.addTarget(self, action: #selector(recordAction(_:)), for: .touchUpInside)
        if asset.audioPath.value == nil {
            recordButton.setImage(DKImagePickerControllerResource.audioRecord(), for: .normal)
        } else {
            recordButton.setImage(DKImagePickerControllerResource.audioAudition(), for: .normal)
        }
        recordButton.backgroundColor = UIColor(0xFF6885FF)
        recordButton.clipsToBounds = true
        recordButton.layer.cornerRadius = 32
        contentView.addSubview(recordButton)
        
        recordButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 64, height: 64))
        }
        
        recordButton.addSubview(playerProgressView)
        playerProgressView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        playerProgressView.progressTintColor = .white
        playerProgressView.backgroundTintColor = .clear
        playerProgressView.isAnnular = true
        playerProgressView.isUserInteractionEnabled = false
        playerProgressView.isHidden = true
        
        recordTipsLabel.text = "长按录制"
        recordTipsLabel.textAlignment = .center
        recordTipsLabel.font = UIFont.systemFont(ofSize: 14)
        recordTipsLabel.textColor = UIColor(red: 1, green: 0.41, blue: 0.52, alpha: 1)
        contentView.addSubview(recordTipsLabel)
        recordTipsLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(recordButton.snp.bottom).offset(36)
        }
        
        contentView.addSubview(deleteButton)
        deleteButton.setTitle("删除", for: .normal)
        deleteButton.setTitleColor(textColor, for: .normal)
        deleteButton.setImage(DKImagePickerControllerResource.audioDelete(), for: .normal)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        deleteButton.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
        deleteButton.isHidden = asset.audioPath.value == nil
        deleteButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(recordButton)
            make.trailing.equalTo(recordButton.snp.leading).offset(-56)
        }
        
        contentView.addSubview(doneButton)
        doneButton.setTitle("完成", for: .normal)
        doneButton.setTitleColor(textColor, for: .normal)
        doneButton.setImage(DKImagePickerControllerResource.audioDone(), for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        doneButton.addTarget(self, action: #selector(doneAction(_:)), for: .touchUpInside)
        doneButton.isHidden = asset.audioPath.value == nil
        doneButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(recordButton)
            make.leading.equalTo(recordButton.snp.trailing).offset(56)
        }
        
        contentView.addSubview(timeLabel)
        timeLabel.textColor = .white
        if asset.audioPath.value != nil {
            let duration = Int(round(asset.audioDuration))
            timeLabel.text = "\(duration)s"
        }
        timeLabel.font = UIFont.systemFont(ofSize: 18)
        timeLabel.textAlignment = .center
        timeLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(recordButton)
            make.bottom.equalTo(recordButton.snp.top).offset(-10)
            make.size.equalTo(CGSize(width: 60, height: 32))
        }
        
        contentView.addSubview(animationView)
        animationView.snp.makeConstraints { (make) in
            make.center.equalTo(recordButton)
            make.size.equalTo(CGSize(width: 200, height: 200))
        }
        animationView.animationSpeed = 0.9
        
        let tapView = UIView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tapView.isUserInteractionEnabled = true
        tapView.addGestureRecognizer(tapGesture)
        view.addSubview(tapView)
        tapView.snp.makeConstraints { (make) in
            make.leading.top.trailing.equalToSuperview()
            make.bottom.equalTo(contentView.snp.top)
        }
    }
    
    private func prepareRx() {
        isRecording
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (value) in
                DispatchQueue.main.async {
                    self?.updateRecordState(value)
                    if value {
                        self?.displayStart()
                    } else {
                        self?.displayStop()
                    }
                }
            }).disposed(by: bag)
        
        isPlaying
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (value) in
                guard let self = self, self.asset.audioPath.value != nil else { return }
                if value {
                    self.displayStart()
                    self.recordButton.setImage(DKImagePickerControllerResource.audioPause(), for: .normal)
                } else {
                    self.displayStop()
                    self.recordButton.setImage(DKImagePickerControllerResource.audioAudition(), for: .normal)
                }
                self.playerProgressView.isHidden = !value
            }).disposed(by: bag)
        
        asset.audioPath
            .distinctUntilChanged()
            .subscribe(onNext: { (audioPath) in
                if let path = audioPath {
                    
                } else {
                    
                }
            }).disposed(by: bag)
    }
    
    fileprivate func displayStart() {
        let dl = CADisplayLink(target: self, selector: #selector(displayAction(_:)))
        dl.add(to: .main, forMode: .default)
        displayLink = dl
    }
    
    fileprivate func displayStop() {
        displayLink?.remove(from: .main, forMode: .default)
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc func displayAction(_ sender: CADisplayLink) {
        
        if let recorder = audioRecorder, recorder.isRecording {
            // 录音
            let currentTime = recorder.currentTime
            if currentTime > 15 {
                stopRecord()
            } else {
                let minute: Int = 15 - Int(floor(currentTime))
                if minute > 5 {
                    timeLabel.text = "\(minute)s"
                    timeLabel.textColor = .white
                    timeLabel.font = UIFont.systemFont(ofSize: 18)
                } else {
                    timeLabel.text = "\(minute)"
                    timeLabel.textColor = UIColor(0xFF6885FF)
                    let fontSize: CGFloat = CGFloat(currentTime - floor(currentTime)) * 10
                    timeLabel.font = UIFont.boldSystemFont(ofSize: 28 - fontSize)
                }
            }
        } else if let player = audioPlayer, player.isPlaying {
            let duration = Int(round(player.duration))
            let time = max(duration - Int(round(player.currentTime)), 0)
            timeLabel.text = "\(time)s"
            playerProgressView.progress = Float(player.currentTime / player.duration)
        }
    }
    
    private func updateRecordState(_ recording: Bool) {
        if recording {
            recordTipsLabel.text = "松开完成录制"
            deleteButton.isHidden = true
            doneButton.isHidden = true
            animationView.isHidden = false
            animationView.play(fromProgress: 0,
                               toProgress: 1,
                               loopMode: .loop,
                               completion: nil)
        } else {
            animationView.stop()
            animationView.isHidden = true
            if asset.audioPath.value == nil {
                recordTipsLabel.text = "长按录制"
                timeLabel.text = ""
                recordButton.setImage(DKImagePickerControllerResource.audioRecord(), for: .normal)
            } else {
                recordTipsLabel.text = "试听"
            }
            deleteButton.isHidden = asset.audioPath.value == nil
            doneButton.isHidden = asset.audioPath.value == nil
        }
    }
    
    @objc func tapAction(_ tapGesture: UITapGestureRecognizer) {
        guard !isRecording.value else { return }
        dismiss()
    }
    
    @objc func recordAction(_ btn: UIButton) {
        
        if audioPlayer == nil {
            prepareToPlay()
        }
        
        if let path = asset.audioPath.value, let ap = audioPlayer {
            if ap.isPlaying {
                audioStop()
            } else {
                audioPlay()
            }
        }
    }
    
    @objc func longPressAction(_ gesture: UILongPressGestureRecognizer) {
        guard asset.audioPath.value == nil else { return }
        
        switch gesture.state {
        case .began:
            guard !prepareRecord else { break }
            startRecord()
        case .changed:
            break
        default:
            guard isRecording.value || prepareRecord else { break }
            stopRecord()
        }
    }
    
    @objc func deleteAction(_ btn: UIButton) {
        if isPlaying.value {
            audioStop()
        }
        audioRecorder?.deleteRecording()
        if FileManager.default.fileExists(atPath: audioPath) {
            try? FileManager.default.removeItem(atPath: audioPath)
        }
        asset.audioDuration = 0
        asset.audioPath.accept(nil)
        updateRecordState(false)
    }
    
    @objc func doneAction(_ btn: UIButton) {
        print("save audio...")
        dismiss()
    }
    
    fileprivate func dismiss() {
        displayLink?.invalidate()
        displayLink = nil
        
        if asset.audioDuration < 3 {
            try? FileManager.default.removeItem(atPath: audioPath)
        }
        
        dismiss(animated: true) {
            self.transitionController = nil
        }
    }
    
    // MARK: - Record
    
    private var audioRecorder: AVAudioRecorder?
    
    private let audioPath: String
    
    fileprivate func prepareRecordAtOnce() {
        guard audioRecorder == nil else { return }
        
        let settings: [String : Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
            
            let url = URL(fileURLWithPath: audioPath)

            let ar = try AVAudioRecorder(url: url, settings: settings)
            ar.delegate = self
            if ar.prepareToRecord() {
                audioRecorder = ar
                print("配置录音 \(audioPath)")
            } else {
                audioRecorder = nil
                print("启动音频录制失败")
            }
        } catch {
            audioRecorder = nil
            print("启动音频录制失败 \(error)")
        }
    }
    
    private func startRecord() {
        prepareRecord = true; defer { prepareRecord = false }
        prepareRecordAtOnce()
        guard let ar = audioRecorder else { return }
        ar.deleteRecording()
        if ar.record() {
            print("开始录音")
            isRecording.accept(true)
        }
    }
    
    private func stopRecord() {
        guard let ar = audioRecorder else { return }
        print("停止录制 \(ar.currentTime)")
        ar.stop()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        finishRecording(recorder)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("录制失败")
        finishRecording(recorder)
        if let e = error {
            print(e)
        }
    }
    
    fileprivate func finishRecording(_ recorder: AVAudioRecorder) {
        
        isRecording.accept(false)
        prepareToPlay() // 最小录制时间
        if audioPlayer != nil && audioPlayer!.duration >= 3 {
            asset.audioDuration = audioPlayer!.duration
            asset.audioPath.accept(audioPath)
        } else if recorder.currentTime > 3 {
            // 来电、Home退出等异常情况，无法prepareToPlay()
            asset.audioDuration = recorder.currentTime
            asset.audioPath.accept(audioPath)
        } else {
            recorder.deleteRecording()
            asset.audioDuration = 0
            asset.audioPath.accept(nil)
            // 弹出toast "录音不得少于3s"
            let hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud.isUserInteractionEnabled = false
            hud.mode = .text
            hud.label.text = "录音不得少于3s"
            hud.label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
            hud.label.textColor = .white
            hud.bezelView.backgroundColor = .black
            hud.margin = 8
            hud.hide(animated: true, afterDelay: 1.2)
        }
        updateRecordState(false)
    }
    
    // MARK: - Audio Player
    
    var audioPlayer: AVAudioPlayer?
    
    func prepareToPlay() {
        guard let url = URL(string: audioPath) else { return }

        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//            try AVAudioSession.sharedInstance().setActive(true)

            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            if player.prepareToPlay() {
                timeLabel.textColor = .white
                timeLabel.text = "\(Int(round(player.duration)))s"
                timeLabel.font = UIFont.systemFont(ofSize: 18)
                recordButton.setImage(DKImagePickerControllerResource.audioAudition(), for: .normal)
                audioPlayer = player
            } else {
                print("音频初始化失败")
            }
        } catch {
            print("音频初始化失败 \(error)")
        }
    }
    
    func audioPlay() {
        guard let player = audioPlayer else { return }
        
        player.currentTime = 0
        if player.play() {
            isPlaying.accept(true)
            recordButton.setImage(DKImagePickerControllerResource.audioPause(), for: .normal)
        } else {
            print("AudioPlayer play() failure.")
        }
    }
    
    func audioStop() {
        audioPlayer?.stop()
        isPlaying.accept(false)
        if let player = audioPlayer {
            timeLabel.text = "\(Int(round(player.duration)))s"
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying.accept(false)
        timeLabel.textColor = .white
        timeLabel.text = "\(Int(round(player.duration)))s"
        timeLabel.font = UIFont.systemFont(ofSize: 18)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        isPlaying.accept(false)
        timeLabel.textColor = .white
        timeLabel.text = "\(Int(round(player.duration)))s"
        timeLabel.font = UIFont.systemFont(ofSize: 18)
    }
}
