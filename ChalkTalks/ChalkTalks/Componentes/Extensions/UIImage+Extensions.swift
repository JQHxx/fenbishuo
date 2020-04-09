//
//  UIImage+Extensions.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/2/7.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit
import CoreFoundation
import ImageIO

import SDWebImage

extension UIImage {
    
    static func thumbnailImage(maxPixel: CGFloat, path: String) -> UIImage? {
        autoreleasepool {
            guard
                let data = (try? Data(contentsOf: URL(fileURLWithPath: path))) as CFData?,
                let src = CGImageSourceCreateWithData(data, nil)
                else { return nil }
            
            let options: CFDictionary = [
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceThumbnailMaxPixelSize: maxPixel,
            ] as CFDictionary
            
            guard let cgImage = CGImageSourceCreateThumbnailAtIndex(src, 0, options) else {
                return nil
            }
            return UIImage(cgImage: cgImage)
        }
    }
    
    static func thumbnailImageAsyc(maxPixel: CGFloat, path: String, callback: @escaping (UIImage?) -> ()) {
        DispatchQueue.global().async {
            let image = self.thumbnailImage(maxPixel: maxPixel, path: path)
            DispatchQueue.main.async {
                callback(image)
            }
        }
    }
    
    func thumbnailImage(_ size: CGSize, callback: @escaping (UIImage?) -> ()) {
        DispatchQueue.global().async {
            guard
                let data = self.pngData() as CFData?,
                let src = CGImageSourceCreateWithData(data, nil) else {
                    callback(nil)
                    return
            }

            let options: CFDictionary = [
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceThumbnailMaxPixelSize: 200,
            ] as CFDictionary
            
            guard let cgImage = CGImageSourceCreateThumbnailAtIndex(src, 0, options) else {
                callback(nil)
                return
            }
            callback(UIImage(cgImage: cgImage))
        }
    }
    
    var thumbnailImage: UIImage? {
        guard
            let data = self.pngData() as CFData?,
            let src = CGImageSourceCreateWithData(data, nil)
            else { return nil }

        let options: CFDictionary = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: 300,
        ] as CFDictionary
        
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(src, 0, options) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}
