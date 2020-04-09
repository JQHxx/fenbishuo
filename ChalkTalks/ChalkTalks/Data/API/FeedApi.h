//
//  FeedApi.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/4.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTRequest.h"

NS_ASSUME_NONNULL_BEGIN

/// 首页feed相关接口
@interface FeedApi : NSObject

/// 获取所有频道
+(CTRequest*)feedCategoriesApi;

/// 获取首页热门内容列表 feeds
/// @param page  当前页
/// @param pageSize 页码内容数量
/// @param action  上下滑动（up/down）
/// @param feedId  feedId
+ (CTRequest *)homeFeedListApiByAction:(NSString *)action
                              feedId:(NSInteger)feedId;

/// 获取首页热门内容列表
/// @param page  当前页
/// @param pageSize 页码内容数量
+(CTRequest*)feedRecommendsApi:(NSInteger)page
                         pageSize:(NSInteger)pageSize;



/// 获取某个(全部)频道下的观点列表
/// @param categoryId  频道ID
/// @param page page
/// @param pageSize  数量
+(CTRequest*)feedAnswersApi:(NSInteger)categoryId
                          page:(NSInteger)page
                      pageSize:(NSInteger)pageSize;

/// 获取某个(全部)频道下的观点列表
/// @param answerId  频道ID
+ (CTRequest *)feedAnswerUploadReadByAnswerId:(NSInteger)answerId;



/// 对观点进行投票(即：点赞 | 踩)
/// @param answerId 观点ID
/// @param attitude 态度：  【like:关心 】 【neutral：取消操作(中立态度)】 【unlike:踩】
+(CTRequest*)voterToAttitude:(NSInteger)answerId
                    attitude:(NSString*)attitude;



/// 删除观点
/// @param answerId 观点id
+(CTRequest*)deleteViewpoint:(NSInteger)answerId;


/// 获取某个观点详情
/// @param answerId  观点id
+(CTRequest*)getViewpointDetail:(NSInteger)answerId;


@end


NS_ASSUME_NONNULL_END
