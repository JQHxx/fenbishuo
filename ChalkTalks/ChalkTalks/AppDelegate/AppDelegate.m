//
//  AppDelegate.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/1.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "AppDelegate.h"
#import "LibKey.h"
#import "AppDependency.h"
#import "AppDelegate+UM.h"
#import "AppDelegate+WX.h"
#import "AppDelegate+HTTPCache.h"
#import "AppDelegate+IQKeyboard.h"
#import "WXApi.h"
#import "CTFNetReachabilityManager.h"
#import <YTKNetwork/YTKNetwork.h>
#import <UMShare/UMShare.h>
@import Firebase;
#import "ChalkTalks-Swift.h"
#import "NSUserDefaultsInfos.h"
#import <ATAuthSDK/ATAuthSDK.h>

@interface AppDelegate ()

@property (nonatomic, strong) RACDisposable *disposable;
@property (nonatomic, assign) NSInteger time;

@end

@implementation AppDelegate
@synthesize countDownTime = _countDownTime;

#pragma mark - 懒加载
- (UIWindow *)additionalWindow {
    if (!_additionalWindow) {
        _additionalWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _additionalWindow.backgroundColor = [UIColor clearColor];
        _additionalWindow.windowLevel = UIWindowLevelAlert;
    }
    return _additionalWindow;
}

/* 当应用程序启动时执行，应用程序启动入口。只在应用程序启动时执行一次 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL backTag = [NSUserDefaultsInfos getValueforKey:kEnterBackgroundTag];
    [NSUserDefaultsInfos putKey:kNewUserKey andValue:[NSNumber numberWithBool:backTag]];
    
    //标识启动
    [NSUserDefaultsInfos putKey:kAPPlicationFinishLaunching andValue:[NSNumber numberWithBool:YES]];
    
    /* 开启网络状态的监听 */
    [[CTFNetReachabilityManager sharedInstance] netMonitoring];
    
    /* keyWindows、登录界面、UITabBar的UI配置 */
    [AppDependency installAppDependencies:self];
    
    // 禁用摇一摇
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:NO];
   
    [self configWx];/* 微信登录的配置 */
    [self configUmeng];/* 友盟分享、友盟统计的配置 */
    [self configHTTPCache];/* 网络请求缓存的配置 */
    [[CTPushManager share] setupUPushWithLaunchOptions:launchOptions];/* 友盟推送的配置 */
    [FIRApp configure];/* FirebaseApp配置 */
    [self configIQKeyboard];/* 键盘的配置 */
    [self setupMonitor];/* 通知监听的注册 */
    
    // 阿里云手机号认证，设置SDK参数，app生命周期内调用一次即可
    [[TXCommonHandler sharedInstance] setAuthSDKInfo:AliPhoneVerificationAuthSDKSecret complete:^(NSDictionary * _Nonnull resultDic) {
    }];
    
    return YES;
}

/* 当应用程序将要进入非活动状态执行，在此期间，应用程序不接受消息或事件，比如来电 */
- (void)applicationWillResignActive:(UIApplication *)application {
    
}

/* 当应用程序已经进入后台时执行 */
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [CTLogger flush]; // 写日志
    [NSUserDefaultsInfos putKey:kEnterBackgroundTag andValue:[NSNumber numberWithBool:YES]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationDidEnterBackgroundNotification object:nil];
}

/* 当应用程序将要进入活动状态时执行 */
- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

/* 当应用程序已经进入活动状态时执行 */
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

/* 当应用程序将要退出，通常用于保存和退出前的一些清理工作 */
- (void)applicationWillTerminate:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationWillTerminateNotification object:nil];
}

/* 当设备为应用程序分配了太多的内存，操作系统会终止应用程序的运行，在终止前会执行这个方法
   通常可以在这里进行内存清理工作，防止程序被终止
*/
-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    NSLog(@"系统内存不足，需要进行清理工作");
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    if ([[CTPushManager share] canOpenUrl:url]) {
        return [[CTPushManager share] application:app open:url options:options];
    } else if ([url.absoluteString containsString:@"wx_oauth_authorization_state"]) {/* 微信 */
        return [WXApi handleOpenURL:url delegate:self];
    } else {
        return [[UMSocialManager defaultManager] handleOpenURL:url options:options];
    }
}

#pragma mark - 倒计时相关
- (NSInteger)countDownTime {
    return self.time;
}

- (void)setCountDownTime:(NSInteger)countDownTime {
    
    self.time = countDownTime;
    @weakify(self)
    self.disposable = [[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSDate * _Nullable x) {
        self.time--;
        @strongify(self)
        if (self.time == 0) {
            //关掉信号
            [self.disposable dispose];
        }
    }];
}

#pragma mark - Push

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[CTPushManager share] interceptApplication:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[CTPushManager share] interceptApplication:application didFailToRegisterForRemoteNotificationsWithError:error];
}

#pragma mark - 通知监听

- (void)setupMonitor {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(monitor_loginSuccess) name:kLoginedNotification object:nil];
}

- (void)monitor_loginSuccess {
    //关掉信号
    self.time = 0;
    [self.disposable dispose];
}

@end
