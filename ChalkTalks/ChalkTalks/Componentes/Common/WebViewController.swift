//
//  WebViewController.swift
//  ChalkTalks
//
//  Created by lizhuojie on 2020/1/11.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

import UIKit
import WebKit

import RxSwift
import RxCocoa

@objc(CTWebViewController)
open class WebViewController: BaseViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    public fileprivate(set) var webView: WKWebView!
    
    public fileprivate(set) var url: URL?
    
    convenience init(url: URL?) {
        self.init()
        self.url = url
    }
    
    open func buildWKUserContentController() -> WKUserContentController {
        return WKUserContentController().ss.prepare { content in
            content.add(BaseWebViewControllerLeakAvoider(self), name: "fenbishuo")
            content.add(BaseWebViewControllerLeakAvoider(self), name: "openUrl")
        }
    }
    
    override open func prepareUI() {
        super.prepareUI()
        
        let content = buildWKUserContentController()
        
        let config = WKWebViewConfiguration().ss.prepare { object in
            object.userContentController = content
            object.preferences.javaScriptEnabled = true
            object.applicationNameForUserAgent = "ChalkTalks"
            object.allowsInlineMediaPlayback = true
        }
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        contentView.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override open func prepareRx() {
        super.prepareRx()
        
        webView
            .rx.observe(String.self, "title")
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] title in
                self?.navItem.title = title
            }).disposed(by: disposeBag)
        
        webView
            .rx.observe(Double.self, "estimatedProgress")
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (progress: Double?) in
                // TODO： 加载进度条
            }).disposed(by: disposeBag)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        willAppearOnceHandler()
    }
    
    // VC生命周期仅执行一次
    fileprivate lazy var willAppearOnceHandler: () -> Void = {
        guard let url = url else { return {} }
        let request = URLRequest(url: url,
                                 cachePolicy: URLRequest.CachePolicy.useProtocolCachePolicy,
                                 timeoutInterval: 15)
        webView.load(request)
        HUD.show(to: webView, loadingType: .lottie)
        return {}
    }()
    
    /// 加载成功失败都会回调
    open func didFinishedLoad() {
        HUD.hide(for: webView)
    }
    
    open func showErrorView(isNetworkError: Bool) {
        
        let imageView = UIImageView().ss.prepare { (view) in
            view.image = UIImage(named: isNetworkError ? "empty_NoNetwork_154x154" : "empty_NoNetwork_154x154")
        }
        
        let titleLabel = UILabel().ss.prepare { (label) in
            label.font = UIFont.boldSystemFont(ofSize: 15)
            label.textColor = UIColor(0x999999FF)
            label.text = isNetworkError ? "网络出了一点小意外～" : "你要的数据不小心飞走了~"
            label.textAlignment = .center
        }
        
        let contentLabel = UILabel().ss.prepare { (label) in
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = UIColor(0xDDDDDDFF)
            label.text = isNetworkError ? "别紧张，请稍后再试~" : "别紧张，请稍后再试~"
            label.textAlignment = .center
        }
        
        let titleStack = UIStackView(arrangedSubviews: [titleLabel, contentLabel])
        titleStack.alignment = .center
        titleStack.axis = .vertical
        titleStack.distribution = .equalSpacing
        titleStack.spacing = 7
        
        let stack = UIStackView(arrangedSubviews: [imageView, titleStack])
        stack.alignment = .center
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = 26
        
        contentView.addSubview(stack)
        stack.snp.makeConstraints({ make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.78)
            make.top.greaterThanOrEqualToSuperview().offset(30).priority(999)
        })
    }
    
    // MAKR: - Message Handle
    
    open func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // 只能当前线程调用
        let name = message.name
        let body = message.body
        Logger.info("[Webview]: name: \(name) body: \(body)")
        
        if message.name == "openUrl" {
            guard
                let body = message.body as? String,
                let url = URL(string: EnvConfig.share.h5BaseUrl() + body)
                else { return }
            openUrl(url)
        } else if message.name == "fenbishuo" {
            guard let body = message.body as? String, body == "popWebView" else { return }
            navigationController?.popViewController(animated: true)
        }
    }
    
    open func openUrl(_ url: URL) {
        let vc = WebViewController(url: url)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - WKNavigationDelegate
    
    // 内存占用过大 https://zhuanlan.zhihu.com/p/24990222
    open func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
    
    open func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        Logger.debug("[WebView] didFailProvisionalNavigation \(error)")
        showErrorView(isNetworkError: false)
        didFinishedLoad()
    }
    
    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Logger.debug("[WebView] didFinish \(webView.url?.absoluteString ?? "")")
        didFinishedLoad()
    }
    
    open func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Logger.debug("[WebView] didFail \(error)")
        
        let error = (error as NSError)
        
        switch error.code {
        case NSURLErrorTimedOut, NSURLErrorCannotConnectToHost, NSURLErrorNetworkConnectionLost, NSURLErrorNotConnectedToInternet:
            // 网络错误
            showErrorView(isNetworkError: true)
        default:
            // 其他
            showErrorView(isNetworkError: false)
        }
        
        didFinishedLoad()
    }
}

// MARK: - WKUIDelegate

extension WebViewController: WKUIDelegate {
    
}

// MARK: - BaseWebViewControllerLeakAvoider

final class BaseWebViewControllerLeakAvoider: NSObject, WKScriptMessageHandler {
    
    weak var delegate: WKScriptMessageHandler?

    public init(_ delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
}
