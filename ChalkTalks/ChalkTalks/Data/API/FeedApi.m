//
//  FeedApi.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/4.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "FeedApi.h"
#import "NSUserDefaultsInfos.h"
#import "UIDevice+Extend.h"

static NSString *const api_v1_categories = @"/api/v1/categories";
static NSString *const api_v1_recommends = @"/api/v1/recommends";
static NSString *const api_v1_answers = @"/api/v1/answers";
static NSString *const api_v2_recommends = @"/api/v2/recommends";
static NSString *const api_v2_answers = @"/api/v2/answers";
static NSString *const api_v1_feeds = @"/api/v1/feeds";

@implementation FeedApi

+(CTRequest*)feedCategoriesApi{
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_v1_categories argument:nil method:YTKRequestMethodGET];
    request.apiCacheTime = 86400; //频道缓存一天
    return request;
}

#pragma mark  获取首页热门内容列表 feeds
+ (CTRequest *)homeFeedListApiByAction:(NSString *)action feedId:(NSInteger)feedId{
    BOOL isNew = [[NSUserDefaultsInfos getValueforKey:kNewUserKey] boolValue];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"isNew"] = isNew?@"false":@"true";
    params[@"action"] = action;
    params[@"deviceId"] = [UIDevice deviceIdentifier];
    if ([action isEqualToString:@"up"]) {
        params[@"page"] = @(1);
        params[@"beforeId"] = @(feedId);
    }
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_v1_feeds argument:params method:YTKRequestMethodGET];
    return request;
}

#pragma mark  获取首页热门内容列表
+(CTRequest*)feedRecommendsApi:(NSInteger)page
                         pageSize:(NSInteger)pageSize{
    BOOL isNew = [[NSUserDefaultsInfos getValueforKey:kNewUserKey] boolValue];
    NSDictionary *arg = @{
        @"page": @(page),
        @"pageSize": @(pageSize),
        @"type":isNew?@"all":@"isNew"
    };
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_v2_recommends argument:arg method:YTKRequestMethodGET];
    return request;
}

#pragma mark 获取某个(全部)频道下的观点列表
+(CTRequest*)feedAnswersApi:(NSInteger)categoryId
                          page:(NSInteger)page
                         pageSize:(NSInteger)pageSize{
    NSDictionary *arg = @{
        @"categoryId": @(categoryId),
        @"page": @(page),
        @"pageSize": @(pageSize)
    };
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_v2_answers argument:arg method:YTKRequestMethodGET];
    return request;
}

#pragma mark 上报回答已读
+ (CTRequest *)feedAnswerUploadReadByAnswerId:(NSInteger)answerId {
    NSDictionary *arg = @{
        @"answerId": @(answerId),
        @"deviceId": [UIDevice deviceIdentifier],
    };
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_v1_feeds argument:arg method:YTKRequestMethodPOST];
    return request;
}

#pragma mark 对观点进行投票(即：点赞 | 踩)
+(CTRequest*)voterToAttitude:(NSInteger)answerId
                    attitude:(NSString*)attitude{
    NSDictionary *arg = @{
        @"attitude": attitude,
    };
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"%@/%ld/voters",api_v1_answers, answerId] argument:arg method:YTKRequestMethodPOST];
    return request;
}

#pragma mark 删除观点
+(CTRequest*)deleteViewpoint:(NSInteger)answerId{
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"%@/%ld",api_v1_answers, answerId] argument:nil method:YTKRequestMethodDELETE];
    return request;
}

#pragma mark 获取某个观点详情
+(CTRequest*)getViewpointDetail:(NSInteger)answerId{
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"%@/%ld",api_v2_answers, answerId] argument:nil method:YTKRequestMethodGET];
    return request;
}

@end
