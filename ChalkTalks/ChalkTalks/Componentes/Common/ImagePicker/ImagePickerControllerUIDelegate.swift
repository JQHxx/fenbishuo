//
//  ImagePickerControllerUIDelegate.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/24.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import UIKit

import DKImagePickerController

class ImagePickerControllerUIDelegate: DKImagePickerControllerBaseUIDelegate {
    
    // MARK: - Button
    
    override func createDoneButtonIfNeeded() -> UIButton {
        if let button = doneButton {
            return button
        }
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 82, height: 32)
        button.clipsToBounds = true
        button.layer.cornerRadius = 16
        updateDoneButtonTitle(button)
        doneButton = button
        
        return button
    }
    
    override func updateDoneButtonTitle(_ button: UIButton) {

        button.removeTarget(nil, action: nil, for: .allEvents)
        
        let ids: [DKAsset] = imagePickerController?.selectedAssets ?? []
        
        if ids.isEmpty {
            if let pc = imagePickerController as? ImagePickerController, pc.supportSkip {
                button.backgroundColor = UIColor(0xFF6885FF)
                button.setTitle("跳过", for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.addTarget(imagePickerController, action: #selector(imagePickerController.done), for: .touchUpInside)
            } else {
                button.backgroundColor = UIColor(0xDDDDDDFF)//.withAlphaComponent(0.3)
                button.setTitle("下一步", for: .normal)
                button.setTitleColor(UIColor(0xFFF9FAFF), for: .normal)
            }
        } else {
            button.backgroundColor = UIColor(0xFF6885FF) // UIColor(red: 1, green: 0.41, blue: 0.52, alpha: 1)
            button.setTitle("下一步", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.setTitleColor(UIColor(0xD2CECEFF), for: .highlighted)
            button.addTarget(imagePickerController, action: #selector(DKImagePickerController.done), for: .touchUpInside)
        }
//        _handleBarButtonBug(button: button)
    }
    
    private func _handleBarButtonBug(button: UIButton) {
        if #available(iOS 11.0, *) { // Handle iOS 11 BarButtonItems bug
            if button.constraints.count == 0 {
                button.widthAnchor.constraint(equalToConstant: button.bounds.width).isActive = true
                button.heightAnchor.constraint(equalToConstant: button.bounds.height).isActive = true
            } else {
                for constraint in button.constraints {
                    if constraint.firstAttribute == .width {
                        constraint.constant = button.bounds.width
                    } else if constraint.firstAttribute == .height {
                        constraint.constant = button.bounds.height
                    }
                }
            }
        }
    }
    
    override func prepareLayout(_ imagePickerController: DKImagePickerController, vc: UIViewController) {
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: createDoneButtonIfNeeded())
    }
    
    override func imagePickerController(_ imagePickerController: DKImagePickerController, showsCancelButtonForVC vc: UIViewController) {
        let cancelButton = UIButton(type: .custom)
        cancelButton.ss.prepare { (btn) in
            btn.setTitle("取消", for: .normal)
            // old UIColor(0x666666FF)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            btn.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        }
        cancelButton.addTarget(imagePickerController, action: #selector(imagePickerController.dismiss as () -> Void), for: .touchUpInside)
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
    }
    
    override func imagePickerControllerDidReachMaxLimit(_ imagePickerController: DKImagePickerController) {
        let imgPicker = imagePickerController as? ImagePickerController
        let suffix: String
        switch imgPicker?.type ?? .photo {
        case .photo, .pwa:
            suffix = "张照片"
        case .video:
            suffix = "个视频"
        }
        let alert = UIAlertController(title: "", message: "最多只能选择\(imagePickerController.maxSelectableCount)\(suffix)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "我知道了", style: .cancel, handler: nil))
        imagePickerController.present(alert)
    }
    
    // MAKR: - Cell
    
    override func imagePickerControllerCollectionImageCell() -> DKAssetGroupDetailBaseCell.Type {
        return ImagePickerDetailImageCell.self
    }
    
    override func imagePickerControllerCollectionVideoCell() -> DKAssetGroupDetailBaseCell.Type {
        return ImagePickerDetailVideoCell.self
    }
    
    override func imagePickerControllerGroupCell() -> DKAssetGroupCellType.Type {
        return ImagePickerGroupCell.self
    }
    
    override func imagePickerControllerSelectGroupButton(_ imagePickerController: DKImagePickerController, selectedGroup: DKAssetGroup) -> UIButton {
        return createGroupButton(isDropUp: true, title: selectedGroup.groupName ?? "")
    }
    
    override func imagePickerControllerCloseSelectGroupButton(_ imagePickerController: DKImagePickerController, selectedGroup: DKAssetGroup) -> UIButton {
        return createGroupButton(isDropUp: false, title: selectedGroup.groupName ?? "")
    }
    
    //
    
    private func createGroupButton(isDropUp: Bool, title: String) -> UIButton {
        let button = ImageButton(position: .right, spacing: 3)
        button.setTitle(title, for: .normal)
        // old UIColor(0x333333FF)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        let image = UIImage(named: isDropUp ? "nav_bar_drop_up" : "nav_bar_drop_down")
        button.setImage(image, for: .normal)
//        button.imageSize = CGSize(width: 34, height: 34)
        button.sizeToFit()
        button.frame = CGRect(x: 0, y: 0, width: button.width + 34 + button.spacing, height: 34)
        button.layoutSubviews()
        return button
    }
    
    override func videoCaptureRecordingView() -> DKVideoCaptureRecordingView {
        return VideoCaptureRecordingView()
    }
    
    override func createNew() -> DKImagePickerControllerBaseUIDelegate {
        return ImagePickerControllerUIDelegate()
    }
}
