//
//  CTFMineApi.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/17.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFMineApi.h"

static NSString *const api_v1_users_me = @"/api/v1/users/me";
static NSString *const api_v1_fans_list = @"/api/v1/users/:userId/followers";
static NSString *const api_v1_users = @"/api/v1/users";
static NSString *const api_v1_users_badges = @"/api/v1/users";

@implementation CTFMineApi

+ (CTRequest *)mineUserMessage {
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_v1_users_me argument:nil method:YTKRequestMethodGET];
    return request;
}

+ (CTRequest *)reviseUserMessageByHeadLine:(NSString * _Nullable)headLine name:(NSString * _Nullable)name gender:(NSString * _Nullable)gender avatarImageId:(NSInteger)avatarImageId {
    
    NSMutableDictionary *parems = [NSMutableDictionary dictionary];
    if (headLine) {
        parems[@"headline"] = headLine;
    }
    if (name) {
        parems[@"name"] = name;
    }
    if (gender) {
        parems[@"gender"] = gender;
    }
    if (avatarImageId != 0) {
        parems[@"avatarImageId"] = @(avatarImageId);
    }
    
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_v1_users_me argument:parems method:YTKRequestMethodPUT];
    return request;
}

+ (CTRequest *)mineFansListDataByPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize {
    NSDictionary *arg = @{
        @"page": @(pageIndex),
        @"pageSize": @(pageSize)
    };
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"/api/v1/users/%ld/followers", UserCache.getUserInfo.userId] argument:arg method:YTKRequestMethodGET];
    return request;
}

+ (CTRequest *)userFansListDataByUserId:(NSInteger)userId pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize {
    NSDictionary *arg = @{
        @"page": @(pageIndex),
        @"pageSize": @(pageSize)
    };
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"/api/v1/users/%ld/followers", userId] argument:arg method:YTKRequestMethodGET];
    return request;
}

+ (CTRequest *)mineFollowListDataByPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize {
    NSDictionary *arg = @{
        @"page": @(pageIndex),
        @"pageSize": @(pageSize)
    };
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"/api/v1/users/%ld/following", UserCache.getUserInfo.userId] argument:arg method:YTKRequestMethodGET];
    return request;
}

// 获取某个用户所关注的用户列表
+ (CTRequest *)userFollowListDataByUserId:(NSInteger)userId pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize {
    NSDictionary *arg = @{
        @"page": @(pageIndex),
        @"pageSize": @(pageSize)
    };
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"/api/v1/users/%ld/following", userId] argument:arg method:YTKRequestMethodGET];
    return request;
}

+ (CTRequest *)mineTopicListDataByPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize {
    NSDictionary *arg = @{
        @"page": @(pageIndex),
        @"pageSize": @(pageSize)
    };
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"/api/v1/users/%ld/questions", UserCache.getUserInfo.userId] argument:arg method:YTKRequestMethodGET];
    return request;
}

+ (CTRequest *)mineCareTopicListDataByPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize {
    NSDictionary *arg = @{
        @"page": @(pageIndex),
        @"pageSize": @(pageSize)
    };
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"/api/v1/users/%ld/following_questions", UserCache.getUserInfo.userId] argument:arg method:YTKRequestMethodGET];
    return request;
}


+ (CTRequest *)followToUser:(NSInteger)userId {
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"%@/%zd/followers", api_v1_users, userId] argument:nil method:YTKRequestMethodPOST];
    return request;
}

+ (CTRequest *)unfollowerToUser:(NSInteger)userId {
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"%@/%zd/followers", api_v1_users, userId] argument:nil method:YTKRequestMethodDELETE];
    return request;
}

/// 获得某用户的勋章墙信息
+ (CTRequest *)badgeWallMessageForUserId:(NSInteger)userId {
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"%@/%zd/badges", api_v1_users_badges, userId] argument:nil method:YTKRequestMethodGET];
    return request;
}

#pragma mark 上报分享资源行为
+ (CTRequest *)uploadShareEventWithResourceType:(NSString *)resourceType resourceId:(NSInteger)resourceId {
    NSDictionary *arg = @{
           @"resourceType": resourceType,
           @"resourceId": @(resourceId)
       };
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"%@/share/resource", api_v1_users] argument:arg method:YTKRequestMethodPOST];
    return request;
}

@end
