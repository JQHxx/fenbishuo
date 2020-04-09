//
//  CTFLoginApi.h
//  ChalkTalks
//
//  Created by 何雨晴 on 2019/12/6.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFLoginApi : NSObject

/// 获取短信码
/// @param phone 手机号
/// @param type 类型 bind-绑定 login-登录
+ (CTRequest *)getCodeWith:(NSString *)phone type:(NSString *)type;


/// 手机登录请求
/// @param phone 手机号码
/// @param code 验证码
+ (CTRequest *)phoneLoginApi:(NSString *)phone code:(NSString *)code;


/// 绑定手机号码
/// @param phone 手机号码
/// @param code 验证码
+ (CTRequest *)bindPhone:(NSString *)phone code:(NSString *)code;


/// 微信登录
/// @param openId 微信参数：open_id
/// @param unionId 微信参数：union_id
/// @param name 微信参数：昵称
/// @param gender 微信参数：性别 【unknown:未知】 【male:男】 【female：女】
/// @param avatarUrl 微信参数：头像
+ (CTRequest *)wechatLoginApi:(NSString *)openId unionId:(NSString *)unionId name:(NSString *)name gender:(NSString *)gender avatarUrl:(NSString *)avatarUrl;


/// 获取微信用户信息
/// @param code 微信code
/// @param completeBlock 回调（用户信息、error）
+ (void)getWechatUserInfo:(NSString *)code complete:(void(^)(NSDictionary * _Nullable dic, NSError * _Nullable error))completeBlock;


/// 退出登录
+ (CTRequest *)logout;

+ (CTRequest *)phoneVerification_loginWithAccessToken:(NSString *)accessToken pushId:(NSString *)pushId;

+ (CTRequest *)phoneVerification_bindWithAccessToken:(NSString *)accessToken;

@end

NS_ASSUME_NONNULL_END
