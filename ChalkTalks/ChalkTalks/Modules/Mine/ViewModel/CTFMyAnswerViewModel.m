//
//  CTFMyAnswerViewModel.m
//  ChalkTalks
//
//  Created by vision on 2019/12/27.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFMyAnswerViewModel.h"
#import "CTFMyAnswerApi.h"
#import "ChalkTalks-Swift.h"

@interface CTFMyAnswerViewModel ()

@property (nonatomic,strong) NSMutableArray *myAnswersList;
@property (nonatomic,strong) PagingModel    *pagingModel;

@end

@implementation CTFMyAnswerViewModel

-(instancetype)init{
    self = [super init];
    if (self) {
        self.pagingModel = [[PagingModel alloc] init];
        self.myAnswersList = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark 加载我的观点
- (void)loadMyAnswersDataByPage:(PagingModel *)pageModel complete:(AdpaterComplete)complete{
    CTRequest *request = [CTFMyAnswerApi requestMyAnswersDataWithSort:@"createdAt" page:pageModel.page pageSize:pageModel.pageSize];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if(isSuccess){
            NSDictionary *paging = [data safe_objectForKey:@"paging"];
            self.pagingModel.total = [paging safe_integerForKey:@"total"];
            self.pagingModel.count = [paging safe_integerForKey:@"count"];
            
            NSDictionary *answers = [[data safe_objectForKey:@"data"] safe_objectForKey:@"answers"];
            NSArray *arr = [NSArray yy_modelArrayWithClass:[AnswerModel class] json:answers];
            NSMutableArray *tempArr = [[NSMutableArray alloc] init];
            for (AnswerModel *model in arr) {
                NSString *timeString = [CTDateUtils formatTimeAgoWithTimestamp:model.createdAt];
                model.myTitle = [NSString stringWithFormat:@"%@ 回答了",timeString];
                [tempArr addObject:model];
            }
            NSArray *list = [CTFMyAnswerCellLayout converToLayout:tempArr];
            if (pageModel.page == 1) {
                [self.myAnswersList removeAllObjects];
            }
            [self.myAnswersList safe_addObjectsFromArray:list];
            complete(YES);
        }else{
            complete(NO);
        }
    }];
}

#pragma mark 删除我的观点
- (void)deleteMyAnswerWithAnswerId:(NSInteger)answerId{
    CTFMyAnswerCellLayout *currentLayout = [[CTFMyAnswerCellLayout alloc] init];
    for (CTFMyAnswerCellLayout *layout in self.myAnswersList) {
        if (layout.model.answerId == answerId) {
            currentLayout = layout;
            break;
        }
    }
    [self.myAnswersList removeObject:currentLayout];
}

#pragma mark  动态数
- (NSInteger)numberOfMyAnswersData{
    return self.myAnswersList.count;
}

#pragma mark 返回一条动态
- (CTFMyAnswerCellLayout *)getMyAnswerModelWithIndex:(NSInteger)index{
    return [self.myAnswersList safe_objectAtIndex:index];
}

#pragma mark 是否有更多动态
- (BOOL)hasMoreMyAnswersListData{
    if(self.pagingModel && self.myAnswersList) {
        return self.pagingModel.total > self.myAnswersList.count;
    }
    return NO;
}

#pragma mark 是否为空
- (BOOL)isEmpty{
    return self.myAnswersList.count==0;
}


@end
