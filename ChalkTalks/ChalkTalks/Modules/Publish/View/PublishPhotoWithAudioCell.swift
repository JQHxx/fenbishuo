//
//  PublishPhotoWithAudioCell.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/1/19.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit

import SnapKit
import RxSwift
import SDWebImage

import DKImagePickerController

class PublishPhotoWithAudioCell: UICollectionViewCell {
    
    static let reuseIdentifier = "PublishPhotoWithAudioCell.douya.com"
    
    fileprivate weak var asset: DKAsset?
    var imageView: UIImageView = UIImageView()
    
    weak var viewModel: PublishPhotoWithAudioViewModel?
    
    fileprivate var coverView: UIView = UIView()
    fileprivate var tipsLabel: UILabel = UILabel()
    
    fileprivate let audioIcon = UIImageView()
    fileprivate let audioDuration = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    fileprivate func setup() {
        
        imageView.ss.prepare { (view) in
            contentView.addSubview(view)
            view.contentMode = .scaleAspectFill
            view.clipsToBounds = true
            view.layer.cornerRadius = 6
            view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        coverView.ss.prepare { (view) in
            contentView.addSubview(view)
            view.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
            view.clipsToBounds = true
            view.layer.cornerRadius = 6
            view.isHidden = true
            view.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        
        tipsLabel.ss.prepare { (view) in
            coverView.addSubview(view)
            view.textColor = .white
            view.font = UIFont.systemFont(ofSize: 14)
            view.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }
        }
        
        BaseButton(type: .custom).ss.prepare { (button) in
            button.setImage(UIImage(named: "publish_delete_item"), for: .normal)
            button.hitTestInset = UIEdgeInsets(top: -6, left: -6, bottom: -6, right: -6)
            button.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
            contentView.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(6)
                make.trailing.equalToSuperview().offset(-6)
                make.size.equalTo(CGSize(width: 20, height: 20))
            }
        }
        
        audioIcon.ss.prepare { (view) in
            view.image = UIImage(named: "audio_tag_icon")
            contentView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().offset(5)
                make.bottom.equalToSuperview().offset(-15)
                make.size.equalTo(CGSize(width: 19, height: 19))
            }
            view.isHidden = true
        }
        
        audioDuration.ss.prepare { (label) in
            label.font = UIFont.systemFont(ofSize: 10)
            label.textColor = UIColor(0xFF6885FF)
            contentView.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.centerX.equalTo(audioIcon)
                make.bottom.equalToSuperview().offset(-2)
            }
            label.isHidden = true
        }
    }
    
    fileprivate func showAudioInfo(duration: TimeInterval) {
        audioIcon.isHidden = false
        audioDuration.isHidden = false
        audioDuration.text = "\(Int(round(duration)))s"
    }
    
    fileprivate func hideAudioInfo() {
        audioIcon.isHidden = true
        audioDuration.isHidden = true
    }
    
    @objc func deleteAction(_ btn: UIButton) {
        guard let asset = asset else { return }
        viewModel?.delete(asset: asset)
    }
    
    fileprivate var bag: DisposeBag!
    
    func prepare(asset: DKAsset) {
        
        if asset.audioDuration > 1 {
            showAudioInfo(duration: asset.audioDuration)
        } else {
            hideAudioInfo()
        }
                
        self.asset = asset
        imageView.image = nil
        if let imagePath = asset.imagePath.value {
            DispatchQueue.global().async {
                var image: UIImage?
                if let thumbnail = asset.thumbnailImage {
                    image = thumbnail
                } else if asset.fromDraft {
                    image = UIImage.thumbnailImage(maxPixel: 160, path: imagePath)
                    asset.thumbnailImage = image
                } else {
                    if let path = SDImageCache.shared.cachePath(forKey: imagePath) {
                        image = UIImage.thumbnailImage(maxPixel: 160, path: path)
                        asset.thumbnailImage = image
                    } else {
                        image = SDImageCache.shared.imageFromCache(forKey: imagePath)
                    }
                }
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        } else {
            Logger.debug("不存在图片！！！\(asset)")
        }
        
        bag = DisposeBag()
        
        asset
            .uploadState
            .subscribe(onNext: { [weak self] (state) in
                guard let self = self else { return }
                switch state {
                case .wait:
                    self.coverView.isHidden = false
                    self.tipsLabel.text = "上传中"
                case .uploading:
                    self.coverView.isHidden = false
                case .success:
                    self.coverView.isHidden = true
                    self.tipsLabel.text = nil
                case .failure:
                    self.coverView.isHidden = false
                    self.tipsLabel.text = "上传失败"
                }
            }).disposed(by: bag)
        
        asset
            .uploadProgress
            .subscribe(onNext: { [weak self] (progress) in
                guard
                    let self = self,
                    let asset = self.asset,
                    asset.uploadState.value == .uploading
                    else { return }
                
                let format = "\(Int(round(progress * 100)))%"
                self.tipsLabel.text = format // String(format: "%.2f%%", arguments: [progress * 100])
            }).disposed(by: bag)
    }
}

