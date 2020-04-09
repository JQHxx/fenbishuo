//
//  UIViewController+CTF_CheckLoginStatement.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/26.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "UIViewController+CTF_CheckLoginStatement.h"
#import "PhoneLoginViewController.h"
#import <ATAuthSDK/ATAuthSDK.h>
#import "WXApi.h"
#import "LoginViewController.h"

@implementation UIViewController (CTF_CheckLoginStatement)

/*
 🔭传入参数：需要登录：
 1 判断是否在登录状态
    1.1 在登录状态
        return YES
    1.2 不再登录状态
        return NO
        1.2.1 是否安装了微信 yes--jump微信登录引导界面 no--下一步：
        1.2.2 是否有手机卡 yes--jump手机号一键登录界面 no--下一步：
        1.2.3 jump手机号验证码登录界面
 
 🔭传入参数：需要绑定：
 1 判断是否在登录状态
    1.1 在登录状态
        1.1.1 已绑定手机号 return YES
        1.1.2 未绑定手机号 return NO，进入2
    1.2 不在登录状态
        return NO
        1.2.1 是否安装了微信 yes--jump微信登录引导界面（登录成功后重新进入1） no--下一步：
        1.2.2 是否有手机卡 yes--jump手机号一键登录界面 no--下一步：
        1.2.3 jump手机号验证码登录界面
 2 绑定手机号
    2.1 是否有手机卡 yes--jump手机号一键绑定界面 no--下一步：
    2.2 jump手机号验证码绑定界面
 */

- (BOOL)ctf_checkLoginStatement {
    
    if ([UserCache isUserLogined] == UserLoginStatus_NotLogin) {
        
        [ROUTER routeByCls:kLoginViewController param:@{@"isContinueBindPhone" : @(YES)} animation:false presentWithNavBar:YES];
        
        return NO;
    }
    if ([UserCache isUserLogined] == UserLoginStatus_UnBindPhone) {
        PhoneLoginViewController *phoneLoginViewController = [[PhoneLoginViewController alloc] initWithFunctionType:CTFFunctionType_Bind];
        phoneLoginViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:phoneLoginViewController animated:YES completion:nil];
        return NO;
    }
    return YES;
}

