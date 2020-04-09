//
//  DKPhotoWithAudioCell.swift
//  DKImagePickerController
//
//  Created by lizhuojie on 2020/1/15.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

class DKPhotoWithAudioCell: UICollectionViewCell {
    
    fileprivate var asset: DKAsset?
    fileprivate var imageView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func setup() {
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func prepare(asset: DKAsset) {
        self.asset = asset
        updateUI(asset)
    }
    
    var bag: DisposeBag?
    
    func updateUI(_ asset: DKAsset) {
        if let image = asset.audioImage.value {
            imageView.image = image
        } else if let image = asset.lastCacheImage {
            imageView.image = image
        }
        
        bag = DisposeBag()
        asset.audioImage
//            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (image) in
                guard let self = self, let image = image else { return }
                self.imageView.image = image
            }).disposed(by: bag!)
    }
}

// MARK: - PhotoWithAudio Index

class DKPhotoWithAudioIndexLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        scrollDirection = .horizontal
        sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        minimumInteritemSpacing = 8
        if let cBounds = collectionView?.bounds, cBounds != .zero {
            // 60 : 68
            let height: CGFloat = cBounds.height - 20
            let width: CGFloat = height * 3.5 / 4
            itemSize = CGSize(width: width, height: height)
        }
    }
}

class DKPhotoWithAudioIndexCell: DKPhotoWithAudioCell {
    
    static let reuseIdentifier = "DKPhotoWithAudioIndexCell.douya.com"

    private let audioImageView: UIImageView = UIImageView()
    
    private var audioBag: DisposeBag!
    
    override func setup() {
        super.setup()
        
        contentView.addSubview(audioImageView)
        audioImageView.backgroundColor = UIColor(0xFF6885FF)
        audioImageView.clipsToBounds = true
        audioImageView.layer.cornerRadius = 8
        audioImageView.image = DKImagePickerControllerResource.audioTagIcon()
        audioImageView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(6)
            make.bottom.equalToSuperview().offset(-6)
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
        audioImageView.isHidden = true
    }
    
    var showBorder: Bool = false {
        didSet {
            if showBorder {
                layer.borderColor = UIColor(0xFF6885FF).cgColor
                layer.borderWidth = 2
            } else {
                layer.borderColor = UIColor.clear.cgColor
                layer.borderWidth = 0
            }
        }
    }
    
    override func updateUI(_ asset: DKAsset) {
        super.updateUI(asset)
        audioBag = DisposeBag()
        asset.audioPath.map({ $0 == nil }).bind(to: audioImageView.rx.isHidden).disposed(by: audioBag)
    }
}

// MARK: - PhotoWithAudio Content

class DKPhotoWithAudioContentLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        scrollDirection = .horizontal
        sectionInset = .zero
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        
        if let cBounds = collectionView?.bounds, cBounds != .zero {
            itemSize = CGSize(width: cBounds.width, height: cBounds.height)
        }
    }
}

class DKPhotoWithAudioContentCell: DKPhotoWithAudioCell {
    
    static let reuseIdentifier = "DKPhotoWithAudioContentCell.douya.com"
    
    weak var audioEditor: DKPhotoWithAudioEditor?
    
    fileprivate var originalImage: UIImage?
    
