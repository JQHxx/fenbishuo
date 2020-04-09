//
//  BaseViewController.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/21.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

@objc(CTBaseViewController)
open class BaseViewController: UIViewController {
    
    /// 替代VC.view，方便自定义
    public let contentView: UIView = UIView()
    
    /// Rx绑定释放
    public let disposeBag: DisposeBag = DisposeBag()
    
    /// 自定义NavigationBar
    public let navBar: NavigationBar = NavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: Utils.navbarHeight))
    public let navItem: UINavigationItem = UINavigationItem()
    
    public var showNavBar: Bool = true {
        didSet {
            updateNavigationBar()
        }
    }
    
    public var showBackButton: Bool = true
    public var backBar: UIBarButtonItem!
    public var backButton: UIButton!
    
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// VC设置，执行于viewDidLoad之前
    open func setup() {
        hidesBottomBarWhenPushed = true
        automaticallyAdjustsScrollViewInsets = false
        extendedLayoutIncludesOpaqueBars = false
        edgesForExtendedLayout = []
        fd_prefersNavigationBarHidden = true
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        prepareRx()
    }
    
    /// UI设置，执行于viewDidLoad
    open func prepareUI() {
        
        view.backgroundColor = .white
        
        backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "app_navback_btn"), for: .normal)
        backButton.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        backButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        
        backBar = UIBarButtonItem(customView: backButton)
        
        if showBackButton {
            if #available(iOS 11, *) {
                backButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 0)
                navItem.leftBarButtonItems = [
                    Utils.fixedSpacer(offset: -12),
                    backBar
                ]
            } else {
                navItem.leftBarButtonItems = [
                    Utils.fixedSpacer(offset: -12),
                    backBar
                ]
            }
        }
        
        navBar.items = [navItem]

        navBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0),
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)
        ]
        
        view.addSubview(navBar)
        updateNavigationBar()
        
        view.addSubview(contentView)
        contentView.clipsToBounds = true
        contentView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(navBar.snp.bottom)
        }

        view.bringSubviewToFront(navBar)
    }
    
    /// Rx绑定，执行于viewDidLoad
    open func prepareRx() {
        
    }
    
    @objc open func backAction(_ btn: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    /// 调整NavigationBar
    public func updateNavigationBar(isToLandscape: Bool? = nil) {

        guard navBar.superview != nil else {
            return
        }

        let isLandscape = isToLandscape ?? (navBar.supportLandscape && Device.isLandscape())
        if #available(iOS 11, *) {} else if isLandscape {
            navBar.setTitleVerticalPositionAdjustment(-5, for: .compact)
        }

        navBar.snp.remakeConstraints { make in
            make.leading.trailing.equalToSuperview()
            if isLandscape {
                make.height.equalTo(44)
            } else {
                make.height.equalTo(Utils.navbarHeight)
            }
            if self.showNavBar {
                self.navBar.isHidden = false
                make.top.equalToSuperview()
            } else {
                self.navBar.isHidden = true
                make.bottom.equalTo(self.view.snp.top)
            }
        }
    }
}
