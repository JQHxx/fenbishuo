//
//  ImagePickerGroupCell.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/1/3.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit
import Photos

import DKImagePickerController

final class ImagePickerGroupCell: UITableViewCell, DKAssetGroupCellType {
    
    static var preferredHeight: CGFloat = 64
    
    fileprivate lazy var thumbnailImageView: UIImageView = {
        let thumbnailImageView = UIImageView()
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true

        return thumbnailImageView
    }()

    lazy var groupNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        return label
    }()

    lazy var totalCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
            } else {
                backgroundColor = .white
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .white

        contentView.addSubview(self.thumbnailImageView)
        contentView.addSubview(self.groupNameLabel)
        contentView.addSubview(self.totalCountLabel)
        
        thumbnailImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        groupNameLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(12)
        }
        
        totalCountLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalTo(groupNameLabel.snp.trailing).offset(8)
        }
    }
    
    func configure(with assetGroup: DKAssetGroup, tag: Int, dataManager: DKImageGroupDataManager, imageRequestOptions: PHImageRequestOptions) {
        self.tag = tag
        groupNameLabel.text = assetGroup.groupName
        if assetGroup.totalCount == 0 {
            thumbnailImageView.image = DKImagePickerControllerResource.emptyAlbumIcon()
        } else {
            dataManager.fetchGroupThumbnail(
                with: assetGroup.groupId,
                size: CGSize(width: ImagePickerGroupCell.preferredHeight, height: ImagePickerGroupCell.preferredHeight).toPixel(),
                options: imageRequestOptions) { [weak self] image, info in
                    if self?.tag == tag {
                        self?.thumbnailImageView.image = image
                    }
            }
        }
        totalCountLabel.text = String(assetGroup.totalCount)
    }
}
