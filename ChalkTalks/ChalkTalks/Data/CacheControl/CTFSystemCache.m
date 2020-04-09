//
//  CTFSystemCache.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/2/21.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFSystemCache.h"

/* 历史搜索关键词-缓存 */
static NSString * const kCache_searchHistoryList = @"CTFSearchHistoryList";

/* 投票列表的数据排序方式-缓存 */
static NSString * const kCache_voteListSortTypeList = @"CTFVoteListSortTypeList";

/* App中是否展示过投票列表的引导页-缓存 */
static NSString * const kCache_showedVoteGuide = @"CTFShowedVoteGuide";

/* App中缓存的手机号码 */
static NSString * const kCache_inputedPhoneNumber = @"CTFInputedPhoneNumber";

/* App中显示全局学习引导页的判断 */
static NSString * const kCache_showedLearningGuideView = @"CTFShowedLearningGuideView";

@implementation CTFSystemCache

#pragma mark - 历史搜索关键词-缓存
+ (NSArray *)query_searchHistoryList {
    NSArray *searchHistoryList = [[NSUserDefaults standardUserDefaults] objectForKey:kCache_searchHistoryList];
    return searchHistoryList;
}

+ (void)revise_searchHistoryList:(NSArray *)searchHistoryList {
    [[NSUserDefaults standardUserDefaults] setObject:searchHistoryList forKey:kCache_searchHistoryList];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 投票列表的数据排序方式-缓存
+ (NSDictionary *)query_voteListSortTypeList {
    NSDictionary *voteListSortTypeList = [[NSUserDefaults standardUserDefaults] objectForKey:kCache_voteListSortTypeList];
    return voteListSortTypeList;
}

+ (void)revise_voteListSortTypeList:(NSDictionary *)voteListSortTypeList {
    [[NSUserDefaults standardUserDefaults] setObject:voteListSortTypeList forKey:kCache_voteListSortTypeList];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - App中是否展示过投票列表的引导页-缓存
+ (BOOL)query_whetherShowVoteGuide {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kCache_showedVoteGuide] == nil) {
        [CTFSystemCache revise_whetherShowedVoteGuide:NO];
    }
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kCache_showedVoteGuide] boolValue];
}

+ (void)revise_whetherShowedVoteGuide:(BOOL)showedVoteGuide {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:!showedVoteGuide] forKey:kCache_showedVoteGuide];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - App中缓存的手机号码
+ (NSString *)query_inputedPhoneNumber {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kCache_inputedPhoneNumber];
}

+ (void)revise_inputedPhoneNumber:(NSString *)phoneNumber {
    [[NSUserDefaults standardUserDefaults] setObject:phoneNumber forKey:kCache_inputedPhoneNumber];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - App中显示全局学习引导页的判断（YES-已经显示过了 NO-没有显示过）
+ (BOOL)query_showedLearningGuideForFunctionView:(CTFLearningGuideViewType)learningGuideView {
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:kCache_showedLearningGuideView];
    if (array == nil || array.count < (learningGuideView+1)) {
        [CTFSystemCache revise_showedLearningGuide:NO ForFunctionView:learningGuideView];
        return NO;
    }
    NSNumber *showed = [array objectAtIndex:learningGuideView];
    return [showed boolValue];
}

+ (void)revise_showedLearningGuide:(BOOL)showed
                   ForFunctionView:(CTFLearningGuideViewType)learningGuideView {
    NSMutableArray *mArray = [[[NSUserDefaults standardUserDefaults] objectForKey:kCache_showedLearningGuideView] mutableCopy];
    if (mArray == nil) {
        mArray = [NSMutableArray array];
    }
    if (mArray.count < (learningGuideView+1)) {
        NSInteger needMakeNumber = learningGuideView+1 - mArray.count;
        for (int i = 0; i < needMakeNumber; i++) {
            [mArray addObject:[NSNumber numberWithBool:NO]];
        }
    }
    [mArray replaceObjectAtIndex:learningGuideView withObject:[NSNumber numberWithBool:showed]];
    
    [[NSUserDefaults standardUserDefaults] setObject:mArray forKey:kCache_showedLearningGuideView];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
