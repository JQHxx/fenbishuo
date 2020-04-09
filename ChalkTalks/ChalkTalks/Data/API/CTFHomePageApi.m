//
//  CTFHomePageApi.m
//  ChalkTalks
//
//  Created by vision on 2019/12/26.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFHomePageApi.h"

static NSString *const api_v1_users = @"api/v1/users";
static NSString *const api_v2_users = @"api/v2/users";

@implementation CTFHomePageApi

#pragma mark 获取用户详情
+(CTRequest *)requestUserDetailsDataWithUserId:(NSInteger)userId isMine:(BOOL)isMine{
    NSString *urlStr = nil;
    if (isMine) {
        urlStr = [NSString stringWithFormat:@"%@/me",api_v1_users];
    }else{
        urlStr = [NSString stringWithFormat:@"%@/%ld",api_v1_users,userId];
    }
    
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:urlStr argument:nil method:YTKRequestMethodGET];
    return request;
}

#pragma mark 获取用户的动态信息
+(CTRequest *)requestUserActivitiesDataWithUserId:(NSInteger)userId page:(NSInteger)page pageSize:(NSInteger)pageSize{
    NSDictionary *arg = @{
        @"page": @(page),
        @"pageSize": @(pageSize)
    };
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"%@/%ld/activities",api_v2_users,userId] argument:arg method:YTKRequestMethodGET];
    return request;
}

#pragma mark 关注
+(CTRequest *)requestForFollowWithUserId:(NSInteger)userId{
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"%@/%ld/followers",api_v1_users,userId] argument:nil method:YTKRequestMethodPOST];
    return request;
}

@end
