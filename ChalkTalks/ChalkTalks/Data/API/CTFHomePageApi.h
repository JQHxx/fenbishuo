//
//  CTFHomePageApi.h
//  ChalkTalks
//
//  Created by vision on 2019/12/26.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFHomePageApi : NSObject

/*
 * 获取用户的详情
 * @param userId 用户ID 
 * @param isMine 是否自己
 */
+ (CTRequest *)requestUserDetailsDataWithUserId:(NSInteger)userId isMine:(BOOL)isMine;

/*
 * 获取用户的动态信息
 * @param userId 用户ID
 * @param page 页码
 * @param pageSize 每页个数
 */
+ (CTRequest *)requestUserActivitiesDataWithUserId:(NSInteger)userId page:(NSInteger)page pageSize:(NSInteger)pageSize;

/*
 * 关注用户
 * @param userId 用户ID
 */
+ (CTRequest *)requestForFollowWithUserId:(NSInteger)userId;

@end

NS_ASSUME_NONNULL_END
