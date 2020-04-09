//
//  AppDelegate+IQKeyboard.m
//  ChalkTalks
//
//  Created by zingwin on 2020/1/10.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "AppDelegate+IQKeyboard.h"
#import <IQKeyboardManager/IQKeyboardManager.h>

@implementation AppDelegate (IQKeyboard)

- (void)configIQKeyboard {
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    //默认为YES，关闭为NO
    manager.enable = YES;
    //键盘弹出时，点击背景，键盘收回
    manager.shouldResignOnTouchOutside = YES;
    //如果YES，那么使用textField的tintColor属性为IQToolbar，否则颜色为黑色。默认是否定的。
    manager.shouldToolbarUsesTextFieldTintColor = YES;
    //如果YES，则在IQToolbar上添加textField的占位符文本。默认是肯定的。
    manager.shouldShowToolbarPlaceholder = NO;
    //隐藏键盘上面的toolBar,默认是开启的
    manager.enableAutoToolbar = NO;
}

@end
