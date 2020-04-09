//
//  LoginViewModel.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "LoginViewModel.h"
#import "WXApi.h"
#import "AppNotification.h"
@import AFNetworking;
#import "LibKey.h"
#import "UserCache.h"

@interface LoginViewModel ()<WXApiDelegate>
@property (nonatomic, copy) AdpaterComplete wechatLoginBlock;
@property (nonatomic, strong) MBProgressHUD *loadingHUD;
@end

@implementation LoginViewModel

- (instancetype)init {
    if (self = [super init]) {
        [self setupMonitor];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/* 监听微信登录授权成功的通知 */
- (void)setupMonitor {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondsToNotification:) name:kWechatLoginSuccessNotification object:nil];
}

/* 调用微信登录授权页面 */
- (void)wechatAuthorizationLogin:(AdpaterComplete)complete {
    
    SendAuthReq *req = [[SendAuthReq alloc]init];
    req.scope = @"snsapi_userinfo";
    req.state = @"wx_oauth_authorization_state";
    self.wechatLoginBlock = complete;
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}

/* 微信登录授权成功响应事件 */
- (void)respondsToNotification:(NSNotification *)notification {
    
    /* code-授权临时票据 */
    NSString *code = (NSString *)notification.object;
    
    /* 获取微信用户的基本信息 */
    [self.loadingHUD showAnimated:YES];
    @weakify(self);
    [CTFLoginApi getWechatUserInfo:code complete:^(NSDictionary * _Nullable dic, NSError * _Nullable error) {
        @strongify(self);
        if (!error) {
            [self wechatLogin:dic];
        } else {
            [self.loadingHUD hideAnimated:YES];
            if (self.wechatLoginBlock) {
                self.wechatLoginBlock(NO);
            }
        }
    }];
}

/* 微信登录 */
- (void)wechatLogin:(NSDictionary *)dic {
    
    CTRequest *request = [CTFLoginApi
                          wechatLoginApi:dic[@"openId"]
                          unionId:dic[@"unionId"]
                          name:dic[@"name"]
                          gender:dic[@"gender"]
                          avatarUrl:dic[@"avatarUrl"]];
    
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, NSDictionary * _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self.loadingHUD hideAnimated:YES];
        [self handlerError:error];
        if (!error) {
            UserModel *model = [UserModel yy_modelWithJSON:data[@"user"]];
            if (!model.isBlocked) {/* 判断是否被拉黑 */
                [UserCache saveUserInfo:model];
                [UserCache saveUserAuthtoken:data[@"apiToken"]];
                [UserCache saveUserIsNew:data[@"isNew"]];
                [[NSNotificationCenter defaultCenter] postNotificationName:kLoginedNotification object:nil];
                if (self.wechatLoginBlock) self.wechatLoginBlock(YES);
            } else {
                [kKeyWindow makeToast:@"该账号因违反《粉笔说用户协议》，已被禁用"];
                if (self.wechatLoginBlock) self.wechatLoginBlock(NO);
            }
        } else {
            if (self.wechatLoginBlock) self.wechatLoginBlock(NO);
            [kKeyWindow makeToast:self.errorString];
        }
    }];
}

/* 获取短信验证码 */
- (void)getCode:(NSString *)phone type:(NSString*)type complete:(void(^)(NSString *code, NSInteger leftTime, NSError *error))complete {
    
    CTRequest *request = [CTFLoginApi getCodeWith:phone type:type];
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        if (isSuccess) {
            if (complete){
                complete(data[@"code"], [data[@"leftTime"] integerValue], nil);
            }
        } else {
            if (complete){
                complete(nil, [data[@"leftTime"] integerValue], error);
            }
        }
    }];
}

/* 手机号登录 */
- (void)phoneLoginAndRegister:( NSString * _Nonnull )phone code:(NSString * _Nonnull)code complete:(AdpaterComplete)complete {
    
    [[CTFLoginApi phoneLoginApi:phone code:code] requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        if (error) {
            [self handlerError:error];
            complete(false);
        } else {
            UserModel *model = [UserModel yy_modelWithJSON:data[@"user"]];
            [UserCache saveUserInfo:model];
            [UserCache saveUserAuthtoken:data[@"apiToken"]];
            [UserCache saveUserIsNew:data[@"isNew"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLoginedNotification object:nil];
            complete(true);
        }
    }];
}

/* 手机号绑定 */
- (void)bindPhone:(NSString *)phone code:(NSString *)code complete:(AdpaterComplete)complete {
    
    @weakify(self);
    [[CTFLoginApi bindPhone:phone code:code] requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        if (error) {
            [self handlerError:error];
            complete(false);
        } else {
            //绑定成功之后重新获取下用户信息
            CTRequest *request = [CTFMineApi mineUserMessage];
            [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
                if (isSuccess) {
                    //重新获取成功了就刷新用户信息UserCache，没有成功就不重新赋值
                    NSDictionary *userMessage = data;
                    UserModel *model = [UserModel yy_modelWithJSON:userMessage];
                    [UserCache saveUserInfo:model];
                    //[UserCache saveUserAuthtoken:data[@"apiToken"]];
                    //[UserCache saveUserIsNew:data[@"isNew"]];
                } else {
                    
                }
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLoginedNotification object:nil];
            complete(true);
        }
    }];
}

/* 退出登录 */
- (void)logout:(AdpaterComplete)complete {
    
    CTRequest *request = [CTFLoginApi logout];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        if (isSuccess) {
            if (complete) complete(YES);
        } else {
            [self handlerError:error];
            if (complete) complete(NO);
        }
    }];
}

- (MBProgressHUD *)loadingHUD {
    if (!_loadingHUD) {
        _loadingHUD = [MBProgressHUD ctfShowLoading:nil title:@""];
    }
    return _loadingHUD;
}

@end
