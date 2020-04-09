//
//  CTFUserAgreementVC.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/25.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFUserAgreementVC.h"
#import <WebKit/WebKit.h>

@interface CTFUserAgreementVC () <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSURLRequest *fileRequest;
@property (nonatomic, copy) NSString *uRLString;

@end

static NSString *const urlString = @"/appview/protocol/index";

@implementation CTFUserAgreementVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.isHiddenNavBar = NO;
    [self setupViewContent];
}

- (void)setupViewContent {
    
    WKWebViewConfiguration *webConfiguration = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0,kNavBar_Height, kScreen_Width,kScreen_Height-kNavBar_Height) configuration:webConfiguration];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.contentMode = UIViewContentModeScaleAspectFit;
    self.webView.scrollView.showsHorizontalScrollIndicator = NO;
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.webView];
    
    NSURL *fileUrl = [[NSURL alloc] init];
    fileUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [[CTENVConfig share] h5BaseUrl], urlString]];
    self.fileRequest = [NSURLRequest requestWithURL:fileUrl];
    [self.webView loadRequest:self.fileRequest];
}

#pragma mark - WKNavigationDelegate

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
 
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.baseTitle = webView.title;
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self showNetErrorViewWithType:ERROR_NET whetherLittleIconModel:NO frame:self.webView.frame];
}

// 网络错误空白页上的刷新按钮响应事件
- (void)baseRefreshData {
    [self hideNetErrorView];
    [self.webView loadRequest:self.fileRequest];
}

@end
