//
//  UIViewController+Helpers.h
//  VFit
//
//  Created by zingwin on 15/1/13.
//  Copyright (c) 2015年 zingwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Helpers)
//小菊花
- (void)showHudInView:(UIView *)view hint:(NSString *)hint;
- (void)hideHud;
- (void)showHint:(NSString *)hint;
- (void)showHint:(NSString *)hint yOffset:(float)yOffset;  // 从默认(showHint:)显示的位置再往上(下)yOffset

//点击隐藏键盘
-(void)setupForDismissKeyboard;

//
- (UIViewController *)topViewController;

@end
