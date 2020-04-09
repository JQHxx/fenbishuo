//
//  CTFMineViewModel.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/17.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFMineViewModel.h"
#import "CTFMineApi.h"
#import "MBProgressHUD+CTF.h"

@interface CTFMineViewModel ()
@property (nonatomic, strong) UserModel *userserMessage;

@property (nonatomic, strong) NSMutableArray *fansListArray;
@property (nonatomic, strong) PagingModel *fansPagingModel;

@property (nonatomic, strong) NSMutableArray *followListArray;
@property (nonatomic, strong) PagingModel *followPagingModel;

@property (nonatomic, strong) NSMutableArray *mineTopicListArray;
@property (nonatomic, strong) PagingModel *mineTopicPagingModel;

@property (nonatomic, strong) NSMutableArray *mineCareTopicListArray;
@property (nonatomic, strong) PagingModel *mineCareTopicPagingModel;

@property (nonatomic, strong) NSMutableArray *mineBadgesArray;

@end

@implementation CTFMineViewModel

- (instancetype)init {
    if (self = [super init]) {
        [self setupData];
    }
    return self;
}

- (void)setupData {
    
    self.fansPagingModel = [[PagingModel alloc] init];
    self.fansListArray = [NSMutableArray array];
    
    self.followPagingModel = [[PagingModel alloc] init];
    self.followListArray = [NSMutableArray array];
    
    self.mineTopicPagingModel = [[PagingModel alloc] init];
    self.mineTopicListArray = [NSMutableArray array];
    
    self.mineCareTopicPagingModel = [[PagingModel alloc] init];
    self.mineCareTopicListArray = [NSMutableArray array];
    
    self.mineBadgesArray = [NSMutableArray array];
}

- (void)svr_fetchMineUserMessage:(AdpaterComplete)complete {
    
    CTRequest *request = [CTFMineApi mineUserMessage];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if (isSuccess) {
            NSDictionary *userMessage = data;
            UserModel *model = [UserModel yy_modelWithJSON:userMessage];
            self.userserMessage = model;
            if (complete) complete(YES);
        } else {
            if (complete) complete(NO);
        }
    }];
}

- (UserModel *)currentUserMessage {
    return self.userserMessage;
}

- (void)svr_reviseMineUserMessageByNewUserMessageModel:(UserModel *)newUserMessage avatarImageId:(NSInteger)avatarImageId complete:(AdpaterComplete)complete {
    
    CTRequest *request = [CTFMineApi reviseUserMessageByHeadLine:newUserMessage.headline name:newUserMessage.name gender:newUserMessage.gender avatarImageId:avatarImageId];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if (isSuccess) {
            if (complete) complete(YES);
        } else {
            if (complete) complete(NO);
        }
    }];
}

- (void)svr_reviseMineUserMessageByHeadLine:(NSString * _Nullable)headLine name:(NSString * _Nullable)name gender:(NSString * _Nullable)gender avatarImageId:(NSInteger)avatarImageId complete:(AdpaterComplete)complete {
    
    CTRequest *request = [CTFMineApi reviseUserMessageByHeadLine:headLine name:name gender:gender avatarImageId:avatarImageId];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if (isSuccess) {
            if (complete) complete(YES);
        } else {
            if (complete) complete(NO);
        }
    }];
}

//-------
- (void)svr_fetchFansListByUserId:(NSInteger)userId page:(PagingModel *)page complete:(AdpaterComplete)complete {
    
    CTRequest *request = [CTFMineApi userFansListDataByUserId:userId pageIndex:page.page pageSize:page.pageSize];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if (isSuccess) {
            NSDictionary *paging = [data safe_objectForKey:@"paging"];
            self.fansPagingModel.total = [paging safe_integerForKey:@"total"];
            NSArray *fans = [data safe_objectForKey:@"data"];
            NSArray *arr = [NSArray yy_modelArrayWithClass:[CTFFansUserModel class] json:fans];
            if (page.page == 1) {
                [self.fansListArray removeAllObjects];
            }
            [self.fansListArray safe_addObjectsFromArray:arr];
            if (complete) complete(YES);
        } else {
            if (complete) complete(NO);
        }
    }];
}

- (NSInteger)numberOfFansList {
    return self.fansListArray.count;
}
- (NSArray<CTFFansUserModel *> *)fansModelArray {
    return self.fansListArray;
}
- (CTFFansUserModel *)fansModelAtIndex:(NSInteger)index {
    return self.fansListArray[index];
}
- (BOOL)hasMoreFansListData {
    if(self.fansPagingModel && self.fansListArray) {
        return self.fansPagingModel.total > self.fansListArray.count;
    }
    return NO;
}

- (void)svr_readFansMessageByPullId:(NSString *)pullId complete:(AdpaterComplete)complete {
    CTRequest *request = [CTFMessageApi read:@[pullId]];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if (isSuccess) {
            if (complete) complete(YES);
        } else {
            if (complete) complete(NO);
        }
    }];
}

