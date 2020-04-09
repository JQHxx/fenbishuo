//
//  AppDelegate+UM.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "AppDelegate+UM.h"
#import <UMAnalytics/MobClick.h>
#import <UMCommon/UMCommon.h>
#import <UMShare/UMShare.h>
#import "LibKey.h"

@implementation AppDelegate (UM)

- (void)configUmeng {
//#if DEBUG
//#else
    [UMConfigure initWithAppkey:umengKey channel:@"App Store"];
    [MobClick setScenarioType:E_UM_NORMAL];
    [MobClick setCrashReportEnabled:NO];
    /* 设置微信的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:wxAPPID appSecret:wxAPPSECRET redirectURL:@"http://mobile.umeng.com/social"];
    /* 设置分享到QQ互联的appID */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:QQAPPKey appSecret:nil redirectURL:@"http://mobile.umeng.com/social"];
//#endif
}
@end
