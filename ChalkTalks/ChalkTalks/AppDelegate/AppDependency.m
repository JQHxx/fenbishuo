//
//  AppDependency.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "AppDependency.h"
#import "UserCache.h"
#import "BaseTabBarViewController.h"
#import "LoginViewController.h"

@implementation AppDependency
+ (void)installAppDependencies:(AppDelegate *)app {
    
    /* 创建keyWindows */
    app.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    app.window.backgroundColor = [UIColor whiteColor];
    app.window.rootViewController = [BaseTabBarViewController createRootViewController];
    
    /*
    //是否显示闪屏广告页面
    if (NO) {
        app.additionalWindow.rootViewController = [[LaunchViewController alloc] init];
        [app.additionalWindow makeKeyAndVisible];
    }*/

    [app.window makeKeyAndVisible];
    
    /* 配置UITabBar的UI属性 */
    [self configUIAppearance];
    
    /* 模态登录界面 */
    /* 2022.3.17,根据产品要求在2.1.8版本中当用户打开app是默认不弹出登录页
    [self presentLogin];
     */
    
    //上传设备信息
    [UserCache uploadUserDeviceInfoWithAppLaunching:YES];
}

// 模态登录界面
+ (void)presentLogin {
    
    [[UIViewController getWindowsCurrentVC] ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Logined];
    
//    if (![UserCache isUserLogined]) {
//        [ROUTER routeByCls:kLoginViewController param:@{@"isContinueBindPhone" : [NSNumber numberWithBool:NO]} animation:false presentWithNavBar:true];
//    }
    
}

// 配置UITabBar的UI属性
+ (void)configUIAppearance {
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    // 字体颜色 选中
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10.0F], NSForegroundColorAttributeName : UIColorFromHEX(0x222222)} forState:UIControlStateSelected];
    
    // 字体颜色 未选中
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10.0F], NSForegroundColorAttributeName:UIColorFromHEX(0x909090)} forState:UIControlStateNormal];
    
    [[UITabBar appearance] setTranslucent:NO];
    [[UITabBar appearance] setBackgroundColor:UIColorFromHEX(0xf6f6f6)];
}

@end
