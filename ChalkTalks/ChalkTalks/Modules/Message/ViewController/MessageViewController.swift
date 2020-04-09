//
//  MessageViewController.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/21.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import UIKit
import UserNotifications

import SnapKit
import RxSwift
import RxRelay

import JXCategoryView

@objc(CTMessageViewController)
final class MessageViewController: BaseViewController, UIScrollViewDelegate {
    
    fileprivate let scrollView: UIScrollView = UIScrollView()
    var controllers: [MessageViewSubController] = []
    
    /// 是否需要展示通知授权请求
    var needShowNotiAuthReq: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    
    override func setup() {
        super.setup()
        hidesBottomBarWhenPushed = false
        showNavBar = false
        showBackButton = false
        
        loadUnreadCount()
        
        PushManager.share.refreshReddotCallback = { [weak self] isSystemNotification in
            self?.loadUnreadCount()
            if isSystemNotification {
                self?.controllers.last?.tableView.mj_header?.beginRefreshing()
            } else {
                self?.controllers.first?.tableView.mj_header?.beginRefreshing()
            }
            return
        }
        
        checkNotificationAuthorization()
        
        NotificationCenter.default.rx
            .notification(Notification.Name(kLogoutedNotification))
            .subscribe(onNext: { [weak self] (_) in
                self?.updateReddotsState(UnreadCount())
            }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx
        .notification(Notification.Name(kLoginedNotification))
        .subscribe(onNext: { [weak self] (_) in
            self?.loadUnreadCount()
            self?.controllers.forEach({ $0.loadData(true) })
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx
            .notification(UIApplication.didBecomeActiveNotification)
            .subscribe(onNext: { [weak self] (_) in
                self?.checkNotificationAuthorization()
            }).disposed(by: disposeBag)
    }
    
    fileprivate func checkNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] (settings) in
            self?.needShowNotiAuthReq.accept(settings.authorizationStatus != .authorized)
        }
    }
    
    fileprivate var normalHeaderHeight: CGFloat {
        max(Utils.statusHeight, 20) + 44 + 0.5
    }
    
    fileprivate var authReqView: AuthReqView?
    
    override func prepareUI() {
        super.prepareUI()
        
        UIView().ss.prepare { (space) in
            space.backgroundColor = .white
            contentView.addSubview(space)
            space.snp.makeConstraints { (make) in
                make.leading.top.trailing.equalToSuperview()
                make.height.equalTo(max(Utils.statusHeight, 20))
            }
        }
        
        let headerViewHeight: CGFloat = normalHeaderHeight
        
        segmentView.ss.prepare { (segment) in
            contentView.addSubview(segment)
            // 不使用frame的话indicator不生效
            segment.frame = CGRect(x: 0, y: max(Utils.statusHeight, 20), width: Utils.screenPortraitWidth, height: 44)
            
            segment.titles = MessageType.tabs.map({ $0.title })
            segment.titleFont = UIFont.systemFont(ofSize: 16, weight: .medium)
            segment.titleSelectedColor = .black
            segment.titleColor = UIColor(0x999999FF)
            segment.isTitleColorGradientEnabled = true
            segment.isTitleLabelZoomScrollGradientEnabled = true
            segment.contentScrollView = scrollView
            
            let margin: CGFloat = 68
            segment.cellWidth = Utils.screenPortraitWidth / 2 - margin
            segment.contentEdgeInsetRight = margin
            segment.contentEdgeInsetLeft = margin
            segment.cellSpacing = 0
            
            let indicator = JXCategoryIndicatorLineView()
            indicator.indicatorColor = UIColor(0xFF6885FF)
            indicator.indicatorWidth = 23
            indicator.indicatorHeight = 2
            segment.indicators = [indicator]
        }
        
        UIView().ss.prepare { (line) in
            line.backgroundColor = UIColor(0xEEEEEEFF)
            contentView.addSubview(line)
            line.snp.makeConstraints { (make) in
                make.top.equalTo(segmentView.snp.bottom)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(0.5 / UIScreen.main.scale)
            }
        }
        
//        if showAuthReqView && authReqView == nil {
//            authReqView = AuthReqView().ss.prepare({ (view) in
//                contentView.addSubview(view)
//                view.snp.makeConstraints { (make) in
//                    make.top.equalTo(segmentView.snp.bottom).offset(0.5)
//                    make.leading.trailing.equalToSuperview()
//                    make.height.equalTo(AuthReqView.height)
//                }
//            })
//        }
        
        // Scroll view
        scrollView.ss.prepare { (view) in
            view.delegate = self
            contentView.addSubview(view)
            view.isPagingEnabled = true
            view.showsHorizontalScrollIndicator = false
            view.showsVerticalScrollIndicator = false
        }
        
        controllers = MessageType.tabs.map { MessageViewSubController(type: $0, pvc: self) }

        let contentHeight = Utils.screenPortraitHeight - Utils.tabbarHeight - headerViewHeight
        scrollView.frame = CGRect(x: 0, y: headerViewHeight, width: Utils.screenPortraitWidth, height: contentHeight)
        scrollView.contentSize = CGSize(width: CGFloat(controllers.count) * Utils.screenPortraitWidth, height: contentHeight)
        
        for (idx, vc) in controllers.enumerated() {
            scrollView.addSubview(vc.view)
            vc.parentController = self
            vc.view.frame = CGRect(x: CGFloat(idx) * Utils.screenPortraitWidth,
                                   y: 1,
                                   width: Utils.screenPortraitWidth,
                                   height: contentHeight)
            addChild(vc)
            vc.didMove(toParent: self)
        }
        
        contentView.bringSubviewToFront(segmentView)
    }
    
