//
//  DKAsset.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 15/12/13.
//  Copyright © 2015年 ZhangAo. All rights reserved.
//

import Photos

import RxSwift
import RxRelay
import SDWebImage

public extension CGSize {
	
    func toPixel() -> CGSize {
        let scale = UIScreen.main.scale
        
//        let screenHeight = max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
        return CGSize(width: self.width * scale, height: self.height * scale)
    }
}

@objc
public enum DKAssetType: Int {
    
    case photo
    
    case video
    
}

/**
 An `DKAsset` object represents a photo or a video managed by the `DKImagePickerController`.
 */
@objc
open class DKAsset: NSObject {
	
	@objc public private(set) var type: DKAssetType = .photo
	
    @objc public var localIdentifier: String
    
    /// Returns location, if its contained in original asser
    @objc public private(set) var location: CLLocation?
    
    /// play time duration(seconds) of a video.
    @objc public private(set) var duration: Double = 0
    
    /// The width, in pixels, of the asset’s image or video data.
    @objc public private(set) var pixelWidth: Int
    
    /// The height, in pixels, of the asset’s image or video data.
    @objc public private(set) var pixelHeight: Int
    
    @objc public private(set) var originalAsset: PHAsset?
    
    var lastSize: CGSize?
    var lastCacheImage: UIImage?
    
    @objc public var thumbnailImage: UIImage?
    
    /// 音频地址
    public var audioPath: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)
    public var audioDuration: TimeInterval = 0
    var isResized: Bool = false
    var isCroping: Bool = false
    public var audioImage: BehaviorRelay<UIImage?> = BehaviorRelay<UIImage?>(value: nil)
    public var imagePath: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)

    /// 上传状态
    public enum UploadState {
        case wait, uploading, success, failure
    }
    
    public var uploadProgress: BehaviorRelay<CGFloat> = BehaviorRelay<CGFloat>(value: 0)
    public var uploadState: BehaviorRelay<UploadState> = BehaviorRelay<UploadState>(value: .wait)
    public var imageUploadInfo: Any?
    public var audioUploadInfo: Any?
    public var uploadBag = DisposeBag()
    // OSSPutObjectRequest
    public weak var uploadObject: AnyObject?
    
    // 取自草稿箱
    public var fromDraft: Bool = false
    
//    deinit {
//        if let path = imagePath.value {
//            try? FileManager.default.removeItem(atPath: path)
//            SDImageCache.shared.removeImageFromMemory(forKey: path)
//            print("移除缓存图片文件")
//        }
//        if let path = audioPath.value {
//            try? FileManager.default.removeItem(atPath: path)
//            print("移除缓存音频文件")
//        }
//    }
    public init(imagePath: String) {
        self.localIdentifier = imagePath
        self.pixelWidth = 0
        self.pixelHeight = 0
        super.init()
        self.type == .photo
    }
    
	public init(originalAsset: PHAsset) {
        self.localIdentifier = originalAsset.localIdentifier
        self.location = originalAsset.location
        self.pixelWidth = originalAsset.pixelWidth
        self.pixelHeight = originalAsset.pixelHeight
		super.init()
		
		self.originalAsset = originalAsset
		
		let assetType = originalAsset.mediaType
		if assetType == .video {
			self.type = .video
			self.duration = originalAsset.duration
        }
	}
	
	public private(set) var image: UIImage?
	public init(image: UIImage) {
        self.localIdentifier = String(image.hash)
        self.pixelWidth = Int(image.size.width * image.scale)
        self.pixelHeight = Int(image.size.height * image.scale)
		super.init()
        
		self.image = image
        
        self.type = .photo
	}
	
	override open func isEqual(_ object: Any?) -> Bool {
        if let another = object as? DKAsset {
            if let image = self.image, let anotherImage = another.image {
                return image == anotherImage
            } else if self.image == nil && another.image == nil {
                return self.localIdentifier == another.localIdentifier
            } else {
                return false
            }
        }
        
        return false
	}
	
}

public extension AVAsset {
	
    @objc func calculateFileSize() -> Float {
        if let URLAsset = self as? AVURLAsset {
            var size: AnyObject?
            try! (URLAsset.url as NSURL).getResourceValue(&size, forKey: URLResourceKey.fileSizeKey)
            if let size = size as? NSNumber {
                return size.floatValue
            } else {
                return 0
            }
        } else if let _ = self as? AVComposition {
            var estimatedSize: Float = 0.0
            var duration: Float = 0.0
            for track in self.tracks {
                let rate = track.estimatedDataRate / 8.0
                let seconds = Float(CMTimeGetSeconds(track.timeRange.duration))
                duration += seconds
                estimatedSize += seconds * rate
            }
            return estimatedSize
        } else {
            return 0
        }
    }
    
}
