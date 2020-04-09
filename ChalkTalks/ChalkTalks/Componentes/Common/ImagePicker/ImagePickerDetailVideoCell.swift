//
//  ImagePickerDetailVideoCell.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/1/6.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit

import DKImagePickerController
import SnapKit

final class ImagePickerDetailVideoCell: ImagePickerDetailImageCell {
    
    override class func cellReuseIdentifier() -> String {
        return "chalk.talks.image.picker.detail.video.cell"
    }
    
    override func setup() {
        super.setup()
    }
    
    override weak public var asset: DKAsset? {
        didSet {
            if let asset = asset {
                let minutes: Int = Int(asset.duration) / 60
                let seconds: Int = Int(round(asset.duration)) % 60
                videoInfoView.text = String(format: "\(minutes):%02d", seconds)
            }
        }
    }
    
    fileprivate lazy var videoInfoView: UILabel = {
        let infoView = InfoLabel()
        infoView.textColor = .white
        infoView.font = UIFont.boldSystemFont(ofSize: 12)
        infoView.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        infoView.textAlignment = .center
        infoView.layer.cornerRadius = 8
        infoView.clipsToBounds = true
        
        addSubview(infoView)
        infoView.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(16)
        }
        return infoView
    }()
}

fileprivate final class InfoLabel: UILabel {
    
    let insets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += insets.left + insets.right
        size.height += insets.top + insets.bottom
        return size
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
}
