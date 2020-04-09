//
//  AppDelegate.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/1.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIWindow *additionalWindow;

@property (nonatomic, assign) BOOL restrictRotation;

/* 与app同生命周期的计时器，用于登录注册获取验证码倒计时 */
@property (nonatomic, assign) NSInteger countDownTime;

@end

