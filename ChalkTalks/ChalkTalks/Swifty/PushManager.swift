//
//  PushManager.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/27.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import AudioToolbox
import UserNotifications
import AdSupport

import RxSwift
import RxCocoa

enum PushType: String {
    case question, answer, comment, user, system
}

@objc(CTPushManager)
class PushManager: NSObject, UNUserNotificationCenterDelegate {
    
    @objc static let share = PushManager()
        
    // App是否完全启动
    var didInitialize: Bool = false
    var saveNotificationUserInfo: (UIApplication, [AnyHashable: Any]?)?
    
    /// Bool: is system notification
    var refreshReddotCallback: ((Bool) -> Void)?
    
    private var _deviceToken: String?
    private var granted: Bool = false
    private let bag: DisposeBag = DisposeBag()
    
    private override init() {
        super.init()
        
        NotificationCenter.default
            .rx
            .notification(Notification.Name(rawValue: kLoginedNotification))
            .subscribe(onNext: { [weak self] (_) in
                self?.upload()
            }).disposed(by: bag)
        
        UNUserNotificationCenter.current().delegate = self

        // 快速进入当前开发VC
        #if DEBUG
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 200_000)) {
//            self.readMessageCategory(.invite)
//            let pwa = PublishPhotoWithAudioController(questionId: 280261368152588290,
//                                                      questionTitle: "话题标题话题标题话题标题话题标题话题标题话题标题话题标题话题标题话题标题话题标题")
//            Utils.topVC?.navigationController?.pushViewController(pwa, animated: true)
//        }
        #endif
    }
    
    // MARK: - 友盟推送
    
    @objc func setupUPush(launchOptions: [AnyHashable: Any]?) {
        #if DEBUG
        UMessage.openDebugMode(true)
        #endif
        let entity = UMessageRegisterEntity()
        entity.types = Int(
            UMessageAuthorizationOptions.alert.rawValue
            | UMessageAuthorizationOptions.sound.rawValue
            | UMessageAuthorizationOptions.badge.rawValue
        )
        UMessage.registerForRemoteNotifications(launchOptions: launchOptions, entity: entity) { (granted, error) in
            if granted {
                self.granted = granted
            } else {
                Logger.error("[PUSH] 注册友盟推送失败 \(String(describing: error))")
            }
        }
        UMessage.setBadgeClear(true) // 自动清空角标
        UMessage.setAutoAlert(false) // 前台运行收到Push时不弹出Alert框
    }
    
    // MARK: - Pure
    
    fileprivate var lastAuthReq: TimeInterval = 0
    fileprivate let authReqInterval: TimeInterval = 3 * 24 * 60 * 60 // 3天间隔
    fileprivate let kLastAuthReq: String = "com.fenbishuo.ios.noti.auth.req.key"
    
    /// 显示通知授权提示框
    @objc func showAuthReqAlertIfNeed() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .denied:
                DispatchQueue.main.async {
                    self.showAuthReqAlert()
                }
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, error in
                    if let error = error {
                        Logger.error("[PUSH] 通知授权失败 \(error)")
                    }
                }
            default:
                break
            }
        }
    }
    
    fileprivate func showAuthReqAlert() {
        // 授权间隔
        if lastAuthReq == 0 {
            lastAuthReq = UserDefaults.standard.double(forKey: kLastAuthReq)
        }
        let lastDate = Date(timeIntervalSince1970: lastAuthReq)
        let current = Date()
        // 自然天
        let date1 = Calendar.current.startOfDay(for: lastDate)
        let date2 = Calendar.current.startOfDay(for: current)
        let dayInterval = Calendar.current.dateComponents([.day],
                                                          from: date1,
                                                          to: date2).day ?? 0
        guard dayInterval > 2 else {
            return
        }
        
        lastAuthReq = current.timeIntervalSince1970
        UserDefaults.standard.set(lastAuthReq, forKey: kLastAuthReq)
        UserDefaults.standard.synchronize()
        NotificationAlert.showAuthReq()
    }
    
    public func jumpToAuthSetting() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
        }
    }
    
