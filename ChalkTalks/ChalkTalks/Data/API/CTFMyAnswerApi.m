//
//  CTFMyAnswerApi.m
//  ChalkTalks
//
//  Created by vision on 2019/12/27.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFMyAnswerApi.h"

static NSString *const api_v2_users = @"api/v2/users";

@implementation CTFMyAnswerApi

+(CTRequest *)requestMyAnswersDataWithSort:(NSString *)sort page:(NSInteger)page pageSize:(NSInteger)pageSize{
    NSDictionary *arg = @{
           @"page": @(page),
           @"pageSize": @(pageSize),
           @"sort":sort
       };
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"%@/%ld/answers",api_v2_users,UserCache.getUserInfo.userId] argument:arg method:YTKRequestMethodGET];
    return request;
}

@end