- (BOOL)ctf_checkLoginStatementByNeededStation:(CTFNeededLoginStationType)neededLoginStationType {
    
    if (neededLoginStationType == CTFNeededLoginStationType_Logined) {
        if ([UserCache isUserLogined] == UserLoginStatus_NotLogin) {
            if (![[CTENVConfig share] enablePhoneLogin] && [WXApi isWXAppInstalled]) {
                // 安装了微信app
                [ROUTER routeByCls:kLoginViewController param:@{@"isContinueBindPhone" : @(NO)} animation:false presentWithNavBar:YES];
            } else {
                @weakify(self);
                TXCustomModel *model = [self setupCustomModelByFunctionType:CTFNeededLoginStationType_Logined];
                [self checkEnvAvailableForPhoneVerificationComplete:^(BOOL isAvailable) {
                    @strongify(self);
                    if (isAvailable) {
                        [self fetchPhoneVerificationWithViewModel:model accessTokenComplete:^(BOOL isSuccess, NSString *accessToken, NSString *code) {
                            if (isSuccess) {
                                CTRequest *request = [CTFLoginApi phoneVerification_loginWithAccessToken:accessToken pushId:@""];
                                [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
                                    if (isSuccess) {
                                        NSLog(@"一键登录成功:%@", data);
                                        UserModel *model = [UserModel yy_modelWithJSON:data[@"user"]];
                                        if (!model.isBlocked) {/* 判断是否被拉黑 */
                                            [UserCache saveUserInfo:model];
                                            [UserCache saveUserAuthtoken:data[@"apiToken"]];
                                            [UserCache saveUserIsNew:data[@"isNew"]];
                                            [[NSNotificationCenter defaultCenter] postNotificationName:kLoginedNotification object:nil];
                                        } else {
                                            [kKeyWindow makeToast:@"该账号因违反《粉笔说用户协议》，已被禁用"];
                                        }
                                    }
                                    [[TXCommonHandler sharedInstance] cancelLoginVCAnimated:YES complete:nil];
                                }];
                            } else {
                                @weakify(self);
                                [[TXCommonHandler sharedInstance] cancelLoginVCAnimated:YES complete:^{
                                    @strongify(self);
                                    // 跳转到手机号码验证界面
                                    PhoneLoginViewController *phoneLoginViewController = [[PhoneLoginViewController alloc] initWithFunctionType:CTFFunctionType_Login];
                                    phoneLoginViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                                    [self presentViewController:phoneLoginViewController animated:YES completion:nil];
                                }];
                            }
                        }];
                    } else {
                        // 跳转到手机号码验证界面
                        PhoneLoginViewController *phoneLoginViewController = [[PhoneLoginViewController alloc] initWithFunctionType:CTFFunctionType_Login];
                        phoneLoginViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                        [self presentViewController:phoneLoginViewController animated:YES completion:nil];
                    }
                }];
            }
            return NO;
        } else {
            return YES;// 需要登录，若已经在登录状态了，直接返回YES
        }
    } else {// 需要绑定
        if ([UserCache isUserLogined] == UserLoginStatus_NotLogin) {
            if (![[CTENVConfig share] enablePhoneLogin] && [WXApi isWXAppInstalled]) {
                 // 安装了微信app
                [ROUTER routeByCls:kLoginViewController param:@{@"isContinueBindPhone" : @(YES)} animation:false presentWithNavBar:YES];
            } else {
                @weakify(self);
                TXCustomModel *model = [self setupCustomModelByFunctionType:CTFNeededLoginStationType_Logined];
                [self checkEnvAvailableForPhoneVerificationComplete:^(BOOL isAvailable) {
                    @strongify(self);
                    if (isAvailable) {
                        [self fetchPhoneVerificationWithViewModel:model accessTokenComplete:^(BOOL isSuccess, NSString *accessToken, NSString *code) {
                            if (isSuccess) {
                                CTRequest *request = [CTFLoginApi phoneVerification_loginWithAccessToken:accessToken pushId:@""];
                                [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
                                    if (isSuccess) {
                                        NSLog(@"一键登录成功:%@", data);
                                        UserModel *model = [UserModel yy_modelWithJSON:data[@"user"]];
                                        if (!model.isBlocked) {/* 判断是否被拉黑 */
                                            [UserCache saveUserInfo:model];
                                            [UserCache saveUserAuthtoken:data[@"apiToken"]];
                                            [UserCache saveUserIsNew:data[@"isNew"]];
                                            [[NSNotificationCenter defaultCenter] postNotificationName:kLoginedNotification object:nil];
                                        } else {
                                            [kKeyWindow makeToast:@"该账号因违反《粉笔说用户协议》，已被禁用"];
                                        }
                                    }
                                    [[TXCommonHandler sharedInstance] cancelLoginVCAnimated:YES complete:nil];
                                }];
                            } else {
                                @weakify(self);
                                [[TXCommonHandler sharedInstance] cancelLoginVCAnimated:YES complete:^{
                                    @strongify(self);
                                    // 跳转到手机号码验证界面
                                    PhoneLoginViewController *phoneLoginViewController = [[PhoneLoginViewController alloc] initWithFunctionType:CTFFunctionType_Login];
                                    phoneLoginViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                                    [self presentViewController:phoneLoginViewController animated:YES completion:nil];
                                }];
                            }
                        }];
                    } else {
                        // 跳转到手机号码验证界面
                        PhoneLoginViewController *phoneLoginViewController = [[PhoneLoginViewController alloc] initWithFunctionType:CTFFunctionType_Login];
                        phoneLoginViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                        [self presentViewController:phoneLoginViewController animated:YES completion:nil];
                    }
                }];
            }
            return NO;
        } else {// 在登录状态
            if ([UserCache isUserLogined] == UserLoginStatus_BindPhone) {
                return YES;// 需要绑定，若已经在绑定状态，直接返回YES
            } else {// 在登录状态，但是没有绑定手机号
                @weakify(self);
                TXCustomModel *model = [self setupCustomModelByFunctionType:CTFNeededLoginStationType_Binded];
                [self checkEnvAvailableForPhoneVerificationComplete:^(BOOL isAvailable) {
                    @strongify(self);
                    if (isAvailable) {
                        [self fetchPhoneVerificationWithViewModel:model accessTokenComplete:^(BOOL isSuccess, NSString *accessToken, NSString *code) {
                            if (isSuccess) {
                                CTRequest *request = [CTFLoginApi phoneVerification_bindWithAccessToken:accessToken];
                                [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
                                    if (isSuccess) {
                                        NSLog(@"一键绑定成功:%@", data);
                                        UserModel *model = [UserModel yy_modelWithJSON:data];
                                        if (!model.isBlocked) {/* 判断是否被拉黑 */
                                            [UserCache saveUserInfo:model];
                                            [[NSNotificationCenter defaultCenter] postNotificationName:kLoginedNotification object:nil];
                                        } else {
                                            [kKeyWindow makeToast:@"该账号因违反《粉笔说用户协议》，已被禁用"];
                                        }
                                    }
                                    [[TXCommonHandler sharedInstance] cancelLoginVCAnimated:YES complete:nil];
                                }];
                            } else {
                                @weakify(self);
                                [[TXCommonHandler sharedInstance] cancelLoginVCAnimated:YES complete:^{
                                    @strongify(self);
                                    // 跳转到手机号码验证界面
                                    PhoneLoginViewController *phoneLoginViewController = [[PhoneLoginViewController alloc] initWithFunctionType:CTFFunctionType_Bind];
                                    phoneLoginViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                                    [self presentViewController:phoneLoginViewController animated:YES completion:nil];
                                }];
                            }
                        }];
                    } else {
                        // 跳转到手机号码验证界面
                        PhoneLoginViewController *phoneLoginViewController = [[PhoneLoginViewController alloc] initWithFunctionType:CTFFunctionType_Bind];
                        phoneLoginViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                        [self presentViewController:phoneLoginViewController animated:YES completion:nil];
                    }
                }];
                return NO;
            }
        }
    }
}