    fileprivate func updateSubViews() {
        let showAuthReqView = needShowNotiAuthReq.value
        let headerViewHeight: CGFloat = normalHeaderHeight + (showAuthReqView ? AuthReqView.height : 0)
        
        if showAuthReqView && authReqView == nil {
            authReqView = AuthReqView().ss.prepare({ (view) in
                contentView.addSubview(view)
                view.snp.makeConstraints { (make) in
                    make.top.equalTo(segmentView.snp.bottom).offset(0.5)
                    make.leading.trailing.equalToSuperview()
                    make.height.equalTo(AuthReqView.height)
                }
            })
        } else {
            authReqView?.removeFromSuperview()
            authReqView = nil
        }
        
        let contentHeight = Utils.screenPortraitHeight - Utils.tabbarHeight - headerViewHeight
        scrollView.frame = CGRect(x: 0, y: headerViewHeight, width: Utils.screenPortraitWidth, height: contentHeight)
        scrollView.contentSize = CGSize(width: CGFloat(controllers.count) * Utils.screenPortraitWidth, height: contentHeight)
        
        for (idx, vc) in controllers.enumerated() {
            vc.view.frame = CGRect(x: CGFloat(idx) * Utils.screenPortraitWidth,
                                   y: 1,
                                   width: Utils.screenPortraitWidth,
                                   height: contentHeight)
        }
    }
    
