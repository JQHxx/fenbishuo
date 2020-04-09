//
//  MainPageViewModel.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/3.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "BaseViewModel.h"
#import "CTModels.h"
#import "CTFFeedCellLayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface MainPageViewModel : BaseViewModel

//首次加载feeds数据
- (void)fetchFirstLaunchingFeedsDataByCategoryID:(NSInteger)categoryId
                                        complete:(AdpaterComplete)complete;

///上报回答已读
///@param answerId 回答id
- (void)uploadAnswerHasReadWithAnswerId:(NSInteger)answerId;

//加载首页分类数据
-(void)fetchFeedTopTabList:(AdpaterComplete)complete;
-(NSArray<CategoriesModel*>*)categoriesList;

//加载首页列表数据
-(void)fetchFeedListByCategoryID:(NSInteger)categoryId
                          action:(NSString *)action
                          feedId:(NSInteger)feedId
                            page:(PagingModel*)page
                        complete:(AdpaterComplete)complete;
- (NSInteger)numberOfList:(NSInteger)categoryId;
- (CTFFeedCellLayout*)modelForFeed:(NSInteger)categoryId Index:(NSInteger)index;
- (BOOL)hasMoreData:(NSInteger)categoryId;
- (BOOL)isEmpty:(NSInteger)categoryId;
//最后数据feedid
- (NSInteger )lastAnswerFeedId;
//最新数据数量
- (NSInteger)refreshDataCount;
//最新一次上拉拉取数量
- (NSInteger)latestUpLoadFeedsDataCount;

-(ERRORTYPE)errorType:(NSInteger)categoryId;

//点赞、踩
-(void)votersToAnswer:(NSInteger)answerId
             attitude:(NSString*)attitude
             complete:(AdpaterComplete)complete;

/// 举报
/// @param answerId 观点ID
-(void)impeachViewpoint:(NSInteger)answerId
               complete:(AdpaterComplete)complete;

/// 举报话题
/// @param questionId 话题ID
/// @param complete  callback
-(void)impeachTopic:(NSInteger)questionId
           complete:(AdpaterComplete)complete;

/// 删除自己发不的观点
/// @param answerId  观点id
/// @param complete callback
-(void)deleteMyViewpoint:(NSInteger)answerId
                complete:(AdpaterComplete)complete;

-(void)deleteModelForFeed:(NSInteger)categoryId Index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
