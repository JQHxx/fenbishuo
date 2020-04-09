//
//  CTFMessageApi.h
//  ChalkTalks
//
//  Created by lizhuojie on 2019/12/23.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTRequest.h"

@interface CTFMessageApi : NSObject

/// 获取所有(或某类)消息列表
/// @param categoryType 为空表示获取所有消息
+ (CTRequest * _Nonnull)getMessageList:(NSString * _Nullable)categoryType
                               pageIdx:(NSInteger)page
                              pageSize:(NSInteger)pageSize;

/// 设置某个分类全部消息为已读
+ (CTRequest * _Nonnull)readAll:(NSString * _Nonnull)category;

/// 批量(单个)设置某些(个)消息已读
/// @param ids 消息id
+ (CTRequest * _Nonnull)read:(NSArray * _Nonnull)ids;

/// 返回未读总数，以及每类未读消息数
+ (CTRequest * _Nonnull)getUnreadCount;

/// 上传push id (alias device token)
+ (CTRequest * _Nonnull)uploadDeviceToken:(NSString * _Nullable)token;

/// 消息统计
/// @param type 消息类型：MessageType reply, like, follower, system
/// @param tid 消息taskId
/// @param isPush 是否为推送
+ (CTRequest * _Nonnull)metricsReportWithType:(NSString * _Nullable)type
                                       taskId:(NSString * _Nullable)tid
                                       isPush:(BOOL)isPush;

@end
