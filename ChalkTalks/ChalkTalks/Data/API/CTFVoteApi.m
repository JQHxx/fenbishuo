//
//  CTFVoteApi.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/11.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFVoteApi.h"

//获取所有频道
static NSString *const api_v1_categories = @"/api/v1/categories";
//获取某个（全部）频道下的话题投票列表
static NSString *const api_v1_voteList = @"/api/v1/questions";
//获取投票的轮播消息数据
static NSString *const api_v1_carousels = @"/api/v1/carousels";

@implementation CTFVoteApi

//获取所有频道
+ (CTRequest *)voteCategoriesApi {
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_v1_categories argument:nil method:YTKRequestMethodGET];
    return request;
}

//获取投票的轮播消息数据
+ (CTRequest *)voteCarouselsApi {
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_v1_carousels argument:nil method:YTKRequestMethodGET];
    return request;
}

//获取某个（全部）频道下的话题投票列表
+ (CTRequest *)voteListApiByCategoryId:(NSInteger)categoryId sortType:(NSString *)sort pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize {
    
    NSString *url = api_v1_voteList;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"categoryId"] = @(categoryId);
    params[@"sort"] = sort;
    params[@"page"] = @(pageIndex);
    params[@"pageSize"] = @(pageSize);

    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:url argument:params method:YTKRequestMethodGET];
    return request;
}

//对话题进行投票
+ (CTRequest *)voteQuestionId:(NSInteger)questionId toState:(NSString *)attitude {
    
    NSString *url = [NSString stringWithFormat:@"/api/v1/questions/%ld/voters", questionId];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"attitude"] = attitude;
    
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:url argument:params method:YTKRequestMethodPOST];
    return request;
}

@end
