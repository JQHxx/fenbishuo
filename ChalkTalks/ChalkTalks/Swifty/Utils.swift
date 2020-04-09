//
//  Utils.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/21.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import UIKit
import Foundation

public struct Utils {

    public static let navbarSpace: CGFloat = -8.0
    public static let navbarHeight: CGFloat = DeviceType.isPhoneX ? 88.0 : 64.0
    public static let tabbarHeight: CGFloat = DeviceType.isPhoneX ? 83.0 : 49
    public static let statusBarHeight: CGFloat = DeviceType.isPhoneX ? 44 : 20
    public static let safeAreaInsets: UIEdgeInsets = DeviceType.isPhoneX ? UIEdgeInsets(top: 44, left: 0, bottom: 34, right: 0) : UIEdgeInsets.zero
    
    /// 状态栏高度
    public static var statusHeight: CGFloat {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
        } else {
            return 0
        }
    }
    
    public static var bottomHeight: CGFloat {
       if #available(iOS 11.0, *) {
           return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
       } else {
           return 0
       }
    }
    
    /// 屏幕竖屏宽度
    public static let screenPortraitWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    /// 屏幕竖屏高度
    public static let screenPortraitHeight = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    
    /// 分割线宽度
    public static let splitWidth: CGFloat = 1.0 / UIScreen.main.scale
    
    public static func fixedSpacer(offset: CGFloat = navbarSpace) -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .fixedSpace,
                                   target: nil,
                                   action: nil)
        item.width = offset
        return item
    }
    
    public struct DeviceType {

        public static let identifier: String = {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            return identifier
        }()

        public static let modelName: String = {
            // https://www.theiphonewiki.com/wiki/Models
            switch identifier {
            case "iPod5,1": return "iPod Touch 5"
            case "iPod7,1": return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3": return "iPhone 4"
            case "iPhone4,1": return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2": return "iPhone 5"
            case "iPhone5,3", "iPhone5,4": return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2": return "iPhone 5s"
            case "iPhone7,2": return "iPhone 6"
            case "iPhone7,1": return "iPhone 6 Plus"
            case "iPhone8,1": return "iPhone 6s"
            case "iPhone8,2": return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3": return "iPhone 7"
            case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
            case "iPhone8,4": return "iPhone SE"
            case "iPhone10,1", "iPhone10,4": return "iPhone 8"
            case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6": return "iPhone X"
            case "iPhone11,8": return "iPhone XR"
            case "iPhone11,2": return "iPhone XS"
            case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
            case "iPhone12,1": return "iPhone 11"
            case "iPhone12,3": return "iPhone 11 Pro"
            case "iPhone12,5": return "iPhone 11 Pro Max"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3": return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6": return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3": return "iPad Air"
            case "iPad5,3", "iPad5,4": return "iPad Air 2"
            case "iPad6,11", "iPad6,12": return "iPad 5"
            case "iPad2,5", "iPad2,6", "iPad2,7": return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6": return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9": return "iPad Mini 3"
            case "iPad5,1", "iPad5,2": return "iPad Mini 4"
            case "iPad6,3", "iPad6,4": return "iPad Pro 9.7 Inch"
            case "iPad6,7", "iPad6,8": return "iPad Pro 12.9 Inch"
            case "iPad7,1", "iPad7,2": return "iPad Pro 12.9 Inch 2. Generation"
            case "iPad7,3", "iPad7,4": return "iPad Pro 10.5 Inch"
            case "iPad8,1": return "iPad Pro 3rd Gen (11 inch, WiFi)"
            case "iPad8,2": return "iPad Pro 3rd Gen (11 inch, 1TB, WiFi)"
            case "iPad8,3": return "iPad Pro 3rd Gen (11 inch, WiFi+Cellular)"
            case "iPad8,4": return "iPad Pro 3rd Gen (11 inch, 1TB, WiFi+Cellular)"
            case "iPad8,5": return "iPad Pro 3rd Gen (12.9 inch, WiFi)"
            case "iPad8,6": return "iPad Pro 3rd Gen (12.9 inch, 1TB, WiFi)"
            case "iPad8,7": return "iPad Pro 3rd Gen (12.9 inch, WiFi+Cellular)"
            case "iPad8,8": return "iPad Pro 3rd Gen (12.9 inch, 1TB, WiFi+Cellular)"
            case "AppleTV5,3": return "Apple TV"
            case "AppleTV6,2": return "Apple TV 4K"
            case "AudioAccessory1,1": return "HomePod"
            case "i386", "x86_64": return "Simulator"
            default: return identifier
            }
        }()

        public static let isPhone = UIDevice.current.userInterfaceIdiom == .phone
        public static let isPad = UIDevice.current.userInterfaceIdiom == .pad

        // iPhoneX尺寸 目前 iPhone X 高宽比：812/375 = 2.16533333 iPhone XR 和 iPhone XS Max 高宽比：896/414 = 2.16425121
        /// 是否为X系列刘海屏
        public static let isPhoneX = isPhone && (screenPortraitHeight / screenPortraitWidth) > 2.164251
    }
    
    public static var currentLocale: String {
        return ((Locale.current as NSLocale).object(forKey: NSLocale.Key.identifier) as? String) ?? "en_US"
    }

    public static var currentCurrencyCode: String {
        return ((Locale.current as NSLocale).object(forKey: NSLocale.Key.currencyCode) as? String) ?? "CNY"
    }

    public static var systemVersion: String {
        return UIDevice.current.systemVersion
    }

    public static var timeZone: String {
        return TimeZone.autoupdatingCurrent.identifier
    }

    public static var appName: String {
        return Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "iOS"
    }
    
    public static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }


    public static var buildVersion: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    public static var version: String {
        guard
            let dict = Bundle.main.infoDictionary,
            let version = dict["CFBundleShortVersionString"] as? String,
            let build = dict["CFBundleVersion"] as? String
        else {
            return ""
        }

        return "\(version)(\(build))"
    }
    
    public static var topVC: UIViewController? {
        let window = UIApplication.shared.windows.first(where: { $0.rootViewController != nil })
        return window?.rootViewController?.topVC
    }
    
    func generateObjectId() -> String {
        let data = NSMutableData()
        // get timestamp - first 4 bytes
        var date = UInt32(NSDate().timeIntervalSince1970).bigEndian
        data.append(&date, length: 4)
        // 3 bytes Just using a random number, but should be using device id and bigEndian
        var random1 = arc4random().bigEndian
        data.append(&random1, length: 3)
        // 2 bytes pid - big endian
        var pid = UInt32(ProcessInfo.processInfo.processIdentifier).bigEndian
        data.append(&pid, length: 2)
        // 3 bytes big endian counter - using a random number
        var random2 = arc4random().bigEndian
        data.append(&random2, length: 3)
        return data.map({ String(format: "%02hhX", $0) }).joined()
    }
}

public class Device {

    public static var orientation: UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }

    public static func isLandscape() -> Bool {
        return orientation.isLandscape
    }

    public static func screenLength() -> CGFloat {
        return max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
    }

    public static func screenWidth() -> CGFloat {
        return min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
    }

    public static func rotate() {
        let value: UIInterfaceOrientation = isLandscape() ? .portrait : .landscapeRight
        UIDevice.current.setValue(UIInterfaceOrientation.unknown.rawValue, forKey: "orientation")
        UIDevice.current.setValue(value.rawValue, forKey: "orientation")
    }
    
    public static func rotateToPortrait() {
        if isLandscape() {
            rotate()
        }
    }
}