// MARK: - Add

class PublishPhotoWithAudioAddCell: UICollectionViewCell {
    
    static let reuseIdentifier = "PublishPhotoWithAudioAddCell.douya.com"
    
    fileprivate let addImage: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    fileprivate func setup() {
        addImage.image = UIImage(named: "video_upload_more")
        contentView.addSubview(addImage)
        addImage.snp.makeConstraints({ $0.edges.equalToSuperview() })
    }
    
//    override func draw(_ rect: CGRect) {
//
//        let context: CGContext = UIGraphicsGetCurrentContext()!
//        UIGraphicsPushContext(context)
//
//        let color = UIColor(0xDDDDDDFF).cgColor
//        context.setStrokeColor(color)
//        context.setFillColor(color)
//
//        let width = Utils.splitWidth * 3
//        context.setLineWidth(width)
//        context.setLineCap(.round)
//        context.setLineJoin(.round)
//
//        let path = UIBezierPath(roundedRect: rect.insetBy(dx: 2, dy: 2), cornerRadius: 6)
//        let dashs: [CGFloat] = [7, 5]
//        context.addPath(path.cgPath)
//        context.setLineDash(phase: 0, lengths: dashs)
//        context.drawPath(using: .stroke)
//        context.strokePath()
//
//        context.setLineDash(phase: 0, lengths: [])
//
//        context.move(to: CGPoint(x: bounds.width / 2 - 16, y: bounds.height / 2))
//        context.addLine(to: CGPoint(x: bounds.width / 2 + 16, y: bounds.height / 2))
//
//        context.move(to: CGPoint(x: bounds.width / 2, y: bounds.height / 2  - 16))
//        context.addLine(to: CGPoint(x: bounds.width / 2, y: bounds.height / 2  + 16))
//
//        context.drawPath(using: .stroke)
//        context.strokePath()
//
//        UIGraphicsPopContext()
//    }
}

// MARK: - Header

class PublishPhotoWithAudioHeaderView: UICollectionReusableView {
    
    static let reuseIdentifier = "PublishPhotoWithAudioHeaderView.douya.com"
    
    let titleLabel: UILabel = UILabel()
    
    fileprivate let bottomLine: UIView = UIView()
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        addSubview(titleLabel)
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor(0x333333FF)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 16, bottom: 20, right: 16))
        }
        
        addSubview(bottomLine)
        bottomLine.backgroundColor = UIColor(0xF1F1F1FF)
        bottomLine.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(10)
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: - Footer

class PublishPhotoWithAudioFooterView: UICollectionReusableView {
    
    static let reuseIdentifier = "PublishPhotoWithAudioFooterView.douya.com"
        
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setup() {
        backgroundColor = .white
    }
}
