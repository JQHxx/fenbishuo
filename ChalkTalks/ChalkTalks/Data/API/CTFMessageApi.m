//
//  CTFMessageApi.m
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/23.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFMessageApi.h"

#import "UserCache.h"
#import "UIDevice+Extend.h"

static NSString *const api_v1_read_msgs = @"/api/v1/notifications/read";
static NSString *const api_v2_push_id = @"/api/v2/users/push_id";
static NSString *const api_v1_metrics_report = @"api/v1/metrics/report";

static NSString *const api_v2_read_all = @"/api/v2/notifications/read_all";
static NSString *const api_v2_unread_count = @"/api/v2/users/notifications/unread_count";
static NSString *const api_v2_message_list = @"/api/v2/users/notifications";

@implementation CTFMessageApi

+ (CTRequest *)getMessageList:(NSString *)categoryType pageIdx:(NSInteger)page pageSize:(NSInteger)pageSize {
    NSDictionary *arg = @{
        @"type": categoryType,
        @"page": @(page),
        @"pageSize": @(pageSize)
    };
    CTRequest *request = [[CTRequest alloc]
                          initWithRequestUrl:api_v2_message_list
                          argument:arg
                          method:YTKRequestMethodGET];
    return request;
}

+ (CTRequest *)readAll:(NSString * _Nonnull)category {
    NSDictionary *arg = @{
        @"type": category
    };
    CTRequest *request = [[CTRequest alloc]
                          initWithRequestUrl:api_v2_read_all
                          argument:arg
                          method:YTKRequestMethodPUT];
    return request;
}

+ (CTRequest *)read:(NSArray *)ids {
    NSDictionary *arg = @{
        @"ids": ids
    };
    CTRequest *request = [[CTRequest alloc]
                          initWithRequestUrl:api_v1_read_msgs
                          argument:arg
                          method:YTKRequestMethodPUT];
    return request;
}

+ (CTRequest *)getUnreadCount {
    CTRequest *request = [[CTRequest alloc]
                          initWithRequestUrl:api_v2_unread_count
                          argument:nil
                          method:YTKRequestMethodGET];
    return request;
}

+ (CTRequest *)uploadDeviceToken:(NSString *)token {
    NSDictionary *arg = @{
        @"pushId": token,
        @"deviceId": [UIDevice deviceIdentifier],
    };
    CTRequest *request = [[CTRequest alloc]
                          initWithRequestUrl:api_v2_push_id
                          argument:arg
                          method:YTKRequestMethodPUT];
    return request;
}

+ (CTRequest *)metricsReportWithType:(NSString *)type
                              taskId:(NSString *)tid
                              isPush:(BOOL)isPush {
    NSTimeInterval now = [[NSDate new] timeIntervalSince1970];
    NSDictionary *arg = @{
        @"uuid": [UserCache getCurrentUserID],
        @"category": isPush ? @"push" : @"pull",
        @"event": [NSString stringWithFormat:@"system_%@", tid],
        @"eventedAt": @((long)now),
    };
    
    CTRequest *request = [[CTRequest alloc]
                          initWithRequestUrl:api_v1_metrics_report
                          argument:arg
                          method:YTKRequestMethodPOST];
    request.verifyJSONFormat = NO;
    return request;
}

@end