//    @objc func setup() {
//        let application = UIApplication.shared
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
//            guard let self = self else { return }
//            if granted {
//                // 用户允许进行通知
//                UNUserNotificationCenter.current().delegate = self
//            } else {
//                // 后期需要继续提示引导或者通知服务端
//            }
//        }
//        application.registerForRemoteNotifications()
//    }
    
    // 启动不重复处理旧消息 【ID1002728】
    private let appStartTime: TimeInterval = Date().timeIntervalSince1970
    
    /// 应用内接受到通知的处理方法
    @objc func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        completionHandler([])
        
        let current = Date().timeIntervalSince1970
        guard current - appStartTime > 3 else {
            Logger.info("[PUSH] 收到推送消息，启动多条:\nInApp: \(true)\nPayload: \(userInfo)")
            return
        }
        
        guard let payload = userInfo["extra"] as? [NSString: Any] else {
            Logger.info("[PUSH] 收到推送消息，无extra:\nInApp: \(true)\nPayload: \(userInfo)")
            return
        }
        
        // 徽章消息
        if let type = payload["type"] as? String, type == "badge",
            let resource = payload["resource"] as? String {
            
            Logger.info("[PUSH] 徽章消息 \(payload)")
            let values = resource.components(separatedBy: "|")
            guard
                values.count == 3,
                let typeValue = Int(values.first!),
                let badgeType = BadgeType(rawValue: typeValue), let level = Int(values.last!) else {
                return
            }
            BadgeAlert.show(badgeType, level: level)
        } else if let pushType = payload["pushType"] as? String, pushType == "app" {
            // 应用内通知
            Logger.info("[PUSH] 应用内通知 \(payload)")
            guard
                let messageTitle = payload["messageTitle"] as? String,
                let content = payload["messageContent"] as? String,
                let typeValue = payload["type"] as? String,
                let type = PushType(rawValue: typeValue),
                let resource = payload["resource"] as? String
                else { return }
            NotificationAlert.show(type, resource: resource, subTitle: messageTitle, title: content, payload: payload)
        } else {
            Logger.info("[PUSH] 收到推送消息:\nInApp: \(true)\nPayload: \(userInfo)")
            handleNotification(payload, inApp: true)
        }
    }
    
    /// 应用处于后台的处理方法
    @objc func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        Logger.info("收到推送消息:\nInApp: \(false)\nPayload: \(userInfo)")

        if response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self) ?? false {
            // 应用处于后台时的远程推送接收 必须加这句代码
            UMessage.didReceiveRemoteNotification(userInfo)
        } else {
            // 应用处于后台时的本地推送接收
        }
//        interceptApplication(UIApplication.shared, didReceiveRemoteNotification: response.notification.request.content.userInfo)
        if let payload = userInfo["extra"] as? [NSString: Any] {
            handleNotification(payload, inApp: true)
        }
        completionHandler()
        clearNotifications(center)
    }
    
    @objc func interceptApplication(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // device token提取
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        for i in 0 ..< deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        upload(tokenString)
    }
    
    @objc func interceptApplication(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        _deviceToken = nil
        upload("")
    }
    
