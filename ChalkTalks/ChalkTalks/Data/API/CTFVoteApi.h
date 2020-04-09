//
//  CTFVoteApi.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/11.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 投票Vote相关接口
@interface CTFVoteApi : NSObject

/// 获取所有频道
+ (CTRequest *)voteCategoriesApi;

/// 获取投票的轮播消息数据
+ (CTRequest *)voteCarouselsApi;

/// 获取某个（全部）频道下的话题投票列表
/// @param categoryId 频道ID，⚠️不传此参数时或为0时表示获取全部话题
/// @param sort 排序方式。⚠️‘default’-默认排序  ‘last’-最新发布
/// @param pageIndex 第几页
/// @param pageSize 每页返回条数，默认8，不能超过50
+ (CTRequest *)voteListApiByCategoryId:(NSInteger)categoryId sortType:(NSString *)sort pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize;

/// 对话题进行投票
/// @param questionId 话题ID
/// @param attitude 投票的态度，“like”--关心，“unlike”--踩，“neutral”--中立态度
+ (CTRequest *)voteQuestionId:(NSInteger)questionId toState:(NSString *)attitude;

@end

NS_ASSUME_NONNULL_END