#pragma mark 检测能否进行手机号码认证
- (void)checkEnvAvailableForPhoneVerificationComplete:(void(^)(BOOL isAvailable))complete {
    __block MBProgressHUD *loadingHUD = nil;
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        loadingHUD = [MBProgressHUD ctfShowLoading:self.view title:@""];
    });
    [[TXCommonHandler sharedInstance] checkEnvAvailableWithComplete:^(NSDictionary * _Nullable resultDic) {
        if ([PNSCodeSuccess isEqualToString:[resultDic objectForKey:@"resultCode"]] == NO) {
            if (complete) complete(NO);
            dispatch_async(queue, ^{
                [loadingHUD hideAnimated:YES];
            });
        } else {
            [[TXCommonHandler sharedInstance] accelerateLoginPageWithTimeout:3.0 complete:^(NSDictionary * _Nonnull resultDic) {
                if ([PNSCodeSuccess isEqualToString:[resultDic objectForKey:@"resultCode"]]) {
                    if (complete) complete(YES);
                }
                dispatch_async(queue, ^{
                    [loadingHUD hideAnimated:YES];
                });
            }];
        }
    }];
}

- (void)fetchPhoneVerificationWithViewModel:(TXCustomModel *_Nullable)model accessTokenComplete:(void(^)(BOOL isSuccess, NSString *accessToken, NSString *code))completeBlock {
    
    [[TXCommonHandler sharedInstance] getLoginTokenWithTimeout:3 controller:self model:model complete:^(NSDictionary * _Nonnull resultDic) {
        NSString *code = [resultDic objectForKey:@"resultCode"];
        
        if ([PNSCodeLoginControllerPresentSuccess isEqualToString:code]) {
            // 唤起授权页成功
            
        } else if ([PNSCodeLoginControllerClickCancel isEqualToString:code]) {
            // 点击返回，⽤户取消一键登录
            
        } else if ([PNSCodeLoginControllerClickChangeBtn isEqualToString:code]) {
            // 点击切换按钮，⽤户取消免密登录
            if (completeBlock) {
                completeBlock(NO, nil, code);
            }
            
        } else if ([PNSCodeLoginControllerClickLoginBtn isEqualToString:code]) {
            // 点击登录按钮事件
            if ([[resultDic objectForKey:@"isChecked"] boolValue] == YES) {
                
            } else {
                
            }
        } else if ([PNSCodeLoginControllerClickCheckBoxBtn isEqualToString:code]) {
            // 点击CheckBox事件
            
        } else if ([PNSCodeLoginControllerClickProtocol isEqualToString:code]) {
            // 点击协议富文本文字
            
        } else if ([PNSCodeSuccess isEqualToString:code]) {
            // 点击登录按钮获取登录Token成功回调
            NSString *token = [resultDic objectForKey:@"token"];
            if (!token || token.length == 0) {
                return;
            }
            //
            if (completeBlock) {
                completeBlock(YES, token, code);
            }
        } else {
            
        }
    }];
}

