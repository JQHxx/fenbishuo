//
//  CTFLoginApi.m
//  ChalkTalks
//
//  Created by 何雨晴 on 2019/12/6.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFLoginApi.h"
@import AFNetworking;
#import "LibKey.h"

static NSString * const api_vi_wechatLogin = @"/api/v1/auth/wechat_login";
static NSString * const api_vi_phoneLogin = @"/api/v1/auth/mobile_login";
static NSString * const api_vi_getCode = @"/api/v1/sms_code";
static NSString * const api_vi_phoneBind = @"/api/v1/auth/bind_mobile";
static NSString * const api_vi_logout = @"/api/v1/auth/logout";
static NSString * const api_vi_verification_login = @"/api/v1/auth/verification_login";

@implementation CTFLoginApi

/* 获取验证码 */
+ (CTRequest *)getCodeWith:(NSString *)phone type:(NSString *)type {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"mobile"] = phone;
    params[@"type"] = type;
    
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_vi_getCode argument:params method:YTKRequestMethodPOST];
    
    return request;
}

/* 手机号码登录 */
+ (CTRequest *)phoneLoginApi:(NSString *)phone code:(NSString *)code {
        
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"mobile"] = phone;
    params[@"code"] = code;
    
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_vi_phoneLogin argument:params method:YTKRequestMethodPOST];
    
    return request;
}

/* 手机号绑定 */
+ (CTRequest *)bindPhone:(NSString *)phone code:(NSString *)code {

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"mobile"] = phone;
    params[@"code"] = code;
    
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_vi_phoneBind argument:params method:YTKRequestMethodPUT];
    
    return request;
}

/* 微信登录 */
+ (CTRequest *)wechatLoginApi:(NSString *)openId unionId:(NSString *)unionId name:(NSString *)name gender:(NSString *)gender avatarUrl:(NSString *)avatarUrl {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"openId"] = openId;
    params[@"unionId"] = unionId;
    params[@"name"] = name;
    params[@"gender"] = gender;
    params[@"avatarUrl"] = avatarUrl;
    
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_vi_wechatLogin argument:params method:YTKRequestMethodPOST];
    
    return request;
}

/* 从微信获取access_token和openid，并利用access_token和openid从微信获取用户的个人信息 */
+ (void)getWechatUserInfo:(NSString *)code complete:(void(^)(NSDictionary * _Nullable dic, NSError * _Nullable error))completeBlock {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json", @"text/json", @"text/javascript",nil];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"appid"] = wxAPPID;
    params[@"secret"] = wxAPPSECRET;
    params[@"code"] = code;
    params[@"grant_type"] = @"authorization_code";
    
    [manager GET:@"https://api.weixin.qq.com/sns/oauth2/access_token" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSString *token = [responseObject valueForKey:@"access_token"];
        NSString *openid = [responseObject valueForKey:@"openid"];
        
        [CTFLoginApi getWechatToken:token openId:openid complete:^(NSDictionary * _Nullable dic, NSError * _Nullable error) {
            
            if (completeBlock) {
                completeBlock(dic, error);
            }
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completeBlock) {
            completeBlock(nil, error);
        }
    }];
}

/* 利用access_token和openid从微信获取用户的个人信息 */
+ (void)getWechatToken:(NSString *)wechatToken openId:(NSString *)openId complete:(void(^)(NSDictionary * _Nullable dic, NSError * _Nullable error))completeBlock {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json", @"text/json", @"text/javascript",nil];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = wechatToken;
    params[@"openid"] = openId;
    
    [manager GET:@"https://api.weixin.qq.com/sns/userinfo" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"getWechatToken：%@----%@", [responseObject class], responseObject);
        NSString *unionId = [responseObject safe_objectForKey:@"unionid"];
        NSString *name = [responseObject safe_objectForKey:@"nickname"];
        NSString *gender = (int)[responseObject safe_objectForKey:@"sex"] == 1 ? @"female" : @"male";
        NSString *avatarUrl = [responseObject safe_objectForKey:@"headimgurl"];
        
        NSMutableDictionary *respondDic = [NSMutableDictionary dictionary];
        respondDic[@"openId"] = openId;
        respondDic[@"unionId"] = unionId;
        respondDic[@"name"] = name;
        respondDic[@"gender"] = gender;
        respondDic[@"avatarUrl"] = avatarUrl;
        if (completeBlock) {
            completeBlock(respondDic, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (completeBlock) {
            completeBlock(nil, error);
        }
    }];
}

/* 退出登录 */
+ (CTRequest *)logout {
    
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_vi_logout argument:nil method:YTKRequestMethodPOST];
    
    return request;
}

#pragma mark - 手机号一键登录
+ (CTRequest *)phoneVerification_loginWithAccessToken:(NSString *)accessToken pushId:(NSString *)pushId {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"accessToken"] = accessToken;
    params[@"pushId"] = pushId;
    
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_vi_verification_login argument:params method:YTKRequestMethodPOST];
    
    return request;
}

#pragma mark - 手机号一键绑定
+ (CTRequest *)phoneVerification_bindWithAccessToken:(NSString *)accessToken {

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"type"] = @"verify";
    params[@"accessToken"] = accessToken;
    
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_vi_phoneBind argument:params method:YTKRequestMethodPUT];
    
    return request;
}

@end
