//
//  LoginViewModel.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "BaseViewModel.h"
#import "CTFLoginApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoginViewModel : BaseViewModel

/// 微信授权登录
- (void)wechatAuthorizationLogin:(AdpaterComplete)complete;

/// 获取短信验证码
/// @param phone 手机号
/// @param type 类型 验证码类型【bind:绑定(会做手机号唯一性验证)】【login:登录】
/// @param complete 成功回调
- (void)getCode:(NSString *)phone type:(NSString *)type complete:(void(^)(NSString *code, NSInteger leftTime, NSError *error))complete;

/// 手机登录
/// @param phone 手机号码
/// @param code 验证码
/// @param complete 回调
- (void)phoneLoginAndRegister:(NSString * _Nonnull)phone code:(NSString * _Nonnull) code complete:(AdpaterComplete)complete;

/// 手机号绑定
/// @param phone 需要绑定的手机号
/// @param code 验证码
/// @param complete 回调
- (void)bindPhone:(NSString *)phone code:(NSString *)code complete:(AdpaterComplete)complete;

/// 退出登录
- (void)logout:(AdpaterComplete)complete;

@end

NS_ASSUME_NONNULL_END
