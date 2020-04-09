//
//  CTFVoteViewModel.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/11.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFVoteViewModel.h"
#import "CTFVoteApi.h"
#import "MBProgressHUD+CTF.h"

@interface CTFVoteViewModel ()
@property(nonatomic,strong) NSMutableArray<CategoriesModel *> *categoriesArr;//全部频道
@property(nonatomic,strong) CategoriesModel *recommendTab;//新增“全部”频道

@property(nonatomic,strong) NSMutableArray<CTFCarouselsModel *> *carouselsArr;//全部的投票轮播消息

@property(nonatomic,strong) NSMutableDictionary<NSMutableArray<CategoriesModel *> *, NSString *> *voteDictionary;
@property(nonatomic,strong) NSMutableDictionary<PagingModel *, NSString *> *votePageDictionary;

@end

@implementation CTFVoteViewModel

- (instancetype)init {
    if (self = [super init]) {
        [self setupData];
    }
    return self;
}

- (void)setupData {
    
    self.categoriesArr = [NSMutableArray array];
    self.carouselsArr = [NSMutableArray array];
    
    //新增“全部”频道
    self.recommendTab = [[CategoriesModel alloc] init];
    self.recommendTab.categoryId = 0;
    self.recommendTab.name = @"全部";
    
    self.voteDictionary = [NSMutableDictionary dictionary];
    self.votePageDictionary = [NSMutableDictionary dictionary];
}


//-----获取所有的频道
- (void)svr_fetchVoteTopTabListComplete:(AdpaterComplete)complete {
    
    CTRequest *request = [CTFVoteApi voteCategoriesApi];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if (isSuccess) {
            NSArray *categories = data;
            NSArray *arr = [NSArray yy_modelArrayWithClass:[CategoriesModel class] json:categories];
            [self.categoriesArr setArray:@[self.recommendTab]];
            [self.categoriesArr safe_addObjectsFromArray:arr];
            if (complete) complete(YES);
        } else {
            if (complete) complete(NO);
        }
    }];
}

- (NSArray<CategoriesModel*> *)categoriesList {
    return self.categoriesArr;
}

//-----网络获取投票轮播消息
- (void)svr_fetchVoteCarouselsComplete:(AdpaterComplete)complete {
    
    CTRequest *request = [CTFVoteApi voteCarouselsApi];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if (isSuccess) {
            NSArray *carousels = [data safe_objectForKey:@"data"];
            NSArray *arr = [NSArray yy_modelArrayWithClass:[CTFCarouselsModel class] json:carousels];
            [self.carouselsArr setArray:arr];
            if (complete) complete(YES);
        } else {
            if (complete) complete(NO);
        }
    }];
}

- (NSArray<CTFCarouselsModel*> *)carouselsMessageList {
    return self.carouselsArr;
}

//-----根据频道ID获取本地的pageModel数据
- (PagingModel *)fetchPageModelByCategoryId:(NSInteger)categoryId {
    NSString *key_categoryId = [NSString stringWithFormat:@"%ld", categoryId];
    PagingModel *pageModel = [self.votePageDictionary safe_objectForKey:key_categoryId];
    if (!pageModel) {
        pageModel = [[PagingModel alloc] init];
        pageModel.page = 1;
        pageModel.pageSize = 8;
        [self.votePageDictionary safe_setValue:pageModel forKey:key_categoryId];
    }
    return pageModel;
}

- (void)resetPageModelByCategoryId:(NSInteger)categoryId {
    NSString *key_categoryId = [NSString stringWithFormat:@"%ld", categoryId];
    PagingModel *pageModel = [self.votePageDictionary safe_objectForKey:key_categoryId];
    if (pageModel) {
        pageModel.page = 1;
        pageModel.pageSize = 8;
        [self.votePageDictionary safe_setValue:pageModel forKey:key_categoryId];
    }
}