    override func setup() {
        super.setup()
        
        imageView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
        
        let buttonSize: CGSize = CGSize(width: 64, height: 24)
        
        let deleteButton = ImageButton(spacing: 3, position: .left)
        deleteButton.setTitle("删除", for: .normal)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        deleteButton.setImage(DKImagePickerControllerResource.audioDelete(), for: .normal)
        deleteButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        deleteButton.clipsToBounds = true
        deleteButton.layer.cornerRadius = 12
        deleteButton.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
        contentView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { (make) in
            make.leading.equalTo(imageView).offset(10)
            make.bottom.equalTo(imageView).offset(-10)
            make.size.equalTo(buttonSize)
        }
        
        let editButton = ImageButton(spacing: 2, position: .left)
        editButton.setTitle("调整", for: .normal)
        editButton.setTitleColor(.white, for: .normal)
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        editButton.setImage(DKImagePickerControllerResource.audioResizer(), for: .normal)
        editButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        editButton.clipsToBounds = true
        editButton.layer.cornerRadius = 12
        editButton.addTarget(self, action: #selector(editAction(_:)), for: .touchUpInside)
        contentView.addSubview(editButton)
        editButton.snp.makeConstraints { (make) in
            make.trailing.equalTo(imageView).offset(-10)
            make.bottom.equalTo(imageView).offset(-10)
            make.size.equalTo(buttonSize)
        }
    }
    
    override func updateUI(_ asset: DKAsset) {
        super.updateUI(asset)
        if asset.audioImage.value == nil {
            asset.fetchImage(with: CGSize(width: 1080, height: 1080 * 4 / 3.5)) { [weak self] (image, _) in
                if let image = image {
                    asset.audioImage.accept(image)
                    self?.originalImage = image
                }
            }
        }
    }
    
    @objc func deleteAction(_ btn: UIButton) {
        guard let asset = asset else { return }
        audioEditor?.deleteImage(asset)
    }
    
    @objc func editAction(_ btn: UIButton) {
        guard let asset = asset else { return }
        if let om = originalImage {
            audioEditor?.resizerImage(om, asset)
        } else {
            asset.fetchImage(with: CGSize(width: 1080, height: 1080 * 4 / 3.5)) { [weak self] (image, _) in
                if let image = image {
                    self?.audioEditor?.resizerImage(image, asset)
                    self?.originalImage = image
                }
            }
        }
    }
}

// MARK: - PhotoWithAudio Add

class DKPhotoWithAudioAddCell: DKPhotoWithAudioCell {
    
    static let reuseIdentifier: String = "DKPhotoWithAudioAddCell.douya.com"
    
    override func setup() {
        super.setup()
        
        let iconView = UIImageView(image: DKImagePickerControllerResource.audioAddImage())
        let titleLabel = UILabel()
        titleLabel.textColor = .white
        titleLabel.text = "添加图片"
        titleLabel.font = UIFont.systemFont(ofSize: 10)
        
        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.alignment = .center
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 3
        
        contentView.addSubview(stack)
        stack.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        imageView.image = DKImagePickerControllerResource.audioAddImageBackgroud()
    }
}

// MARK: - ImageButton

class ImageButton: UIButton {
    
    let position: Position
    let spacing: CGFloat
    var hitTestInset: UIEdgeInsets?
    
    enum Position {
        case left, top
    }
    
    init(spacing: CGFloat, position: Position) {
        self.position = position
        self.spacing = spacing
        self.hitTestInset = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        super.init(frame: .zero)
        self.titleLabel?.textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel?.sizeToFit()
        let labelSize = titleLabel?.frame.size ?? CGSize.zero
        let imageSize = imageView?.frame.size ?? CGSize.zero
        
        let totalWidth = labelSize.width + imageSize.width + spacing
        let totalHeight = labelSize.height + imageSize.height + spacing
        
        var imageFrame = CGRect.zero
        var labelFrame = CGRect.zero
        
        switch position {
        case .left:
            imageFrame = CGRect(x: self.bounds.width / 2.0 - totalWidth / 2.0,
                                y: self.bounds.height / 2.0 - imageSize.height / 2.0,
                                width: imageSize.width,
                                height: imageSize.height)
            labelFrame = CGRect(x: imageFrame.maxX + spacing,
                                y: self.bounds.height / 2.0 - labelSize.height / 2.0,
                                width: labelSize.width,
                                height: labelSize.height)
        case .top:
            imageFrame = CGRect(x: self.bounds.width / 2.0 - imageSize.width / 2.0,
                                y: self.bounds.height / 2.0 - totalHeight / 2.0,
                                width: imageSize.width,
                                height: imageSize.height)
            labelFrame = CGRect(x: 5,
                                y: imageFrame.maxY + spacing,
                                width: self.bounds.width - 10,
                                height: labelSize.height)
        default:
            break
        }
        
        
        titleLabel?.frame = labelFrame
        imageView?.frame = imageFrame
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {

        if let inset = self.hitTestInset {
            return self.bounds.inset(by: inset).contains(point)
        }

        return super.point(inside: point, with: event)
    }
}
