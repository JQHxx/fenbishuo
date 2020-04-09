//
//  NSURL+Ext.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/9.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (Ext)

/// 把http urlz转为NSURL
/// @param URLString url字符串
+ (nullable instancetype)safe_URLWithString:(NSString *)URLString;
@end

NS_ASSUME_NONNULL_END
