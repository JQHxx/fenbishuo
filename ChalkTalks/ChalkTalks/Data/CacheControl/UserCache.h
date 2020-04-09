//
//  UserCache.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UserLoginStatus) {
    UserLoginStatus_NotLogin = 0x00,     //没有登录
    UserLoginStatus_UnBindPhone = 0x01,    //需要绑定手机号
    UserLoginStatus_Logined = 0x10,      //已登录
    UserLoginStatus_BindPhone            //已绑定
};

typedef NS_ENUM(NSInteger, CTFUserLoginStatusType) {
    CTFUserLoginStatusType_UnSelected,//未进入
    CTFUserLoginStatusType_Tourist,//游客模式
    CTFUserLoginStatusType_Wx_UnBind,//微信登录+没绑定手机
    CTFUserLoginStatusType_Wx_Bind,//微信登录+绑定手机
    CTFUserLoginStatusType_PhoneIn//手机号登录
};

NS_ASSUME_NONNULL_BEGIN

@interface UserCache : NSObject

/// 当前用户登录状态
+ (UserLoginStatus)isUserLogined;

/// 当前登录用户的UserID,游客模式返回@"tourist"
+ (NSString *)getCurrentUserID;


/// 设置当前用户的API请求Token
/// @param token 登录成功返回的Token
+ (void)saveUserAuthtoken:(NSString *)token;
/// 当前用户的API请求Token
+ (NSString *)getUserAuthtoken;


/// 设置当前用户是否是新用户注册
/// @param isNew 是否是新用户注册
+ (void)saveUserIsNew:(NSNumber *)isNew;
/// 当前用户时候是新用户注册
+ (BOOL)getUserIsNew;


/// 设置用户信息UserModel
/// @param userinfo  用户信息UserModel
+ (void)saveUserInfo:(UserModel *)userinfo;
/// 获取用户信息UserModel
+ (UserModel *)getUserInfo;


/// 清空缓存
+ (void)clearUserCache;

///上传设备信息
+ (void)uploadUserDeviceInfoWithAppLaunching:(BOOL)appLauching;


@end

NS_ASSUME_NONNULL_END
