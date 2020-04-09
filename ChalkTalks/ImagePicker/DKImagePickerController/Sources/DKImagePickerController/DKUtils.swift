//
//  DKUtils.swift
//  DKImagePickerController
//
//  Created by lizhuojie on 2020/1/15.
//

import UIKit
import Foundation

class DKUtils {
    
    static var isPhoneX: Bool = {
        return safaAreaBottom > 0
    }()
    
    static var statusBarHeight: CGFloat = {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 20
        } else {
            return 20
        }
    }()
    
    static var safaAreaBottom: CGFloat = {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        } else {
            return 0
        }
    }()
    
    static var audioDirectory: String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let directory = documentsPath + "/audios/"
        do {
            try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("创建audio文件夹失败 \(error)")
        }
        return directory
    }
    
    static var imageDirectory: String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let directory = documentsPath + "/images/"
        do {
            try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("创建image文件夹失败 \(error)")
        }
        return directory
    }
    
    static func newAudioPath() -> String {
        return audioDirectory + String(Int(Date().timeIntervalSince1970)) + ".m4a"
    }
}

extension UIColor {

    convenience init(hred: Int, hgreen: Int, hblue: Int, alpha: CGFloat = 1.0) {
        assert(hred >= 0 && hred <= 255, "Invalid red component")
        assert(hgreen >= 0 && hgreen <= 255, "Invalid green component")
        assert(hblue >= 0 && hblue <= 255, "Invalid blue component")
        assert(alpha >= 0.0 && alpha <= 1.0, "Invalid alpha component")

        self.init(red: CGFloat(hred) / 255.0,
                  green: CGFloat(hgreen) / 255.0,
                  blue: CGFloat(hblue) / 255.0,
                  alpha: CGFloat(alpha))
    }

    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(hred: (hex >> 16) & 0xFF,
                  hgreen: (hex >> 8) & 0xFF,
                  hblue: hex & 0xFF,
                  alpha: alpha)
    }

    convenience init(_ rgba: UInt32) {
        self.init(
            hred: Int(rgba >> 24) & 0xFF,
            hgreen: Int(rgba >> 16) & 0xFF,
            hblue: Int(rgba >> 8) & 0xFF,
            alpha: CGFloat(rgba & 0xFF) / 255.0
        )
    }
}
