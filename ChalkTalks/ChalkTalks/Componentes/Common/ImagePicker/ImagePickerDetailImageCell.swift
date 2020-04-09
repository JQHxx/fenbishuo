//
//  ImagePickerDetailImageCell.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/24.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import UIKit

import SnapKit
import DKImagePickerController

class ImagePickerDetailImageCell: DKAssetGroupDetailBaseCell {
    
    override class func cellReuseIdentifier() -> String {
        return "chalk.talks.image.picker.detail.image.cell"
    }
    
    fileprivate lazy var _thumbnailImageView: UIImageView = {
        let thumbnailImageView = UIImageView()
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        
        return thumbnailImageView
    }()
    
    override public var thumbnailImageView: UIImageView {
        get {
            return _thumbnailImageView
        }
    }
    
    override public var thumbnailImage: UIImage? {
        didSet {
            thumbnailImageView.image = thumbnailImage
        }
    }
    
    override var showCheckLabel: Bool {
        didSet {
            checkLabel.isHidden = !showCheckLabel
            selectMaskView.isHidden = !showCheckLabel
        }
    }
    
    fileprivate var selectMaskView: UIView = UIView()
    
    override var selectedIndex: Int {
        didSet {
            checkLabel.text = "\(selectedIndex + 1)"
        }
    }
    
    override var showMaskView: Bool {
        didSet {
            imageMaskView.isHidden = !showMaskView
        }
    }
    
    fileprivate let selectBtn: UIButton = UIButton()
    fileprivate let checkLabel: UILabel = UILabel()
    fileprivate let borderView: UIView = UIView()
    fileprivate let imageMaskView: UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        contentView.addSubview(thumbnailImageView)
        thumbnailImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        selectMaskView.ss.prepare { (view) in
            view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            contentView.addSubview(selectMaskView)
            selectMaskView.snp.makeConstraints({ $0.edges.equalToSuperview() })
            view.isHidden = true
        }
        
        let borderWidth: CGFloat = 2
        let borderHeight: CGFloat = 24
        contentView.addSubview(borderView)
        borderView.ss.prepare { (view) in
            view.backgroundColor = UIColor.black.withAlphaComponent(0.2)// UIColor(0xFF6885FF).withAlphaComponent(0.6)
            view.clipsToBounds = true
            view.layer.cornerRadius = borderHeight / 2
            view.layer.borderColor = UIColor.white.cgColor
            view.layer.borderWidth = borderWidth
        }
        borderView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(6)
            make.trailing.equalToSuperview().offset(-6)
            make.size.equalTo(CGSize(width: borderHeight, height: borderHeight))
        }
        
        contentView.addSubview(checkLabel)
        checkLabel.ss.prepare { (label) in
            label.clipsToBounds = true
            label.layer.cornerRadius = (borderHeight - 2 * borderWidth) / 2
            label.backgroundColor = UIColor(0xFF6885FF)
            label.textColor = .white
            label.font = UIFont.boldSystemFont(ofSize: 13)
            label.textAlignment = .center
        }
        checkLabel.snp.makeConstraints { (make) in
            make.center.equalTo(borderView)
            make.size.equalTo(CGSize(width: borderHeight - 2 * borderWidth, height: borderHeight - 2 * borderWidth))
        }
        checkLabel.isHidden = true
        
        contentView.addSubview(selectBtn)
        selectBtn.addTarget(self, action: #selector(selectAction(_:)), for: .touchUpInside)
        selectBtn.snp.makeConstraints { (make) in
            make.top.trailing.equalToSuperview()
            make.size.equalTo(CGSize(width: 36, height: 36))
        }
        
        contentView.addSubview(imageMaskView)
        imageMaskView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        imageMaskView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        imageMaskView.isHidden = true
    }
    
    @objc func selectAction(_ btn: UIButton) {
        guard let asset = asset, let vc = imagePickerController else { return }
        if vc.contains(asset: asset) {
            vc.deselect(asset: asset)
        } else {
            vc.select(asset: asset)
        }
    }
}
