//
//  CTFVoteViewModel.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/11.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseViewModel.h"
#import "CTModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFVoteViewModel : BaseViewModel


/// 网络请求获取所有的频道列表
/// @param complete 获取成功的回调
- (void)svr_fetchVoteTopTabListComplete:(AdpaterComplete)complete;
- (NSArray<CategoriesModel*> *)categoriesList;


/// 网络获取投票轮播消息
/// @param complete 获取成功的回调
- (void)svr_fetchVoteCarouselsComplete:(AdpaterComplete)complete;
- (NSArray<CTFCarouselsModel*> *)carouselsMessageList;


/// 根据频道ID获取本地的pageModel数据
/// @param categoryId 频道ID
- (PagingModel *)fetchPageModelByCategoryId:(NSInteger)categoryId;


/// 重置频道ID获取本地的pageModel数据
/// @param categoryId 频道ID
- (void)resetPageModelByCategoryId:(NSInteger)categoryId;


/// 网络请求某个频道下投票列表数据
/// @param categoryId 频道ID
/// @param page 请求的页码信息
/// @param sort 排序方式，“default”--默认排序，“last”--最新发布
/// @param complete 获取成功的回调
- (void)svr_fetchVoteListByCategoryID:(NSInteger)categoryId
                             page:(PagingModel *)page
                         sortType:(NSString *)sort
                         complete:(AdpaterComplete)complete;
- (NSInteger)numberOfList_voteCategoryId:(NSInteger)categoryId;
- (NSArray<CTFQuestionsModel *> *)voteModelArrayForCategory:(NSInteger)categoryId;
- (CTFQuestionsModel *)voteModelForCategoryId:(NSInteger)categoryId index:(NSInteger)index;
- (BOOL)hasMoreData_voteCategoryId:(NSInteger)categoryId;
- (BOOL)isEmpty_voteCategoryId:(NSInteger)categoryId;
- (NSInteger)totalOfVoteListByCatogoryId:(NSInteger)categoryId;


/// 改变数据源数组中的数据
/// @param questionModel 新的数据源模型数据
/// @param categoryId 频道分类ID
/// @param questionId 话题ID
- (void)reviseModel:(CTFQuestionsModel *)questionModel toCategoryId:(NSInteger)categoryId toQuestionId:(NSInteger)questionId;


/// 网络请求改变投票的意向
/// @param questionId 话题ID
/// @param statement 投票的意向，“like”--赞同，“unlike”--踩，“neutral”--中立状态
/// @param complete 网络请求成功的回调
- (void)svr_voteQuestionId:(NSInteger)questionId toState:(NSString *)statement complete:(AdpaterComplete)complete;


- (void)local_updateVoteListSortType:(NSString *)sort toCategoryId:(NSInteger)categoryId;
- (NSDictionary *)local_queryVoteListSortType;

@end

NS_ASSUME_NONNULL_END
