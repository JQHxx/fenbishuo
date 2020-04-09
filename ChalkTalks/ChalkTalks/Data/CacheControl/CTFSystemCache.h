//
//  CTFSystemCache.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/2/21.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CTFLearningGuideViewType) {
    CTFLearningGuideViewType_Main = 0,   // 首页
    CTFLearningGuideViewType_Vote,       // 投票页
    CTFLearningGuideViewType_Mine,       // 我的页面
    CTFLearningGuideViewType_Public,     // 发布话题
    CTFLearningGuideViewType_AddVoice,   // 添加语音
    CTFLearningGuideViewType_HomePage    // 个人主页
};

/// 与用户无关的信息缓存I/O
@interface CTFSystemCache : NSObject

/// 历史搜索关键词-缓存
+ (NSArray *)query_searchHistoryList;
+ (void)revise_searchHistoryList:(NSArray *)searchHistoryList;

/// 投票列表的数据排序方式-缓存
+ (NSDictionary *)query_voteListSortTypeList;
+ (void)revise_voteListSortTypeList:(NSDictionary *)voteListSortTypeList;

/// App中是否展示过投票列表的引导页-缓存
+ (BOOL)query_whetherShowVoteGuide;
+ (void)revise_whetherShowedVoteGuide:(BOOL)showedVoteGuide;

/// App中缓存的手机号码
+ (NSString *)query_inputedPhoneNumber;
+ (void)revise_inputedPhoneNumber:(NSString *)phoneNumber;

/// App中显示全局学习引导页的判断（YES-已经显示过了 NO-没有显示过）
+ (BOOL)query_showedLearningGuideForFunctionView:(CTFLearningGuideViewType)learningGuideView;
+ (void)revise_showedLearningGuide:(BOOL)showed
                   ForFunctionView:(CTFLearningGuideViewType)learningGuideView;

@end

NS_ASSUME_NONNULL_END
