//
//  CTFMineApi.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/17.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFMineApi : NSObject

+ (CTRequest *)mineUserMessage;

+ (CTRequest *)reviseUserMessageByHeadLine:(NSString * _Nullable)headLine name:(NSString * _Nullable)name gender:(NSString * _Nullable)gender avatarImageId:(NSInteger)avatarImageId;


+ (CTRequest *)mineFansListDataByPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize;
+ (CTRequest *)userFansListDataByUserId:(NSInteger)userId pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize;

+ (CTRequest *)mineFollowListDataByPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize;
+ (CTRequest *)userFollowListDataByUserId:(NSInteger)userId pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize;

+ (CTRequest *)mineTopicListDataByPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize;

+ (CTRequest *)mineCareTopicListDataByPageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize;

/// 关注
/// @param userId  对象userID
+ (CTRequest *)followToUser:(NSInteger)userId;


/// 取消关注
/// @param userId  对象userID
+ (CTRequest *)unfollowerToUser:(NSInteger)userId;


/// 获得某用户的勋章墙信息
+ (CTRequest *)badgeWallMessageForUserId:(NSInteger)userId;

///上报分享资源行为
+ (CTRequest *)uploadShareEventWithResourceType:(NSString *)resourceType resourceId:(NSInteger)resourceId;

@end

NS_ASSUME_NONNULL_END