    override func prepareRx() {
        super.prepareRx()
        
        needShowNotiAuthReq
            .distinctUntilChanged()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (_) in
                self?.updateSubViews()
            }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUnreadCount()
        checkNotificationAuthorization()
        currentVC?.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currentVC?.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        currentVC?.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        currentVC?.viewDidDisappear(animated)
    }
    
    // MARK: - Segment Control
    
    fileprivate let segmentView: JXCategoryTitleView = JXCategoryTitleView()
    fileprivate let segmentDotView: UIView = UIView()
    fileprivate let segmentCountView: UILabel = UILabel()
    
    fileprivate func updateDot(isHidden: Bool) {
        guard segmentDotView.superview == nil else {
            segmentDotView.isHidden = isHidden
            return
        }
        
        let cell = segmentView.collectionView.cellForItem(at: IndexPath(row: 0, section: 0))
        guard !isHidden, let jxCell = cell  as? JXCategoryTitleCell else {
            return
        }
        
        segmentDotView.ss.prepare { (dot) in
            dot.backgroundColor = UIColor(0xFF5757FF)
            dot.clipsToBounds = true
            dot.layer.cornerRadius = 3
            jxCell.contentView.addSubview(dot)
            dot.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: 6, height: 6))
                make.leading.equalTo(jxCell.titleLabel.snp.trailing).offset(-1)
                make.bottom.equalTo(jxCell.titleLabel.snp.top).offset(1)
            }
        }
    }
    
    fileprivate func updateSystemNoti(count: Int) {
        let height: CGFloat = 15
        let width: CGFloat
        let text: String
        if count > 99 {
            width = 30
            text = "99+"
        } else {
            width = 15 + (count > 9 ? 6 : 0)
            text = "\(count)"
        }
        guard segmentCountView.superview == nil else {
            segmentCountView.isHidden = count <= 0
            segmentCountView.text = text
            segmentCountView.layer.cornerRadius = height / 2
            segmentCountView.snp.updateConstraints { (make) in
                make.size.equalTo(CGSize(width: width, height: height))
            }
            return
        }
        
        let cell = segmentView.collectionView.cellForItem(at: IndexPath(row: 1, section: 0))
        guard count > 0, let jxCell = cell  as? JXCategoryTitleCell else {
            return
        }
        
        segmentView.clipsToBounds = false
        segmentCountView.ss.prepare { (label) in
            label.backgroundColor = UIColor(0xFF5757FF)
            label.textColor = .white
            label.text = text
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
            label.layer.cornerRadius = height / 2
            label.clipsToBounds = true
            segmentView.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: width, height: height))
                make.leading.equalTo(jxCell.titleLabel.snp.trailing).offset(-3)
                make.bottom.equalTo(jxCell.titleLabel.snp.top).offset(3)
            }
        }
    }
    
    // MARK: - Page Control
    
    fileprivate var currentIndex: Int = 0
    fileprivate var currentVC: MessageViewSubController? {
        if currentIndex < controllers.count {
            return controllers[currentIndex]
        } else {
            return nil
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentIndex(scrollView.contentOffset.x)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCurrentIndex(scrollView.contentOffset.x)
    }
    
    func updateCurrentIndex(_ newOffsetX: CGFloat) {
        let new = Int(newOffsetX / Utils.screenPortraitWidth)
        if new < controllers.count, currentIndex != new {
            currentIndex = new
            let vc = controllers[new]
            vc.viewDidAppear(false)
        }
    }
    
    // 线程安全
    fileprivate var isLoading: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    var unreadCount: BehaviorRelay<UnreadCount> = BehaviorRelay<UnreadCount>(value: UnreadCount())
    
    func didReadCagegory(_ type: MessageType) {
        let new = unreadCount.value
        switch type {
        case .follower:
            new.all = max(0, new.all - new.follower)
            new.information -= new.follower
            new.follower = 0
        case .information:
            new.all = max(0, new.all - new.information)
            new.information = 0
        case .invite:
            new.all = max(0, new.all - new.invite)
            new.information -= new.invite
            new.invite = 0
        case .like:
            new.all = max(0, new.all - new.like)
            new.information -= new.like
            new.like = 0
        case .reply:
            new.all = max(0, new.all - new.reply)
            new.information -= new.reply
            new.reply = 0
        case .system:
            new.all = max(0, new.all - new.system)
            new.system = 0
        }
        unreadCount.accept(new)
        updateReddotsState(new)
    }
    
    func didReadOneMessage(_ type: MessageType) {
        let new = unreadCount.value
        switch type {
        case .follower:
            new.follower -= 1
        case .information:
            new.information -= 1
        case .invite:
            new.invite -= 1
        case .like:
            new.like -= 1
        case .reply:
            new.reply -= 1
        case .system:
            new.system -= 1
        }
        new.all -= 1
        unreadCount.accept(new)
        updateReddotsState(new)
    }
    
    func loadUnreadCount() {
        if isLoading.value || UserCache.isUserLogined() == .notLogin {
            return
        }
        isLoading.accept(true)
        
        let request = CTFMessageApi.getUnreadCount()
        request.requstApiComplete { [weak self] (success, data, error) in
            self?.isLoading.accept(false)
            guard
                success,
                let json = data as? [String: Any],
                let uc = UnreadCount(json)
                else { return }
            self?.unreadCount.accept(uc)
            self?.updateReddotsState(uc)
        }
    }
    
    fileprivate var reddotView: UIView?
    
    fileprivate func updateReddotsState(_ data: UnreadCount) {
//        JPUSHService.setBadge(data.all)
        
        if data.information > 0 {
            updateDot(isHidden: false)
        } else {
            updateDot(isHidden: true)
        }
        
        updateSystemNoti(count: data.system)
        
        controllers.forEach{( $0.updateHeaderSection() )}
        
        // TabBar
        guard
            data.all > 0,
            let tabbarVC = tabBarController,
            let count = tabbarVC.tabBar.items?.count,
            let nav = navigationController,
            let position = tabbarVC.viewControllers?.firstIndex(of: nav)
            else {
                reddotView?.isHidden = true
                tabBarController?.viewControllers?
                    .first(where: { $0 == navigationController })?
                    .tabBarItem.badgeValue = nil
                return
        }
        if data.system > 0, let tbi = tabbarVC.viewControllers?.first(where: { $0 == nav })?.tabBarItem {
            tbi.badgeValue = data.system > 99 ? "99+" : "\(data.system)"
            reddotView?.isHidden = true
            return
        } else {
            tabbarVC.viewControllers?.first(where: { $0 == nav })?.tabBarItem.badgeValue = nil
        }
        
        if reddotView == nil {
            reddotView = ReddotView(.tabbar).ss.prepare({ (view) in
                
                let column = Utils.screenPortraitWidth / CGFloat(count)
                let offset = column * (CGFloat(position) + 0.5) + 5
                
                tabbarVC.tabBar.addSubview(view)
                view.snp.makeConstraints { (make) in
                    make.leading.equalToSuperview().offset(offset)
                    make.top.equalToSuperview().offset(5)
                    make.size.equalTo(ReddotView.DotType.tabbar.size)
                }
            })
        } else {
            reddotView?.isHidden = false
        }
    }
    
    class UnreadCount {
        
        var all: Int = 0
        var information: Int = 0
        var reply: Int = 0
        var like: Int = 0
        var invite: Int = 0
        var follower: Int = 0
        var system: Int = 0
        
        init() {}
        
        init?(_ json: [String: Any]) {
            guard
                let all = json["all"] as? Int,
                let information = json["information"] as? Int,
                let reply = json["reply"] as? Int,
                let like = json["like"] as? Int,
                let invite = json["invite"] as? Int,
                let system = json["system"] as? Int,
                let follower = json["follower"] as? Int
                else { return nil }
            self.all = all
            self.information = information
            self.reply = reply
            self.like = like
            self.invite = invite
            self.system = system
            self.follower = follower
        }
    }
}

