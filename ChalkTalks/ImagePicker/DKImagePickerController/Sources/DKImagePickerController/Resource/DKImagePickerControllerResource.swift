//
//  DKImagePickerControllerResource.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 15/8/11.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit

public class DKImagePickerControllerResource: NSObject {
    
    private static let cache = NSCache<NSString, UIImage>()
    
    // MARK: - Internationalization
    
    /// Add a hook for custom localization.
    @objc public static var customLocalizationBlock: ((_ title: String) -> String?)?
    
    public class func localizedStringWithKey(_ key: String, value: String? = nil) -> String {
        return customLocalizationBlock?(key) ?? NSLocalizedString(key,
                                                                  tableName: "DKImagePickerController",
                                                                  bundle:Bundle.imagePickerControllerBundle(),
                                                                  value: value ?? "",
                                                                  comment: "")
    }
    
    // MARK: - Images
    
    @objc public static var customImageBlock: ((_ imageName: String) -> UIImage?)?
	
    public class func checkedImage() -> UIImage {
        return imageForResource("checked_background", stretchable: true, cacheable: true)
            .withRenderingMode(.alwaysTemplate)
    }
    
    public class func blueTickImage() -> UIImage {
        return imageForResource("tick_blue", stretchable: false, cacheable: false)
    }
    
    public class func cameraImage() -> UIImage {
        return imageForResource("camera", stretchable: false, cacheable: false)
    }
    
    public class func videoCameraIcon() -> UIImage {
        return imageForResource("video_camera", stretchable: false, cacheable: true)
    }
    
    // audio record
    
    class func audioAddGuide() -> UIImage {
        return imageForResource("icon_addVoice_learningGuide_184x116", stretchable: false, cacheable: true)
    }
    
    class func audioAudition() -> UIImage {
        return imageForResource("audio_audition", stretchable: false, cacheable: true)
    }
    
    class func audioAddImage() -> UIImage {
        return imageForResource("audio_add_image", stretchable: false, cacheable: true)
    }
    
    class func audioDelete() -> UIImage {
        return imageForResource("audio_delete", stretchable: false, cacheable: true)
    }
    
    class func audioDone() -> UIImage {
        return imageForResource("audio_done", stretchable: false, cacheable: true)
    }
    
    class func audioResizer() -> UIImage {
        return imageForResource("audio_image_resizer", stretchable: false, cacheable: true)
    }
    
    class func audioRecord() -> UIImage {
        return imageForResource("audio_record", stretchable: false, cacheable: true)
    }
    
    class func audioTagIcon() -> UIImage {
        return imageForResource("audio_tag_icon", stretchable: false, cacheable: true)
    }
    
    class func audioPause() -> UIImage {
        return imageForResource("audio_pause", stretchable: false, cacheable: true)
    }
    
    class func audioAddImageBackgroud() -> UIImage {
        return imageForResource("audio_add_backgroud", stretchable: false, cacheable: true)
    }
    
    class func audioAddRecord() -> UIImage {
        return imageForResource("audio_new_record", stretchable: false, cacheable: true)
    }
    
    // photo capture
    
    class func whiteCloseIcon() -> UIImage {
        return imageForResource("white_close", stretchable: false, cacheable: true)
    }
    
    class func flashModeOn() -> UIImage {
        return imageForResource("flash_mode_on", stretchable: false, cacheable: true)
    }
    
    class func flashModeOff() -> UIImage {
        return imageForResource("flash_mode_off", stretchable: false, cacheable: true)
    }
    
    class func flashModeAuto() -> UIImage {
        return imageForResource("flash_mode_auto", stretchable: false, cacheable: true)
    }
    
    // video capture
    
    class func whiteBackIcon() -> UIImage {
        return imageForResource("white_back", stretchable: false, cacheable: true)
    }
    
    class func beautifulSelect() -> UIImage {
        return imageForResource("beautiful_unselect", stretchable: false, cacheable: true)
    }
    
    class func beautifulUnSelect() -> UIImage {
        return imageForResource("beautiful_select", stretchable: false, cacheable: true)
    }
    
    class func rotateCamera() -> UIImage {
        return imageForResource("rotate_camera", stretchable: false, cacheable: true)
    }
    
    class func recordNormalIcon() -> UIImage {
        return imageForResource("icon_record_normal", stretchable: false, cacheable: true)
    }
    
    class func deleteLastVideo() -> UIImage {
        return imageForResource("icon_shanchushangyiduan", stretchable: false, cacheable: true)
    }
    
    class func finishCapture() -> UIImage {
        return imageForResource("icon_xiayibu", stretchable: false, cacheable: true)
    }
    
    // photo gallery
	
	public class func emptyAlbumIcon() -> UIImage {
        return imageForResource("empty_album", stretchable: true, cacheable: false)
	}
    
    public class func photoGalleryCheckedImage() -> UIImage {
        return imageForResource("photoGallery_checked_image", stretchable: true, cacheable: true)
    }
    
    public class func photoGalleryUncheckedImage() -> UIImage {
        return imageForResource("photoGallery_unchecked_image", stretchable: true, cacheable: true)
    }
    
    public class func photoGalleryBackArrowImage() -> UIImage {
        return imageForResource("photoGallery_back_arrow", stretchable: false, cacheable: false)
            .withRenderingMode(.alwaysOriginal)
    }
    
    public class func imageForResource(_ name: String, stretchable: Bool = false, cacheable: Bool = false) -> UIImage {
        if let image = customImageBlock?(name) {
            return image
        }
        
        if cacheable {
            if let cache = self.cache.object(forKey: name as NSString) {
                return cache
            }
        }
        
        let bundle = Bundle.imagePickerControllerBundle()
        var image = UIImage(named: name, in: bundle, compatibleWith: nil) ?? UIImage()
        
        if stretchable {
            image = self.stretchImgFromMiddle(image)
        }
        
        if cacheable {
            self.cache.setObject(image, forKey: name as NSString)
        }
        
        return image
    }
    
    public class func stretchImgFromMiddle(_ image: UIImage) -> UIImage {
        let centerX = image.size.width / 2
        let centerY = image.size.height / 2
        return image.resizableImage(withCapInsets: UIEdgeInsets(top: centerY, left: centerX, bottom: centerY, right: centerX))
    }
    
}

private extension Bundle {
    
    class func imagePickerControllerBundle() -> Bundle {
        let assetPath = Bundle(for: DKImagePickerControllerResource.self).resourcePath!
        return Bundle(path: (assetPath as NSString).appendingPathComponent("DKImagePickerController.bundle"))!
    }
    
}
