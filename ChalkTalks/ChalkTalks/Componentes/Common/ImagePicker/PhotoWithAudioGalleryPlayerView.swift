//
//  PhotoWithAudioGalleryPlayerView.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/2/1.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit
import AVFoundation

import DKImagePickerController
import DKPhotoGallery

import Lottie
import RxSwift
import SnapKit

class PhotoWithAudioGalleryPlayerView: BaseView, AVAudioPlayerDelegate {
    
    fileprivate var animation: AnimationView?
    fileprivate var audioButton: UIView?
    fileprivate var timeLabel: UILabel?
    
    fileprivate var asset: DKAsset?
    
    func prepare(item: DKPhotoGalleryItem) {
        
        removeAudioPlayer()

        guard
            let audioAsset = item.audioAsset as? DKAsset,
            let _ = audioAsset.audioPath.value else {
                isHidden = true
                return
        }
        
        isHidden = false
        animation?.removeFromSuperview()
        timeLabel?.removeFromSuperview()
        audioButton?.removeFromSuperview()
        animation = nil
        timeLabel = nil
        audioButton = nil
        
        asset = audioAsset
        
        var name: String
        var size: CGSize
        if audioAsset.audioDuration < 5 {
            name = "audio5"
            size = CGSize(width: 72, height: 38)
        } else if audioAsset.audioDuration < 10 {
            name = "audio10"
            size = CGSize(width: 98, height: 38)
        } else {
            name = "audio15"
            size = CGSize(width: 130, height: 38)
        }
        
        // 背景
        audioButton = UIView().ss.prepare({ (view) in
            view.clipsToBounds = true
            view.layer.cornerRadius = 19
            view.backgroundColor = UIColor(0xFF6885FF)
            view.isUserInteractionEnabled = true
            addSubview(view)
            view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
                make.size.equalTo(size)
            }
        })
        
        animation = AnimationView(name: name, animationCache: LRUAnimationCache.sharedCache).ss.prepare({ (view) in
            view.loopMode = .loop
            audioButton!.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        })
        
        timeLabel = UILabel().ss.prepare({ (view) in
            view.textColor = .white
            view.text = "\(Int(round(audioAsset.audioDuration)))''"
            view.textAlignment = .right
            view.font = UIFont.systemFont(ofSize: 14)
            audioButton!.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.trailing.equalToSuperview().offset(-10)
                make.width.equalTo(30)
            }
        })
        
        BaseButton(type: .custom).ss.prepare { (view) in
            view.backgroundColor = .clear
            view.addTarget(self, action: #selector(audioAction(_:)), for: .touchUpInside)
            view.hitTestInset = UIEdgeInsets(top: -8, left: 0, bottom: -8, right: 0)
            audioButton!.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            // 自动播放
//            audioAction(view)
        }
    }
    
    // MARK: - Audio Player
    
    private var audioPlayer: AVAudioPlayer?
    private var displayLink: CADisplayLink?
    
    @objc func audioAction(_ btn: UIButton) {
        if audioPlayer?.isPlaying ?? false {
            // audioPlayer?.stop()
            removeAudioPlayer()
            if let duration = asset?.audioDuration {
                timeLabel?.text = "\(Int(round(duration)))''"
            }
        } else {
            if audioPlayer == nil {
                prepareAudioPlayer()
            }
            audioPlayer?.play()
            animation?.play()
            displayStart()
        }
    }
    
    func removeAudioPlayer() {
        audioPlayer?.stop()
        audioPlayer = nil
        displayStop()
        animation?.stop()
    }
    
    private func prepareAudioPlayer() {
        guard
            let path = asset?.audioPath.value,
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
    
    private func displayStart() {
        displayStop()
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
        if let duration = asset?.audioDuration {
            timeLabel?.text = "\(Int(round(duration)))''"
        }
        print("停止播放")
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        displayStop()
        animation?.stop()
        if let duration = asset?.audioDuration {
            timeLabel?.text = "\(Int(round(duration)))''"
        }
        print("播放失败")
    }
}