//------
- (void)svr_fetchFollowListByUserId:(NSInteger)userId page:(PagingModel *)page complete:(AdpaterComplete)complete {
    
    CTRequest *request = [CTFMineApi userFollowListDataByUserId:userId pageIndex:page.page pageSize:page.pageSize];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if (isSuccess) {
            NSDictionary *paging = [data safe_objectForKey:@"paging"];
            self.followPagingModel.total = [paging safe_integerForKey:@"total"];
            
            NSArray *fans = [data safe_objectForKey:@"data"];
            NSArray *arr = [NSArray yy_modelArrayWithClass:[CTFFollowUserModel class] json:fans];
            
            if (page.page == 1) {
                [self.followListArray removeAllObjects];
            }
            [self.followListArray safe_addObjectsFromArray:arr];
            if (complete) complete(YES);
        } else {
            if (complete) complete(NO);
        }
    }];
}
- (NSInteger)numberOfFollowList {
    return self.followListArray.count;
}
- (NSArray<CTFFollowUserModel *> *)followModelArray {
    return self.followListArray;
}
- (CTFFollowUserModel *)followModelAtIndex:(NSInteger)index {
    return self.followListArray[index];
}
- (BOOL)hasMoreFollowListData {
    if(self.followPagingModel && self.followListArray) {
        return self.followPagingModel.total > self.followListArray.count;
    }
    return NO;
}

//-------
- (void)svr_fetchMineTopicListByPage:(PagingModel *)page complete:(AdpaterComplete)complete {
    
    CTRequest *request = [CTFMineApi mineTopicListDataByPageIndex:page.page pageSize:page.pageSize];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if (isSuccess) {
            NSDictionary *paging = [data safe_objectForKey:@"paging"];
            self.mineTopicPagingModel.total = [paging safe_integerForKey:@"total"];
            NSArray *fans = [data safe_objectForKey:@"data"];
            NSArray *arr = [NSArray yy_modelArrayWithClass:[CTFQuestionsModel class] json:fans];
            if (page.page == 1) {
                [self.mineTopicListArray removeAllObjects];
            }
            [self.mineTopicListArray safe_addObjectsFromArray:arr];
            if (complete) complete(YES);
        } else {
            if (complete) complete(NO);
        }
    }];
}
- (NSInteger)numberOfMineTopic {
    return self.mineTopicListArray.count;
}
- (NSArray<CTFQuestionsModel *> *)mineTopicModelArray {
    return self.mineTopicListArray;
}
- (CTFQuestionsModel *)mineTopicModelAtIndex:(NSInteger)index {
    return self.mineTopicListArray[index];
}
- (BOOL)hasMoreMineTopicListData {
    if(self.mineTopicPagingModel && self.mineTopicListArray) {
        return self.mineTopicPagingModel.total > self.mineTopicListArray.count;
    }
    return NO;
}

//-------
- (void)svr_fetchMineCareTopicListByPage:(PagingModel *)page complete:(AdpaterComplete)complete {
    
    CTRequest *request = [CTFMineApi mineCareTopicListDataByPageIndex:page.page pageSize:page.pageSize];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if (isSuccess) {
            NSDictionary *paging = [data safe_objectForKey:@"paging"];
            self.mineCareTopicPagingModel.total = [paging safe_integerForKey:@"total"];
            
            NSArray *fans = [data safe_objectForKey:@"data"];
            NSArray *arr = [NSArray yy_modelArrayWithClass:[CTFQuestionsModel class] json:fans];
            if (page.page == 1) {
                [self.mineCareTopicListArray removeAllObjects];
            }
            [self.mineCareTopicListArray safe_addObjectsFromArray:arr];
            if (complete) complete(YES);
        } else {
            if (complete) complete(NO);
        }
    }];
}
- (NSInteger)numberOfMineCareTopic {
    return self.mineCareTopicListArray.count;
}
- (NSArray<CTFQuestionsModel *> *)mineCareTopicModelArray {
    return self.mineCareTopicListArray;
}
- (CTFQuestionsModel *)mineCareTopicModelAtIndex:(NSInteger)index {
    return self.mineCareTopicListArray[index];
}
- (BOOL)hasMoreMineCareTopicListData {
    if(self.mineCareTopicPagingModel && self.mineCareTopicListArray) {
        return self.mineCareTopicPagingModel.total > self.mineCareTopicListArray.count;
    }
    return NO;
}

//-----
- (void)svr_fetchBadgesForUserId:(NSInteger)userId complete:(AdpaterComplete)complete {
    CTRequest *request = [CTFMineApi badgeWallMessageForUserId:userId];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if (isSuccess) {
            NSArray *badges = [data safe_objectForKey:@"badges"];
            NSArray *arr = [NSArray yy_modelArrayWithClass:[CTFBadgeModel class] json:badges];
            [self.mineBadgesArray setArray:arr];
            if (complete) complete(YES);
        } else {
            if (complete) complete(NO);
        }
    }];
}

- (NSArray<CTFBadgeModel *> *)queryBadges {
    return self.mineBadgesArray;
}

@end
