//
//  CTFHomePageViewModel.m
//  ChalkTalks
//
//  Created by vision on 2019/12/26.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFHomePageViewModel.h"
#import "CTFHomePageApi.h"
#import "CTFFeedCellLayout.h"
#import "ChalkTalks-Swift.h"

@interface CTFHomePageViewModel ()

@property (nonatomic,assign) NSInteger      userId;
@property (nonatomic,assign) BOOL           isMine;
@property (nonatomic,strong) UserModel      *userDetails;
@property (nonatomic,strong) NSMutableArray *activitiesData;
@property (nonatomic,strong) PagingModel    *myPagingModel;

@end

@implementation CTFHomePageViewModel

-(instancetype)initWithUserId:(NSInteger)userId isMine:(BOOL)isMine{
    self = [super init];
    if (self) {
        _userId = userId;
        self.isMine = isMine;
        self.activitiesData = [[NSMutableArray alloc] init];
        self.userDetails = [[UserModel alloc] init];
        self.myPagingModel = [[PagingModel alloc] init];
    }
    return self;
}

#pragma mark 加载用户详情
-(void)loadUserDetilsComplete:(AdpaterComplete)complete{
    CTRequest *request = [CTFHomePageApi requestUserDetailsDataWithUserId:self.userId isMine:self.isMine];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if(isSuccess){
            [self.userDetails yy_modelSetWithJSON:data];
            complete(YES);
        }else{
            complete(NO);
        }
    }];
}

#pragma mark 加载个人动态
-(void)loadUserActivitiesDataByPage:(PagingModel *)pageModel complete:(AdpaterComplete)complete{
    CTRequest *request = [CTFHomePageApi requestUserActivitiesDataWithUserId:self.userId page:pageModel.page pageSize:pageModel.pageSize];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if(isSuccess){
            NSDictionary *paging = [data safe_objectForKey:@"paging"];
            self.myPagingModel.total = [paging safe_integerForKey:@"total"];
            self.myPagingModel.count = [paging safe_integerForKey:@"count"];
            
            NSArray *activities = [data safe_objectForKey:@"data"];
            NSArray *arr = [NSArray yy_modelArrayWithClass:[CTFActivityModel class] json:activities];
            NSMutableArray *tempArr = [[NSMutableArray alloc] init];
            for (CTFActivityModel *model in arr) {
                if ([model.resourceType isEqualToString:@"answer"]) {
                    model.answer.hideTitle = YES;
                    NSString *timeString = [CTDateUtils formatTimeAgoWithTimestamp:model.createdAt];
                    model.answer.myTitle = [NSString stringWithFormat:@"%@ %@",timeString,model.actionText]; //
                    model.feedCellLayout = [[CTFMyAnswerCellLayout alloc] initWithData:model.answer];
                }
                [tempArr addObject:model];
            }
            
            if (pageModel.page == 1) {
                [self.activitiesData removeAllObjects];
            }            
            [self.activitiesData safe_addObjectsFromArray:tempArr];
            complete(YES);
        }else{
            complete(NO);
        }
    }];
}

#pragma mark 关注
- (void)requestForFollowNeed:(BOOL)needFollow complete:(AdpaterComplete)complete{
    CTRequest *request;
    if(needFollow){
         request = [CTFMineApi followToUser:self.userId];
    }else{
         request = [CTFMineApi unfollowerToUser:self.userId];
    }
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if(isSuccess){
            if (needFollow) {
                [[CTPushManager share] showAuthReqAlertIfNeed];
            }
            self.userDetails.isFollowing = needFollow;
            complete(YES);
        }else{
            complete(NO);
        }
    }];
    
}

#pragma mark 删除个人动态
-(void)deleteMyActivityWithAnswerId:(NSInteger)answerId{
    CTFActivityModel *myModel = [[CTFActivityModel alloc] init];
    for (CTFActivityModel *aModel in self.activitiesData) {
        if ([aModel.resourceType isEqualToString:@"answer"]&&aModel.answer.answerId==answerId) {
            myModel = aModel;
            break;
        }
    }
    [self.activitiesData removeObject:myModel];
}

#pragma mark  动态数
-(NSInteger)numberOfActitivitiesData{
    return self.activitiesData.count;
}

#pragma mark 返回一条动态
-(CTFActivityModel *)getActivityModelWithIndex:(NSInteger)index{
    return [self.activitiesData safe_objectAtIndex:index];
}

#pragma mark 是否有更多动态
-(BOOL)hasMoreActitivtiesListData{
    if(self.myPagingModel && self.activitiesData) {
        return self.myPagingModel.total > self.activitiesData.count;
    }
    return NO;
}

#pragma mark 动态是否为空
- (BOOL)isEmpty{
    return self.activitiesData.count==0;
}

#pragma mark  返回用户信息
-(UserModel *)getUserInfo{
    return self.userDetails;
}

@end
