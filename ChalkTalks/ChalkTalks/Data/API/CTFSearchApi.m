//
//  CTFSearchApi.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/26.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFSearchApi.h"

static NSString * const api_v1_search_user = @"/api/v1/search/user";
static NSString * const api_v1_search_question = @"/api/v1/search/question";
static NSString * const api_v1_search_answer = @"/api/v1/search/answer";
static NSString * const api_v1_search_configs = @"/api/v1/configs";

@implementation CTFSearchApi

+ (CTRequest *)searchTrendingKeyword {
    
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_v1_search_configs argument:nil method:YTKRequestMethodGET];
    return request;
}

+ (CTRequest *)searchQuestionByKeyword:(NSString *)keyWord pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize {
    
    NSMutableDictionary *parems = [NSMutableDictionary dictionary];
    parems[@"keyword"] = keyWord;
    parems[@"pageSize"] = @(pageSize);
    parems[@"page"] = @(pageIndex);
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_v1_search_question argument:parems method:YTKRequestMethodPOST];
    return request;
}

+ (CTRequest *)searchAnswerByKeyword:(NSString *)keyWord pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize {
    
    NSMutableDictionary *parems = [NSMutableDictionary dictionary];
    parems[@"keyword"] = keyWord;
    parems[@"pageSize"] = @(pageSize);
    parems[@"page"] = @(pageIndex);
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_v1_search_answer argument:parems method:YTKRequestMethodPOST];
    return request;
}

+ (CTRequest *)searchUserByKeyword:(NSString *)keyWord pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize {
    
    NSMutableDictionary *parems = [NSMutableDictionary dictionary];
    parems[@"keyword"] = keyWord;
    parems[@"pageSize"] = @(pageSize);
    parems[@"page"] = @(pageIndex);
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_v1_search_user argument:parems method:YTKRequestMethodPOST];
    return request;
}

@end
