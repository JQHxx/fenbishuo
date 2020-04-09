//
//  UIViewController+CTF_CheckLoginStatement.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/26.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CTFNeededLoginStationType) {
    CTFNeededLoginStationType_Logined = 0,//需要登录
    CTFNeededLoginStationType_Binded      //需要绑定
};

@interface UIViewController (CTF_CheckLoginStatement)

- (BOOL)ctf_checkLoginStatement;

- (BOOL)ctf_checkLoginStatementByNeededStation:(CTFNeededLoginStationType)neededLoginStationType;

// 获取当前屏幕显示的viewcontroller
+ (UIViewController *)getWindowsCurrentVC;

@end

NS_ASSUME_NONNULL_END