//    @objc func interceptApplication(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]?) {
//
//        guard let info = userInfo as? [String: Any] else { return }
//
//        guard self.didInitialize else {
//            self.saveNotificationUserInfo = (application, userInfo)
//            return
//        }
//
//        // 是否在应用内推送。
//        let inApp = info["InApp"] as? String
//        let receivedInApp: Bool = inApp == "true"
//
//        handleNotification(info, inApp: receivedInApp)
//    }
    
    /// 系统消息处理
    /// - Parameters:
    ///   - payload: 消息内容
    ///   - inApp: 是否为应用内推送
    ///   - force: 是否强制跳转
    func handleNotification(_ payload: [AnyHashable : Any], inApp: Bool) {
        
        if let typeText = payload["type"] as? String, typeText == "system" {
            refreshReddotCallback?(true)
        } else {
            refreshReddotCallback?(false)
        }
        
        // 非应用内消息才做跳转
        guard !inApp else { return }
        
        // 邀请消息
        if let action = payload["action"] as? String, action == "QUESTION_INVITATION" {
            let inviteVC = MessageViewDetailController(type: .invite, pvc: nil)
            Utils.topVC?.navigationController?.pushViewController(inviteVC, animated: true)
            readMessageCategory(.invite)
            return
        }
        
        guard
            let typeText = payload["type"] as? String,
            let type = PushType(rawValue: typeText),
            let resource = payload["resource"] as? String,
            let topVC = UIApplication.shared.keyWindow?.rootViewController?.topVC
            else {
                return
        }
        
        var taskId = 0
        if let value = payload["taskId"] as? String {
            taskId = Int(value) ?? 0
        } else if let value = payload["taskId"] as? Int {
            taskId = value
        }
        metricsReport(type: typeText, tid: "\(taskId)", isPush: true)
        
        if type == .user {
            let user = CTFHomePageVC()
            user.schemaArgu = [
                "userId": resource
            ]
            user.hidesBottomBarWhenPushed = true
            topVC.navigationController?.pushViewController(user, animated: true)
        } else if type == .system, let url = URL(string: resource) {
            let web = WebViewController(url: url)
            topVC.navigationController?.pushViewController(web, animated: true)
        } else {
            var param: [String: Any]?
            if [PushType.answer, PushType.comment].contains(type) {
                let ids = resource.components(separatedBy: "|")
                if ids.count == 2 {
                    param = [
                        "questionId": ids[1],
                        "answerId": ids[0]
                    ]
                }
            } else {
                param = ["questionId": resource]
            }
            
            if let param = param {
                let topic = CTFTopicDetailsVC()
                topic.schemaArgu = param
                topic.hidesBottomBarWhenPushed = true
                topVC.navigationController?.pushViewController(topic, animated: true)
            }
        }
    }
    
    func upload(_ dt: String? = nil) {
        var token = dt ?? ""
        if token.isEmpty, let old = _deviceToken {
            token = old
        } else {
            _deviceToken = token
        }
        let request = CTFMessageApi.uploadDeviceToken(token)
        request.requstApiComplete { (success, _, _) in
            Logger.info("[PUSH] 上传DeviceToken \(success) \(token)")
        }
    }
    
    fileprivate func clearNotifications(_ current: UNUserNotificationCenter? = nil) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        if let current = current {
            current.removeAllPendingNotificationRequests()
            current.removeAllDeliveredNotifications()
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
    }
    
    fileprivate func readMessageCategory(_ type: MessageType) {
        var didRead = false
        defer {
            if !didRead {
                MessageViewBaseController(type: .invite, pvc: nil).readAllCategoryMessages()
            }
        }
        guard
            let tabbar = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController,
            let controllers = tabbar.viewControllers
            else { return }
        controllers.forEach { (vc) in
            guard
                let nav = vc as? UINavigationController,
                let root = nav.viewControllers.first as? MessageViewController
                else { return }
            if let sub = root.controllers.first {
                sub.readAllCategoryMessages(type)
                didRead = true
            }
        }
    }
    
    // MARK: - 消息点击统计
    
    func metricsReport(type: String, tid: String, isPush: Bool) {
        guard tid != "0" else {
            return
        }
        let request = CTFMessageApi.metricsReport(withType: type, taskId: tid, isPush: isPush)
        request.requstApiComplete { (success, _, _) in
            Logger.debug("上传消息点击统计 \(success)")
        }
    }
    
    // MARK: - Open URL
    
    @objc func canOpenUrl(_ url: URL) -> Bool {
        return url.absoluteString.hasPrefix("fenbishuo://")
    }
    
    @objc func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
//        let sendingAppID = options[.sourceApplication]
//        print("source application = \(sendingAppID ?? "Unknown")")
        
        // 解析URL
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
            let albumPath = components.path,
            let params = components.queryItems else {
                Logger.error("Open URL failed: \(url)")
                return false
        }
        
        Logger.info("Open URL: \(url)\n \(albumPath) \(params)")
        
        switch albumPath {
        case "/openanswer":
            // 跳转话题
            guard
                let answerId = params.first(where: { $0.name == "answerid" })?.value,
                let aid = Int(answerId),
                let questionId = params.first(where: { $0.name == "questionid" })?.value,
                let qid = Int(questionId)
                else { break }
            let vc = CTFTopicDetailsVC()
            vc.schemaArgu = [
                "questionId": qid,
                "answerId": aid
            ]
            vc.hidesBottomBarWhenPushed = true
            Utils.topVC?.navigationController?.pushViewController(vc, animated: true)
            return true
        case "/openquestion":
            // 跳转回答
            guard
                let questionId = params.first(where: { $0.name == "questionid" })?.value,
                let qid = Int(questionId)
                else { break }
            let vc = CTFTopicDetailsVC()
            vc.schemaArgu = [
                "questionId": qid
            ]
            vc.hidesBottomBarWhenPushed = true
            Utils.topVC?.navigationController?.pushViewController(vc, animated: true)
            return true
        default:
            break
        }
        Logger.error("Open URL failed: \(url)")
        return false
    }
}
