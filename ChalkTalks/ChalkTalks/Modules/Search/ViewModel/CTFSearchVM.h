//
//  CTFSearchVM.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/26.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseViewModel.h"
#import "CTFSearchUserModel.h"
#import "CTFSearchQuestionModel.h"
#import "CTFSearchAnswerModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFSearchVM : BaseViewModel

/* 搜索热词 */
- (void)svr_fetchTrendingSearchWordComplete:(AdpaterComplete)complete;
- (NSString *)queryTrendingSearchWord;

/* 话题搜索 */
- (void)fetchUpdate_QuestionSearchListByKeyword:(NSString *)keyword complete:(AdpaterComplete)complete;
- (BOOL)fetchMore_QuestionSearchList_Complete:(AdpaterComplete)complete;
- (NSArray<CTFSearchQuestionModel *> *)query_QuestionSearchList;
- (void)removeAllSearchResult_question;

/* 观点搜索 */
- (void)fetchUpdate_AnswerSearchListByKeyword:(NSString *)keyword complete:(AdpaterComplete)complete;
- (BOOL)fetchMore_AnswerSearchList_Complete:(AdpaterComplete)complete;
- (NSArray<CTFSearchAnswerModel *> *)query_AnswerSearchList;
- (void)removeAllSearchResult_answer;

/* 用户搜索 */
- (void)fetchUpdate_UserSearchListByKeyword:(NSString *)keyword complete:(AdpaterComplete)complete;
- (BOOL)fetchMore_UserSearchList_Complete:(AdpaterComplete)complete;
- (NSArray<CTFSearchUserModel *> *)query_UserSearchList;
- (void)removeAllSearchResult_user;

/* 搜索历史记录 */
- (NSArray *)query_SearchHistory;
- (void)add_SearchHistory:(NSString *)keyword;
- (void)delete_SearchHistoryWithIndexRow:(NSInteger)indexNum;
- (void)delete_SearchHistoryAll;

@end

NS_ASSUME_NONNULL_END
