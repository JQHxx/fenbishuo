//
//  EncryptUtils.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/4.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 加密相关的功能类
@interface EncryptUtils : NSObject

/// 加密方式,MAC算法:HmacSHA256
/// @param secret 密钥
/// @param content 需要加密的字符串
+ (NSString *)hmacSHA256WithSecret:(NSString *)secret content:(NSString *)content;

/// base64加密
/// @param string 需要加密的字符串
+ (NSString *)base64EncodeString:(NSString *)string;

/// base64解密
/// @param string 需要解密得字符串
+ (NSString *)base64DecodeString:(NSString *)string;

/// 32位小写MD5加密
/// @param string 需要加密的字符串
+ (NSString*)md5:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
