//
//  CTFSearchVM.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/26.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFSearchVM.h"

@interface CTFSearchVM ()
@property (nonatomic, copy) NSString *trendingSearchWord;

@property (nonatomic, strong) NSMutableArray<CTFSearchQuestionModel *> *modelList_question;
@property (nonatomic, strong) NSMutableArray<CTFSearchAnswerModel *> *modelList_answer;
@property (nonatomic, strong) NSMutableArray<CTFSearchUserModel *> *modelList_user;

@property (nonatomic, strong) PagingModel *pageModel_questionList;
@property (nonatomic, strong) PagingModel *pageModel_answerList;
@property (nonatomic, strong) PagingModel *pageModel_userList;

@property (nonatomic, copy) NSString *keyword_question;
@property (nonatomic, copy) NSString *keyword_answerList;
@property (nonatomic, copy) NSString *keyword_userList;

@end

@implementation CTFSearchVM

- (instancetype)init {
    if (self = [super init]) {
        [self setupData];
    }
    return self;
}

- (void)setupData {
    
    self.trendingSearchWord = @"";
    
    self.modelList_question = [NSMutableArray array];
    self.modelList_answer = [NSMutableArray array];
    self.modelList_user = [NSMutableArray array];
    
    self.pageModel_questionList = [[PagingModel alloc] init];
    self.pageModel_questionList.pageSize = 20;
    
    self.pageModel_answerList = [[PagingModel alloc] init];
    self.pageModel_answerList.pageSize = 20;
    
    self.pageModel_userList = [[PagingModel alloc] init];
    self.pageModel_userList.pageSize = 20;
    
    self.keyword_question = @"";
    self.keyword_answerList = @"";
    self.keyword_userList = @"";
}

#pragma mark - 搜索热词
- (void)svr_fetchTrendingSearchWordComplete:(AdpaterComplete)complete {
    CTRequest *request = [CTFSearchApi searchTrendingKeyword];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        NSString *data_value = [data safe_objectForKey:@"appTrendingSearchWord"];
        self.trendingSearchWord = data_value;
        if (isSuccess && complete) {
            complete(YES);
        } else {
            if (complete) {
                complete(NO);
            }
        }
    }];
}

- (NSString *)queryTrendingSearchWord {
    return self.trendingSearchWord;
}

#pragma mark - 话题搜索
- (void)svr_fetchQuestionSearchListComplete:(AdpaterComplete)complete {
    
    CTRequest *request =
    [CTFSearchApi searchQuestionByKeyword:self.keyword_question
                                pageIndex:self.pageModel_questionList.page
                                 pageSize:self.pageModel_questionList.pageSize];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        
        NSDictionary *paging = [data safe_objectForKey:@"paging"];
        self.pageModel_questionList.total = [paging safe_integerForKey:@"total"];
        self.pageModel_questionList.count = [paging safe_integerForKey:@"count"];
        
        NSArray *data_array_page = [data safe_objectForKey:@"data"];
        NSArray *data_modelArray_page = [NSArray yy_modelArrayWithClass:[CTFSearchQuestionModel class] json:data_array_page];
        
        if (self.pageModel_questionList.page == 1) {
            [self.modelList_question removeAllObjects];
        }
        
        if (data_modelArray_page) {
            [self.modelList_question addObjectsFromArray:data_modelArray_page];
        } else {
            self.pageModel_questionList.page--;
        }
        
        if (isSuccess && complete) {
            complete(YES);
        } else {
            if (complete) {
                complete(NO);
            }
        }
    }];
}

- (void)fetchUpdate_QuestionSearchListByKeyword:(NSString *)keyword complete:(AdpaterComplete)complete {
    self.keyword_question = keyword;
    self.pageModel_questionList.page = 1;
    [self svr_fetchQuestionSearchListComplete:complete];
}

- (BOOL)fetchMore_QuestionSearchList_Complete:(AdpaterComplete)complete {
    if (self.modelList_question.count < self.pageModel_questionList.total) {
        self.pageModel_questionList.page++;
        [self svr_fetchQuestionSearchListComplete:complete];
        return YES;
    } else {
        complete(YES);
        return NO;
    }
}

- (NSArray<CTFSearchQuestionModel *> *)query_QuestionSearchList {
    return self.modelList_question;
}

- (void)removeAllSearchResult_question {
    [self.modelList_question removeAllObjects];
}

