//
//  EnvConfig.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/1/2.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import Foundation

enum Channel: String, CaseIterable {
    
    case appstore = "应用商店"
    case adhoc = "内部测试"
    case development = "开发版"
    
}

enum EnvType: String, CaseIterable {
    
    case prod = "生产环境"
    case dev = "开发环境"
    case test = "测试环境"
    case preview = "预发环境"
    
    var baseUrl: String {
        switch self {
        case .prod:
            return "https://api.fenbishuo.com"
        case .dev:
            return "https://api-dev.fenbishuo.com"
        case .test:
            return "https://api-testing.fenbishuo.com"
        case .preview:
            return "https://api-preview.fenbishuo.com"
        }
    }
    
    var h5BaseUrl: String {
        switch self {
        case .prod:
            return "https://m.fenbishuo.com"
        case .dev:
            return "https://m-dev.fenbishuo.com"
        case .test:
            return "https://m-testing.fenbishuo.com"
        case .preview:
            return "https://m-preview.fenbishuo.com"
        }
    }
    
    var apiKey: String {
        if self == .prod || self == .preview {
            return "NJgTo1HG0ChIEybp"
        } else {
            return "test"
        }
    }
    
    var apiSecret: String {
        if self == .prod || self == .preview {
            return "rwBUf3S8DvhAsbUcQ6p9B1RsnrJQtVft"
        } else {
            return "test"
        }
    }
    
    var aliBucketName: String {
        return (self == .prod || self == .preview) ? "fbs-pic1" : "dev-fbs-pic1"
    }
    
    var audioBucketName: String {
        return (self == .prod || self == .preview) ? "fbs-audio1" : "dev-fbs-audio1"
    }
}

@objc(CTENVConfig)
final class EnvConfig: NSObject {
    
    @objc static let share: EnvConfig = EnvConfig()
    
    private let kEnv: String = "com.fenbishuo.chalktalks.env.key"
    private let kNewUserKey: String = "kNewUserKey"
    
    private(set) var envType: EnvType
    
    let channel: Channel
    
    private let lock: NSLock = NSLock()
    
    /// 切换环境通知
    @objc static let kChangedEnvNotification: String = "com.fenbishuo.chalktalks.env.changed"
    
    private override init() {
        if let env = UserDefaults.standard.string(forKey: kEnv), let envType = EnvType(rawValue: env) {
            self.envType = envType
        } else {
            // 默认环境
            #if DEBUG
            self.envType = .dev
            #else
            self.envType = .prod
            #endif
        }
        
        #if DEBUG
        self.channel = .development
        #elseif ADHOC
        self.channel = .adhoc
        #else
        self.channel = .appstore
        #endif
        
        #if DEBUG
        let loginKey = BackdoorViewController.phoneLoginStoreKey
        if UserDefaults.standard.string(forKey: loginKey) == nil {
            UserDefaults.standard.set("", forKey: loginKey)
        }
        #endif
        
        super.init()
    }
    
    func update(type: EnvType) {
        lock.lock(); defer {
            lock.unlock()
            NotificationCenter.default.post(name: Notification.Name(rawValue: EnvConfig.kChangedEnvNotification), object: nil)
        }
        envType = type
        UserDefaults.standard.set(type.rawValue, forKey: kEnv)
        UserDefaults.standard.set(false, forKey:kNewUserKey)
        UserDefaults.standard.synchronize()
        UserCache.clear()
    }
    
    @objc func baseUrl() -> String {
        lock.lock(); defer { lock.unlock() }
        return envType.baseUrl
    }
    
    @objc func h5BaseUrl() -> String {
        lock.lock(); defer { lock.unlock() }
        return envType.h5BaseUrl
    }
    
    @objc func isAppStore() -> Bool {
        return channel == .appstore
    }
    
    @objc func isProdEnv() -> Bool {
        return envType == .prod
    }
    
    @objc func apiKey() -> String {
        lock.lock(); defer { lock.unlock() }
        return envType.apiKey
    }
    
    @objc func apiSecret() -> String {
        lock.lock(); defer { lock.unlock() }
        return envType.apiSecret
    }
    
    @objc func aliBucketName() -> String {
        lock.lock(); defer { lock.unlock() }
        return envType.aliBucketName
    }
    
    @objc func audioBucketName() -> String {
        lock.lock(); defer { lock.unlock() }
        return envType.audioBucketName
    }
    
    @objc func enablePhoneLogin() -> Bool {
        return UserDefaults.standard.string(forKey: BackdoorViewController.phoneLoginStoreKey) != nil
    }
}