//-----网络请求某个频道下投票列表数据
- (void)svr_fetchVoteListByCategoryID:(NSInteger)categoryId
                             page:(PagingModel *)page
                         sortType:(NSString *)sort
                         complete:(AdpaterComplete)complete {
    
    NSString *key_categoryId = [NSString stringWithFormat:@"%ld", categoryId];
    [self.votePageDictionary safe_setValue:page forKey:key_categoryId];
    
    CTRequest *request = [CTFVoteApi voteListApiByCategoryId:categoryId sortType:sort pageIndex:page.page pageSize:page.pageSize];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if (isSuccess) {
            NSDictionary *resultData = data;
            
            NSDictionary *paging = [resultData safe_objectForKey:@"paging"];
            page.total = [paging safe_integerForKey:@"total"];
            page.count = [paging safe_integerForKey:@"count"];
            
            NSArray *questions = [[resultData safe_objectForKey:@"data"] safe_objectForKey:@"questions"];
            NSArray *questionList = [NSArray yy_modelArrayWithClass:[CTFQuestionsModel class] json:questions];
            
            if (page.page == 1) {
                [(NSMutableArray *)[self.voteDictionary safe_objectForKey:key_categoryId] removeAllObjects];
            }
            
            NSMutableArray *arr = [self.voteDictionary safe_objectForKey:key_categoryId];
            
            if (arr) {
                [arr addObjectsFromArray:questionList];
            } else {
                NSMutableArray *newArr = [NSMutableArray arrayWithArray:questionList];
                [self.voteDictionary safe_setObject:newArr forKey:key_categoryId];
            }
            
            if (complete) complete(YES);
        } else{
            page.page--;
            if (complete) complete(NO);
        }
    }];
}

- (NSInteger)numberOfList_voteCategoryId:(NSInteger)categoryId {
    NSString *key = [NSString stringWithFormat:@"%ld", categoryId];
    NSArray *arr = [self.voteDictionary safe_objectForKey:key];
    return [arr count];
}

- (NSArray<CTFQuestionsModel *> *)voteModelArrayForCategory:(NSInteger)categoryId {
    NSString *key = [NSString stringWithFormat:@"%ld", categoryId];
    NSArray *arr = [self.voteDictionary safe_objectForKey:key];
    return arr;
}

- (CTFQuestionsModel *)voteModelForCategoryId:(NSInteger)categoryId index:(NSInteger)index {
    NSString *key = [NSString stringWithFormat:@"%ld", categoryId];
    NSArray *arr = [self.voteDictionary safe_objectForKey:key];
    return [arr safe_objectAtIndex:index];
}

- (BOOL)hasMoreData_voteCategoryId:(NSInteger)categoryId {
    NSString *key = [NSString stringWithFormat:@"%ld", categoryId];
    NSArray *arr = [self.voteDictionary safe_objectForKey:key];
    PagingModel *page = [self.votePageDictionary safe_objectForKey:key];
    
    if (page && arr && arr.count) {
        return page.total > arr.count;
    }
    return NO;
}

- (BOOL)isEmpty_voteCategoryId:(NSInteger)categoryId {
    NSString *key = [NSString stringWithFormat:@"%ld", categoryId];
    NSArray *arr = [self.voteDictionary safe_objectForKey:key];
    if (arr && arr.count>0) return NO;
    return YES;
}

- (NSInteger)totalOfVoteListByCatogoryId:(NSInteger)categoryId {
    NSString *key = [NSString stringWithFormat:@"%ld", categoryId];
    PagingModel *page = [self.votePageDictionary safe_objectForKey:key];
    return page.total;
}

//-----改变数据源数组中的数据
- (void)reviseModel:(CTFQuestionsModel *)questionModel toCategoryId:(NSInteger)categoryId toQuestionId:(NSInteger)questionId {
    
    NSString *key = [NSString stringWithFormat:@"%ld", categoryId];
    NSMutableArray *arr = [self.voteDictionary safe_objectForKey:key];
    NSInteger singNum = 0;
    for (int i = 0; i < arr.count; i++) {
        CTFQuestionsModel *tempModel = arr[i];
        if (tempModel.questionId == questionModel.questionId) {
            singNum = i;
            break;
        }
    }
    [arr replaceObjectAtIndex:singNum withObject:questionModel];
}

//-----网络请求改变投票的意向
- (void)svr_voteQuestionId:(NSInteger)questionId toState:(NSString *)statement complete:(AdpaterComplete)complete {
    
    CTRequest *request = [CTFVoteApi voteQuestionId:questionId toState:statement];
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

//-----投票列表的排序设置
- (void)local_updateVoteListSortType:(NSString *)sort toCategoryId:(NSInteger)categoryId {
    
    NSString *categoryIdString = [NSString stringWithFormat:@"%ld", categoryId];
    NSDictionary *dictionary = [self local_queryVoteListSortType];
    if (!dictionary) {
        dictionary = [[NSDictionary alloc] init];
    }
    NSMutableDictionary *mdictionary = dictionary.mutableCopy;
    mdictionary[categoryIdString] = sort;
    [CTFSystemCache revise_voteListSortTypeList:mdictionary];
}

- (NSDictionary *)local_queryVoteListSortType {
    return [CTFSystemCache query_voteListSortTypeList];
}

@end