// 获取当前屏幕显示的viewcontroller
+ (UIViewController *)getWindowsCurrentVC {
    
    UIViewController *result = nil;
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    do {
        if ([rootVC isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navi = (UINavigationController *)rootVC;
            UIViewController *vc = [navi.viewControllers lastObject];
            result = vc;
            rootVC = vc.presentedViewController;
            continue;
        } else if ([rootVC isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)rootVC;
            result = tab;
            rootVC = [tab.viewControllers objectAtIndex:tab.selectedIndex];
            continue;
        } else if ([rootVC isKindOfClass:[UIViewController class]]) {
            result = rootVC;
            rootVC = nil;
        }
    } while (rootVC != nil);
    
    return result;
}

- (UIImage *)imageForView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    } else {
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (TXCustomModel *)setupCustomModelByFunctionType:(CTFNeededLoginStationType)functionType {
    
    NSString *loginBtnString = @"";
    NSString *changeBtnString = @"";
    NSString *privacyPreString = @"";
    if (functionType == CTFNeededLoginStationType_Logined) {
        loginBtnString = @"本机号码一键登录";
        changeBtnString = @"使用其他号登录";
        privacyPreString = @"登录表明已阅读并同意";
    } else {
        loginBtnString = @"本机号码一键绑定";
        changeBtnString = @"使用其他号绑定";
        privacyPreString = @"绑定表明已阅读并同意";
    }
    
    TXCustomModel *model = [[TXCustomModel alloc] init]; //默认，注：model的构建需要放在主线程
    
    // 导航栏
    model.navColor = UIColorFromHEX(0xFFFFFF);
    model.navTitle = [[NSMutableAttributedString alloc] initWithString:@""];
    model.navBackImage = [UIImage imageNamed:@"icon_nav_goBack_20x20"];
    
    // logo
    UILabel *logoText = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreen_Width, 20)];
    logoText.text = @"根据相关法律要求，完成手机号验证才能在社区发布内容";
    logoText.font = [UIFont systemFontOfSize:12];
    logoText.textColor = UIColorFromHEX(0x999999);
    logoText.textAlignment = NSTextAlignmentCenter;
    model.logoImage = [self imageForView:logoText];
    model.logoFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        return CGRectMake(0, 19, screenSize.width, 20);
    };
    
    // 手机号码
    model.numberFont = [UIFont systemFontOfSize:24];
    model.numberFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        return CGRectMake((screenSize.width-145)/2.f, 215, 145, 33);
    };
    
    // 中国电信提供认证服务
    model.sloganFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        return CGRectMake((screenSize.width-230)/2.f, 251, 230, 20);
    };
    
    // 认证按钮
    NSString *text_loginBtn = loginBtnString;
    NSMutableAttributedString *contentAttribut_loginBtn = [[NSMutableAttributedString alloc] initWithString:text_loginBtn];
    NSMutableParagraphStyle *paragraphStyle_loginBtn = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle_loginBtn setAlignment:NSTextAlignmentCenter];
    [contentAttribut_loginBtn addAttribute:NSParagraphStyleAttributeName
                          value:paragraphStyle_loginBtn
                          range:NSMakeRange(0, [contentAttribut_loginBtn length])];
    [contentAttribut_loginBtn addAttribute:NSForegroundColorAttributeName value:UIColorFromHEX(0xFFFFFF) range:NSMakeRange(0, [contentAttribut_loginBtn length])];
    model.loginBtnText = contentAttribut_loginBtn;
    
    model.loginBtnBgImgs = @[
        [UIImage ctRoundRectImageWithFillColor: UIColorFromHEXWithAlpha(0xFF6885, 1.0) cornerRadius:23],
        [UIImage ctRoundRectImageWithFillColor: UIColorFromHEXWithAlpha(0xFF6885, 0.5) cornerRadius:23],
        [UIImage ctRoundRectImageWithFillColor: UIColorFromHEXWithAlpha(0xFF6885, 0.5) cornerRadius:23]];
    model.loginBtnFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        return CGRectMake(72, 387, screenSize.width-2*72, 46);
    };
    
    // 使用其他号码
    NSString *text_changeBtn = changeBtnString;
    NSMutableAttributedString *contentAttribut_changeBtn = [[NSMutableAttributedString alloc] initWithString:text_changeBtn];
    [contentAttribut_changeBtn addAttribute:NSForegroundColorAttributeName value:UIColorFromHEX(0x999999) range:NSMakeRange(0, [contentAttribut_changeBtn length])];
    [contentAttribut_changeBtn addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, [contentAttribut_changeBtn length])];
    
    model.changeBtnTitle = contentAttribut_changeBtn;
    
    model.changeBtnFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
        return CGRectMake((screenSize.width-230)/2.f, 449, 230, 20);
    };
    
    // 协议
    model.checkBoxIsChecked = YES;
    model.checkBoxIsHidden = YES;
    model.privacyOne = @[@"《粉笔说使用条款和隐私政策》", [NSString stringWithFormat:@"%@%@", [[CTENVConfig share] h5BaseUrl], @"/appview/protocol/index"]];
    model.privacyColors = @[UIColorFromHEX(0x999999), UIColorFromHEX(0xFF6885)];
    model.privacyAlignment = NSTextAlignmentCenter;
    model.privacyPreText = privacyPreString;
    model.privacyFont = [UIFont systemFontOfSize:12];
    model.privacyOperatorPreText = @"《";
    model.privacyOperatorSufText = @"》";
    
    // 协议详情页
    model.privacyNavBackImage = [UIImage imageNamed:@"icon_nav_goBack_20x20"];
    
    return model;
}

