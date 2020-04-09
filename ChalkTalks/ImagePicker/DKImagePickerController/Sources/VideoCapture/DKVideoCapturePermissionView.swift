//
//  DKVideoCapturePermissionView.swift
//  DKImagePickerController
//
//  Created by lizhuojie on 2020/1/10.
//

import UIKit
import AVFoundation

import SnapKit

class DKVideoCapturePermissionView: UIView {
    
    private let titleLabel = UILabel()
    private let subTitleLabel = UILabel()
    
    private let captureButton = UIButton(type: .custom)
    private let microPhoneButton = UIButton(type: .custom)
    
    private var captureGranted: Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    private var microPhoneGranted: Bool {
        return AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
    }
    
    private weak var parent: UIViewController?
    
    var authUpdate: (() -> Void)?
    
    convenience init(_ parent: UIViewController) {
        self.init(frame: .zero)
        self.parent = parent
        self.setup()
    }
    
    private func setup() {
        
        backgroundColor = .black
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.text = "分享到粉笔说"
        
        subTitleLabel.textColor = .gray
        subTitleLabel.font = UIFont.systemFont(ofSize: 17)
        subTitleLabel.text = "允许访问即可拍摄照片和视频。"
        
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        titleStack.alignment = .center
        titleStack.axis = .vertical
        titleStack.distribution = .equalSpacing
        titleStack.spacing = 9
        
        addSubview(titleStack)
        titleStack.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.87)
        }
        
        captureButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        captureButton.addTarget(self, action: #selector(captureAction(_:)), for: .touchUpInside)
        microPhoneButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        microPhoneButton.addTarget(self, action: #selector(microPhoneAction(_:)), for: .touchUpInside)
        let buttonStack = UIStackView(arrangedSubviews: [captureButton, microPhoneButton])
        buttonStack.alignment = .center
        buttonStack.axis = .vertical
        buttonStack.distribution = .equalSpacing
        buttonStack.spacing = 24
        
        addSubview(buttonStack)
        buttonStack.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(1.1)
        }
        
        updateButtons()
        
        let backButton = UIButton(type: .custom)
        backButton.setImage(DKImagePickerControllerResource.whiteBackIcon(), for: .normal)
        backButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(UIApplication.shared.statusBarFrame.height + 20)
            make.leading.equalToSuperview().offset(8)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
    }
    
    private func updateButtons() {
        if captureGranted {
            captureButton.setTitle("相机访问权限已启用", for: .normal)
            captureButton.setTitleColor(.gray, for: .normal)
            captureButton.isEnabled = false
        } else {
            captureButton.setTitle("允许访问相机", for: .normal)
            captureButton.setTitleColor(.systemBlue, for: .normal)
            captureButton.isEnabled = true
        }
        
        if microPhoneGranted {
            microPhoneButton.setTitle("麦克风访问权限已启用", for: .normal)
            microPhoneButton.setTitleColor(.gray, for: .normal)
            microPhoneButton.isEnabled = false
        } else {
            microPhoneButton.setTitle("启用麦克风访问权限", for: .normal)
            microPhoneButton.setTitleColor(.systemBlue, for: .normal)
            microPhoneButton.isEnabled = true
        }
    }
    
    @objc func captureAction(_ btn: UIButton) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { (_) in
                DispatchQueue.main.async { [weak self] in
                    self?.updateButtons()
                    self?.authUpdate?()
                }
            }
        } else {
            gotoSettings()
        }
    }
    
    @objc func microPhoneAction(_ btn: UIButton) {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        if status == .notDetermined {
            AVCaptureDevice.requestAccess(for: .audio) { (_) in
                DispatchQueue.main.async { [weak self] in
                    self?.updateButtons()
                    self?.authUpdate?()
                }
            }
        } else {
            gotoSettings()
        }
    }
    
    fileprivate func gotoSettings() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:]) { [weak self] (_) in
                self?.updateButtons()
            }
        }
    }
    
    @objc func close() {
        parent?.dismiss(animated: true, completion: nil)
    }
}
