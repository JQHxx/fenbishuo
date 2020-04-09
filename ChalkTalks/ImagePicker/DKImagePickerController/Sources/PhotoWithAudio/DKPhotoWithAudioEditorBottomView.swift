//
//  DKPhotoWithAudioEditorBottomView.swift
//  DKImagePickerController
//
//  Created by lizhuojie on 2020/1/17.
//

import UIKit
import AVFoundation

import Lottie
import RxSwift

class DKPhotoWithAudioEditorBottomView: UIView, AVAudioPlayerDelegate {
    
    var addAudioView: UIStackView!
    fileprivate var bag: DisposeBag?
    
    weak var audioEditor: DKPhotoWithAudioEditor?
    
    fileprivate var animation: AnimationView?
    fileprivate var audioButton: UIView?
    fileprivate var timeLabel: UILabel?
    
    convenience init() {
        self.init(frame: .zero)
        self.prepare()
    }
    
    fileprivate func prepare() {
        
        let imageBtn = ImageButton(spacing: 6, position: .left)
        imageBtn.setTitle("添加语音", for: .normal)
        imageBtn.setTitleColor(UIColor(0x333333FF), for: .normal)
        imageBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        imageBtn.setImage(DKImagePickerControllerResource.audioAddRecord(), for: .normal)
        imageBtn.addTarget(self, action: #selector(addAction(_:)), for: .touchUpInside)
        imageBtn.clipsToBounds = true
        imageBtn.layer.cornerRadius = 19
        imageBtn.backgroundColor = .white
        
        let tipsLabel = UILabel()
        tipsLabel.text = "说说你对这张图的想法或见解"
        tipsLabel.textColor = UIColor(0x999999FF)
        tipsLabel.font = UIFont.systemFont(ofSize: 14)
        
        addAudioView = UIStackView(arrangedSubviews: [imageBtn, tipsLabel])
        addAudioView.alignment = .center
        addAudioView.axis = .vertical
        addAudioView.distribution = .equalSpacing
        addAudioView.spacing = 15
        
        imageBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 130, height: 38))
        }
        
        addSubview(addAudioView)
        addAudioView.snp.makeConstraints({ $0.center.equalToSuperview() })
    }
    
    fileprivate var _asset: DKAsset?
    
    func update(with asset: DKAsset) {
        _asset = asset
        bag = DisposeBag()
        asset.audioPath
            .subscribe(onNext: { [weak self] (path) in
                if let path = path {
                    self?.showAnimationView()
                    self?.addAudioView.isHidden = true
                } else {
                    self?.hideAnimationView()
                    self?.addAudioView.isHidden = false
                    self?.removeAudioPlayer()
                }
            }).disposed(by: bag!)
    }
    
    private func showAnimationView() {
        guard let duration = _asset?.audioDuration else { return }
        
        var name: String
        var size: CGSize
        if duration < 5 {
            name = "audio5"
            size = CGSize(width: 72, height: 38)
        } else if duration < 10 {
            name = "audio10"
            size = CGSize(width: 98, height: 38)
        } else {
            name = "audio15"
            size = CGSize(width: 130, height: 38)
        }
        
        if let ab = audioButton {
            ab.snp.remakeConstraints { (make) in
                make.center.equalToSuperview()
                make.size.equalTo(size)
            }
            timeLabel?.text = "\(Int(round(duration)))''"
            return
        }
        
        let ab = UIView()
        ab.clipsToBounds = true
        ab.layer.cornerRadius = 19
        ab.backgroundColor = UIColor(0xFF6885FF)
        ab.isUserInteractionEnabled = true
        addSubview(ab)
        ab.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(size)
        }
        audioButton = ab
        
        let av = AnimationView(name: name, animationCache: LRUAnimationCache.sharedCache)
        av.loopMode = .loop
        ab.addSubview(av)
        av.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        animation = av
        
        let time = UILabel()
        time.textColor = .white
        time.text = "\(Int(round(duration)))''"
        time.textAlignment = .right
        time.font = UIFont.systemFont(ofSize: 14)
        ab.addSubview(time)
        time.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
            make.width.equalTo(30)
        }
        timeLabel = time
        
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(audioAction(_:)), for: .touchUpInside)
        ab.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func hideAnimationView() {
        animation?.stop()
        animation?.removeFromSuperview()
        animation = nil
        timeLabel?.removeFromSuperview()
        timeLabel = nil
        audioButton?.removeFromSuperview()
        audioButton = nil
    }
    
    @objc func addAction(_ btn: UIButton) {
        guard let asset = _asset else { return }
        audioEditor?.showAudioRecorder(asset)
    }
    
    // MARK: - Audio Player
    
    private var audioPlayer: AVAudioPlayer?
    private var displayLink: CADisplayLink?
    
    @objc func audioAction(_ btn: UIControl) {
        guard let asset = _asset else { return }
        audioEditor?.showAudioRecorder(asset)
//        if audioPlayer == nil {
//            prepareAudioPlayer()
//        }
//
//        guard let ap = audioPlayer else { return }
//
//        if ap.isPlaying {
//            ap.stop()
//            displayStop()
//            animation?.stop()
//            let duration = Int(round(ap.duration))
//            timeLabel?.text = "\(duration)''"
//            print("停止播放")
//        } else {
//            ap.currentTime = 0
//            if ap.play() {
//                displayStart()
//                animation?.play()
//                print("开始播放")
//            } else {
//                print("AudioPlayer play() failure.")
//            }
//        }
    }
    
    private func prepareAudioPlayer() {
        guard
            let path = _asset?.audioPath.value,
            let url = URL(string: path)
            else { return }
        
        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//            try AVAudioSession.sharedInstance().setActive(true)

            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            if player.prepareToPlay() {
                audioPlayer = player
            } else {
                print("音频初始化失败")
            }
        } catch {
            print("音频初始化失败 \(error)")
        }
    }
    
    private func removeAudioPlayer() {
        audioPlayer?.stop()
        audioPlayer = nil
        displayStop()
        animation?.stop()
    }
    
    private func displayStart() {
        let dl = CADisplayLink(target: self, selector: #selector(displayAction(_:)))
        dl.add(to: .main, forMode: .default)
        displayLink = dl
    }
    
    private func displayStop() {
        displayLink?.remove(from: .main, forMode: .default)
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc func displayAction(_ display: CADisplayLink) {
        guard let player = audioPlayer else { return }
        let duration = Int(round(player.duration))
        let time = max(duration - Int(round(player.currentTime)), 0)
        timeLabel?.text = "\(time)''"
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        displayStop()
        animation?.stop()
        print("停止播放")
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        displayStop()
        animation?.stop()
        print("播放失败")
    }
}
