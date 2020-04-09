//
//  CTFUtilsApi.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/17.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFUtilsApi.h"
#import "AppInfo.h"
#import "UIDevice+Extend.h"

static NSString *const api_v1_reports = @"/api/v1/reports";
static NSString *const api_v1_feedback = @"/api/v1/feedback";
static NSString *const api_v1_version = @"/api/v1/versions/check";
static NSString *const api_v1_configs = @"/api/v1/configs";
static NSString *const api_v1_device = @"/api/v1/users/device";

@implementation CTFUtilsApi

+ (CTRequest *)reportContent:(NSInteger)resourceId
                resourceType:(NSString *)resourceType
               feedbackTitle:(NSString *)feedbackTitle
                     content:(NSString *)content
                       email:(NSString *)email
                    imageIds:(NSArray *)imageIds {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"resourceType"] = resourceType;
    params[@"resourceId"] = @(resourceId);
    params[@"title"] = feedbackTitle;
    params[@"content"] = content;
    params[@"email"] = email;
    params[@"imageIds"] = imageIds;
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_v1_reports argument:params method:YTKRequestMethodPOST];
    return request;
}

#pragma mark 问题反馈
+ (CTRequest *)creatFeedbakWithContent:(NSString *)content imageIds:(NSArray*)imageIds feedbackType:(NSString *)feedbackType email:(NSString *)email {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"content"] = content;
    params[@"imageIds"] = imageIds;
    params[@"type"] = feedbackType;
    params[@"email"] = email;
    
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_v1_feedback argument:params method:YTKRequestMethodPOST];
    return request;
}

#pragma mark 检测版本
+(CTRequest *)checkVersion{
    NSString *version = [AppInfo appVersion];
    NSDictionary *arg = @{
        @"channel": @"appstore",
        @"platform":@"ios",
        @"version":version
    };
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_v1_version argument:arg method:YTKRequestMethodGET];
    return request;
}

#pragma mark 系统配置
+(CTRequest *)systemConfigs{
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_v1_configs argument:nil method:YTKRequestMethodGET];
    return request;
}

#pragma mark 设备信息上报
+ (CTRequest *)uploadUserDeviceInfoWithAppLaunching:(BOOL)appLauching {
    NSString *res = [NSString stringWithFormat:@"%.f*%.f",kScreen_Width,kScreen_Height];
    NSNumber *isSimuLator = [UIDevice isSimuLator]?@(1):@(0);
    NSNumber *isJailBreak = [UIDevice isJailBreak]?@(1):@(0);
    NSString *mcCode = [UIDevice mobileCountryCode];
    NSString *mnCode = [UIDevice mobileNetworkCode];
    NSString *ipStr = [UIDevice getLocalIPAddress:YES];
    NSNumber *isNew = appLauching ? @(0) : ([UserCache getUserIsNew]?@(1):@(0));
    NSDictionary *arg = @{
        @"appVersion": [AppInfo appVersion],
        @"os":@"iOS",
        @"osVersion":[UIDevice getSystemVersion],
        @"model":[UIDevice iphoneType],
        @"resolution":res,
        @"deviceNumber":[UIDevice deviceIdentifier],
        @"appIp":ipStr,
        @"isSimulator":isSimuLator,
        @"isPrisonBreak":isJailBreak,
        @"mcc":kIsEmptyString(mcCode)?@"":mcCode,
        @"mnc":kIsEmptyString(mnCode)?@"":mnCode,
        @"channel":@"appStore",
        @"idfa":[UIDevice getIDFA],
        @"isNew":isNew
    };
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_v1_device argument:arg method:YTKRequestMethodPOST];
    return request;
}

@end
