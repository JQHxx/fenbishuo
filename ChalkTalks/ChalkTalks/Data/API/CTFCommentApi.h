//
//  CTFCommentApi.h
//  ChalkTalks
//
//  Created by vision on 2019/12/24.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFCommentApi : UIView

/*
 * 获取某个观点下的所有评论
 * @param answerId 观点ID
 * @param page 页码
 * @param pageSize 每页个数
 */
+ (CTRequest *)requestCommentsListWithAnswerId:(NSInteger)answerId page:(NSInteger)page pageSize:(NSInteger)pageSize;

/*
 * 获取某个评论下的所有子评论
 * @param commentId 评论ID
 * @param page 页码
 * @param pageSize 每页个数
 */
+ (CTRequest *)requestSubCommentsListWithCommentId:(NSInteger)commentId page:(NSInteger)page pageSize:(NSInteger)pageSize;

/* 发布评论
 * @param answerId 观点ID
 * @param content 评论内容
 */
+(CTRequest*)creatCommentWithAnswerId:(NSInteger)answerId content:(NSString*)content;

/* 回复评论
* @param commentId 被评论ID
* @param content 回复内容
*/
+ (CTRequest *)creatReplyWithCommentId:(NSInteger)commentId content:(NSString *)content;

/* 删除评论
 * @param commentId 评论id
 */
+(CTRequest*)deleteCommentWithCommentId:(NSInteger)commentId;

/* 对评论进行投票 （即：点赞、踩）
* @param commentId 评论id
* @param attitude 【like:关心 】 【neutral：取消操作(中立态度)】
*/
+(CTRequest *)voteCommentWithCommentId:(NSInteger)commentId attitude:(NSString *)attitude;

@end

NS_ASSUME_NONNULL_END
