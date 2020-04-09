//
//  BadgeWebViewController.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/3/24.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit
import WebKit

@objc(CTBadgeWebViewController)
final class BadgeWebViewController: WebViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc
    convenience init(userId: String) {
        let cuid = UserCache.getCurrentUserID()
        // 是否为当前用户
        let typeValue = cuid == userId ? 0 : 1
        let urlStr = EnvConfig.share.h5BaseUrl() + "/appview/medal_wall/index?userId=\(userId)&type=\(typeValue)"
        self.init(url: URL(string: urlStr))
    }
    
    override func setup() {
        super.setup()
        showNavBar = false
    }
    
    override func prepareRx() {
        // 禁止父类rx绑定
    }
    
    override func openUrl(_ url: URL) {
        let vc = BadgeWebViewController(url: url)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func showErrorView(isNetworkError: Bool) {
        super.showErrorView(isNetworkError: isNetworkError)
        showNavBar = true
    }
    
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        super.webView(webView, didFinish: navigation)
        view.backgroundColor = UIColor(0x16122EFF)
        webView.isOpaque = false
    }
}
