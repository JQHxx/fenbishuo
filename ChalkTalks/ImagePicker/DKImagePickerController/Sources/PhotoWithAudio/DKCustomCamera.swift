//
//  DKCustomCamera.swift
//  DKImagePickerController
//
//  Created by lizhuojie on 2020/2/6.
//

import UIKit
import AVFoundation
import CoreMotion
import ImageIO

import DKCamera

import SnapKit
import Lottie
import RxSwift
import RxCocoa

fileprivate class DKButton: UIButton {
    
    var hitTestInset: UIEdgeInsets?
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let inset = self.hitTestInset {
            return self.bounds.inset(by: inset).contains(point)
        }
        return super.point(inside: point, with: event)
    }
}

open class DKCustomCamera: DKCamera {
    
    enum CameraType {
        case photo, photoWithAudio
        var ratio: CGFloat {
            switch self {
            case .photo:
                return 3 / 4
            case .photoWithAudio:
                return 3.5 / 4
            }
        }
    }
    
    private let captureAnimationView = AnimationView(name: "capture", animationCache: LRUAnimationCache.sharedCache)
    private let disposeBag = DisposeBag()
    
    var type: CameraType = .photoWithAudio
    
    open override func setupUI() {
        
        captureButton = UIButton()
        cameraSwitchButton = UIButton()
        
        // hook UI
        view.addSubview(contentView)
        contentView.backgroundColor = .clear
        contentView.snp.makeConstraints({ $0.edges.equalToSuperview() })
        
        let buttonSize = CGSize(width: 25, height: 25)
        
        let cancelButton = DKButton(type: .custom)
        cancelButton.setImage(DKImagePickerControllerResource.whiteCloseIcon(), for: .normal)
        cancelButton.contentMode = .scaleAspectFit
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                self?.dismissCamera()
            }).disposed(by: disposeBag)
        cancelButton.hitTestInset = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        contentView.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(25)
            make.top.equalToSuperview().offset(26 + DKUtils.statusBarHeight)
            make.size.equalTo(buttonSize)
        }
        
        let flashButton = DKButton(type: .custom)
        flashButton.setImage(DKImagePickerControllerResource.flashModeAuto(), for: .normal)
        flashButton.contentMode = .scaleAspectFit
        flashButton.rx.tap
            .subscribe(onNext: { [weak self, weak flashButton] (_) in
                guard let self = self, let fb = flashButton else { return }
                self.switchFlashMode()
                switch self.flashMode {
                case .on:
                    fb.setImage(DKImagePickerControllerResource.flashModeOn(), for: .normal)
                case .off:
                    fb.setImage(DKImagePickerControllerResource.flashModeOff(), for: .normal)
                default:
                    // use audo
                    fb.setImage(DKImagePickerControllerResource.flashModeAuto(), for: .normal)
                }
            }).disposed(by: disposeBag)
        flashButton.hitTestInset = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        contentView.addSubview(flashButton)
        flashButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(cancelButton)
            make.size.equalTo(CGSize(width: 32, height: 32))
        }
        
        let cameraSwitchButton = DKButton(type: .custom)
        cameraSwitchButton.setImage(DKImagePickerControllerResource.rotateCamera(), for: .normal)
        cameraSwitchButton.contentMode = .scaleAspectFit
        cameraSwitchButton.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                self?.switchCamera()
            }).disposed(by: disposeBag)
        cameraSwitchButton.hitTestInset = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        contentView.addSubview(cameraSwitchButton)
        cameraSwitchButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-25)
            make.centerY.equalTo(cancelButton)
            make.size.equalTo(buttonSize)
        }
        
        let captureLabel = UILabel()
        captureLabel.text = "拍照"
        captureLabel.textColor = .white
        captureLabel.font = UIFont.boldSystemFont(ofSize: 15)
        contentView.addSubview(captureLabel)
        captureLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16 - DKUtils.safaAreaBottom)
        }

        contentView.addSubview(captureAnimationView)
        captureAnimationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(captureAction(_:))))
        captureAnimationView.isUserInteractionEnabled = true
        captureAnimationView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(captureLabel.snp.top).offset(-20)
            make.size.equalTo(CGSize(width: 72, height: 72))
        }
    }
    
    @objc private func captureAction(_ sender: UITapGestureRecognizer) {
        captureAnimationView.play()
        takePicture()
    }
    
    open override func setupSession() {
        super.setupSession()
        
        previewView.snp.makeConstraints { (make) in
            switch type {
            case .photo:
                make.leading.top.trailing.equalToSuperview()
            case .photoWithAudio:
                if UIScreen.main.bounds.width > 375 {
                    make.center.equalToSuperview()
                } else {
                    make.center.equalToSuperview().dividedBy(1.15)
                }
                make.width.equalToSuperview()
            }
            make.height.equalTo(view.bounds.width / type.ratio)
        }
    }
}
