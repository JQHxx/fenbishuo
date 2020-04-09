//
//  CTFSearchApi.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/26.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFSearchApi : NSObject

/// 搜索热词
+ (CTRequest *)searchTrendingKeyword;

/// 话题搜索
/// @param keyWord 关键词
+ (CTRequest *)searchQuestionByKeyword:(NSString *)keyWord pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize;

/// 观点搜索
/// @param keyWord 关键词
+ (CTRequest *)searchAnswerByKeyword:(NSString *)keyWord pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize;

/// 用户搜索
/// @param keyWord 关键词
+ (CTRequest *)searchUserByKeyword:(NSString *)keyWord pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize;

@end

NS_ASSUME_NONNULL_END
