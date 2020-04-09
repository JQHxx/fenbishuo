//
//  CTFCommentViewModel.h
//  ChalkTalks
//
//  Created by vision on 2019/12/24.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseViewModel.h"
#import "CTFCommentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFCommentViewModel : BaseViewModel

@property (nonatomic,assign) BOOL isDetails;

/*
 * 初始化
 * @param answerId 回答id
 */
-(instancetype)initWithAnswerId:(NSInteger)answerId;

/*
* 加载评论数据
* @param page 页码
*/
- (void)loadCommentsListByPage:(PagingModel *)page complete:(AdpaterComplete)complete;

/*
* 加载某评论下所有子评论
* @param commentId 评论id
*/
- (void)loadSubCommentsDataByPage:(PagingModel *)pageModel commentId:(NSInteger )commentId complete:(AdpaterComplete)complete;

/*
* 发表评论
* @param content 评论内容
*/
- (void)createCommentWithContent:(NSString*)content complete:(AdpaterComplete)complete;

/*
* 回复评论
* @param commentId 被评论id
* @param content 评论内容
*/
- (void)createReplyWithCommentId:(NSInteger)commentId content:(NSString*)content complete:(AdpaterComplete)complete;

/*
* 删除评论
* @param commentId 评论id
*/
- (void)deleteCommentWithCommentId:(NSInteger)commentId complete:(AdpaterComplete)complete;

/*
* 举报评论
* @param commentId 评论id
*/
- (void)reportCommentWithCommentId:(NSInteger)commentId complete:(AdpaterComplete)complete;

/*
* 对评论进行投票
* @param commentId 评论id
* @param attitude 【like:关心 】 【neutral：取消操作(中立态度)】
*/
- (void)voteCommentWithCommentId:(NSInteger)commentId attitude:(NSString *)attitude complete:(AdpaterComplete)complete;

//评论数
-(NSInteger)numberOfCommentsList;
//获取cell的评论
-(CTFCommentModel *)getCommentModelWithIndex:(NSInteger)index;
//是否还有更多评论
- (BOOL)hasMoreCommentsListData;

//子评论数据
- (NSArray<CTFCommentModel *> *)subCommentsData;
//是否还有更多子评论
- (BOOL)hasMoreSubCommentsData;

/*
 *评论总数
 */
- (NSInteger)answerAllCommentCount;

@end

NS_ASSUME_NONNULL_END
