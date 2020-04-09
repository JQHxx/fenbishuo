//
//  CTFUtilsApi.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/17.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFUtilsApi : NSObject


/// 举报接口
/// @param resourceId  resourceType 对应的 id
/// @param resourceType  话题：question ------ 观点：answer ------ 评论：comment
+ (CTRequest *)reportContent:(NSInteger)resourceId
                resourceType:(NSString *)resourceType
               feedbackTitle:(NSString *)feedbackTitle
                     content:(NSString *)content
                       email:(NSString *)email
                    imageIds:(NSArray *)imageIds;

/// 问题反馈、投诉
/// @param content 反馈内容
/// @param imageIds 图片id数组
/// @param feedbackType 反馈类型：反馈：@"feedback" 投诉："complain"
/// @param email 邮箱
+ (CTRequest *)creatFeedbakWithContent:(NSString *)content imageIds:(NSArray*)imageIds feedbackType:(NSString *)feedbackType email:(NSString *)email;

/* 检测版本
 */
+(CTRequest*)checkVersion;

/*
 * 系统配置
 */
+(CTRequest*)systemConfigs;

/*
 * 设备信息上报
 */
+ (CTRequest *)uploadUserDeviceInfoWithAppLaunching:(BOOL)appLauching;

@end

NS_ASSUME_NONNULL_END
