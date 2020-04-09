//
//  CTFMineViewModel.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/17.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFMineViewModel : BaseViewModel

- (void)svr_fetchMineUserMessage:(AdpaterComplete)complete;
- (UserModel *)currentUserMessage;

- (void)svr_reviseMineUserMessageByNewUserMessageModel:(UserModel *)newUserMessage avatarImageId:(NSInteger)avatarImageId complete:(AdpaterComplete)complete;

- (void)svr_reviseMineUserMessageByHeadLine:(NSString * _Nullable)headLine name:(NSString * _Nullable)name gender:(NSString * _Nullable)gender avatarImageId:(NSInteger)avatarImageId complete:(AdpaterComplete)complete;

//粉丝
- (void)svr_fetchFansListByUserId:(NSInteger)userId page:(PagingModel *)page complete:(AdpaterComplete)complete;
- (NSInteger)numberOfFansList;
- (NSArray<CTFFansUserModel *> *)fansModelArray;
- (CTFFansUserModel *)fansModelAtIndex:(NSInteger)index;
- (BOOL)hasMoreFansListData;

- (void)svr_readFansMessageByPullId:(NSString *)pullId complete:(AdpaterComplete)complete;

//关注
- (void)svr_fetchFollowListByUserId:(NSInteger)userId page:(PagingModel *)page complete:(AdpaterComplete)complete;
- (NSInteger)numberOfFollowList;
- (NSArray<CTFFollowUserModel *> *)followModelArray;
- (CTFFollowUserModel *)followModelAtIndex:(NSInteger)index;
- (BOOL)hasMoreFollowListData;



//我的话题
- (void)svr_fetchMineTopicListByPage:(PagingModel *)page complete:(AdpaterComplete)complete;
- (NSInteger)numberOfMineTopic;
- (NSArray<CTFQuestionsModel *> *)mineTopicModelArray;
- (CTFQuestionsModel *)mineTopicModelAtIndex:(NSInteger)index;
- (BOOL)hasMoreMineTopicListData;

//我关心的话题
- (void)svr_fetchMineCareTopicListByPage:(PagingModel *)page complete:(AdpaterComplete)complete;
- (NSInteger)numberOfMineCareTopic;
- (NSArray<CTFQuestionsModel *> *)mineCareTopicModelArray;
- (CTFQuestionsModel *)mineCareTopicModelAtIndex:(NSInteger)index;
- (BOOL)hasMoreMineCareTopicListData;

// 勋章墙
- (void)svr_fetchBadgesForUserId:(NSInteger)userId complete:(AdpaterComplete)complete;
- (NSArray<CTFBadgeModel *> *)queryBadges;


@end

NS_ASSUME_NONNULL_END