// MAKR: - AuthReqView

fileprivate class AuthReqView: BaseView {
    
    static let height: CGFloat = 38
    
    override func setup() {
        super.setup()
        
        backgroundColor = UIColor(0xFF6885FF)
        
        let icon = UIImageView().ss.prepare { (view) in
            view.image = UIImage(named: "icon_msg_auth_req")
            addSubview(view)
            view.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.leading.equalToSuperview().offset(16)
            }
        }
        
        UILabel().ss.prepare { (label) in
            label.font = UIFont.systemFont(ofSize: 13)
            label.textColor = .white
            label.text = "开启系统通知，不要错过任何精彩消息哦~"
            addSubview(label)
            label.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.leading.equalTo(icon.snp.trailing).offset(4)
            }
        }
        
        BaseButton().ss.prepare { (button) in
            button.clipsToBounds = true
            button.layer.cornerRadius = 6
            button.backgroundColor = UIColor(0x333333FF)
            button.setTitle("立即开启", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button.hitTestInset = UIEdgeInsets(top: -10, left: 0, bottom: -10, right: 0)
            button.addTarget(self, action: #selector(authAction(_:)), for: .touchUpInside)
            addSubview(button)
            button.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.trailing.equalToSuperview().offset(-16)
                make.size.equalTo(CGSize(width: 64, height: 24))
            }
        }
    }
    
    @objc func authAction(_ btn: UIButton) {
        PushManager.share.jumpToAuthSetting()
    }
}