#pragma mark - 观点搜索
- (void)svr_fetchAnswerSearchListComplete:(AdpaterComplete)complete {
    
    CTRequest *request =
    [CTFSearchApi searchAnswerByKeyword:self.keyword_answerList
                              pageIndex:self.pageModel_answerList.page
                               pageSize:self.pageModel_answerList.pageSize];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        
        NSDictionary *paging = [data safe_objectForKey:@"paging"];
        self.pageModel_answerList.total = [paging safe_integerForKey:@"total"];
        self.pageModel_answerList.count = [paging safe_integerForKey:@"count"];
        
        NSArray *data_array_page = [data safe_objectForKey:@"data"];
        NSArray *data_modelArray_page = [NSArray yy_modelArrayWithClass:[CTFSearchAnswerModel class] json:data_array_page];
        
        if (self.pageModel_answerList.page == 1) {
            [self.modelList_answer removeAllObjects];
        }
        
        if (data_modelArray_page) {
            [self.modelList_answer addObjectsFromArray:data_modelArray_page];
        } else {
            self.pageModel_answerList.page--;
        }
        
        if (isSuccess && complete) {
            complete(YES);
        } else {
            if (complete) {
                complete(NO);
            }
        }
    }];
}

- (void)fetchUpdate_AnswerSearchListByKeyword:(NSString *)keyword complete:(AdpaterComplete)complete {
    self.keyword_answerList = keyword;
    self.pageModel_answerList.page = 1;
    [self svr_fetchAnswerSearchListComplete:complete];
}

- (BOOL)fetchMore_AnswerSearchList_Complete:(AdpaterComplete)complete {
    if (self.modelList_answer.count < self.pageModel_answerList.total) {
        self.pageModel_answerList.page++;
        [self svr_fetchAnswerSearchListComplete:complete];
        return YES;
    } else {
        complete(YES);
        return NO;
    }
}

- (NSArray<CTFSearchAnswerModel *> *)query_AnswerSearchList {
    return self.modelList_answer;
}

- (void)removeAllSearchResult_answer {
    [self.modelList_answer removeAllObjects];
}

#pragma mark - 用户搜索
- (void)svr_fetchUserSearchListComplete:(AdpaterComplete)complete {
    
    CTRequest *request =
    [CTFSearchApi searchUserByKeyword:self.keyword_userList
                            pageIndex:self.pageModel_userList.page
                             pageSize:self.pageModel_userList.pageSize];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        
        NSDictionary *paging = [data safe_objectForKey:@"paging"];
        self.pageModel_userList.total = [paging safe_integerForKey:@"total"];
        self.pageModel_userList.count = [paging safe_integerForKey:@"count"];
        
        NSArray *data_array_page = [data safe_objectForKey:@"data"];
        NSArray *data_modelArray_page = [NSArray yy_modelArrayWithClass:[CTFSearchUserModel class] json:data_array_page];
        
        if (self.pageModel_userList.page == 1) {
            [self.modelList_user removeAllObjects];
        }

        if (data_modelArray_page) {
            [self.modelList_user addObjectsFromArray:data_modelArray_page];
        } else {
            self.pageModel_userList.page--;
        }
        
        if (isSuccess && complete) {
            complete(YES);
        } else {
            if (complete) {
                complete(NO);
            }
        }
    }];
}

- (void)fetchUpdate_UserSearchListByKeyword:(NSString *)keyword complete:(AdpaterComplete)complete {
    self.keyword_userList = keyword;
    self.pageModel_userList.page = 1;
    [self svr_fetchUserSearchListComplete:complete];
}

- (BOOL)fetchMore_UserSearchList_Complete:(AdpaterComplete)complete {
    if (self.modelList_user.count < self.pageModel_userList.total) {
        self.pageModel_userList.page++;
        [self svr_fetchUserSearchListComplete:complete];
        return YES;
    } else {
        complete(YES);
        return NO;
    }
}

- (NSArray<CTFSearchUserModel *> *)query_UserSearchList {
    return self.modelList_user;
}

- (void)removeAllSearchResult_user {
    [self.modelList_user removeAllObjects];
}

#pragma mark - 搜索历史记录
- (NSArray *)query_SearchHistory {
    return [CTFSystemCache query_searchHistoryList];
}

- (void)add_SearchHistory:(NSString *)keyword {
    NSArray *array = [self query_SearchHistory];
    if (!array) {
        array = [[NSArray alloc] init];
    }
    NSMutableArray *mArray = array.mutableCopy;
    if (mArray.count == 20) {
        [mArray removeObjectAtIndex:0];
    }
    //去重
    int sign_deleteIndex;
    for (int i = 0; i < mArray.count; i++) {
        if ([mArray[i] isEqualToString:keyword]) {
            sign_deleteIndex = i;
            [mArray removeObjectAtIndex:sign_deleteIndex];
            break;
        }
    }
    //新增
    [mArray addObject:keyword];
    [CTFSystemCache revise_searchHistoryList:mArray];
}

- (void)delete_SearchHistoryWithIndexRow:(NSInteger)indexNum {
    NSArray *array = [self query_SearchHistory];
    if (!array || (indexNum > array.count - 1)) {
        return;
    }
    NSMutableArray *mArray = array.mutableCopy;
    [mArray removeObjectAtIndex:indexNum];
    [CTFSystemCache revise_searchHistoryList:mArray];
}

- (void)delete_SearchHistoryAll {
    NSArray *array = [self query_SearchHistory];
    array = @[];
    [CTFSystemCache revise_searchHistoryList:array];
}

@end