@end

/*
 搜索无内容时点击“提要求/求推荐”按钮 （登录并绑定）
 点击消息按钮（登录）
 点击我的按钮（登录）

 点击“关心”（登录并绑定）、“踩”（登录）
 点击“靠谱”（登录）、“不靠谱”（登录）
 点击评论和回复的‘靠谱’（登录）

 点击“评论”/“回复”按钮（登录并绑定）
 关注、取消关注用户（登录并绑定）
 点击提要求按钮（登录并绑定）
 点击求推荐按钮（登录并绑定）

 话题详情页面右上角的分享按钮（登录和绑定）
 话题详情列表中回答cell中的关注用户按钮（登录并绑定）
 话题详情页面底部的“我来回答”按钮（登录并绑定）
 话题详情列表中回答cell中的评论按钮（登录并绑定）
 话题详情列表中回答cell中的更多按钮（登录并绑定）

 个人信息修改==
 个人设置中的头像设置（登录并绑定）
 个人设置中的性别设置（登录并绑定）
 个人设置中的昵称设置（登录并绑定）
 个人设置中的个性签名设置（登录并绑定）

 个人主页中点击个人设置按钮（登录并绑定）
 其他人的个人主页点击粉丝列表按钮（无需登录/绑定）
 其他人的个人主页点击关注列表按钮（无需登录/绑定）
 */
