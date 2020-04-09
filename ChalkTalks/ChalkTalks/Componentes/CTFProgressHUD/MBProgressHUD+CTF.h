//
//  MBProgressHUD+CTF.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/9.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "MBProgressHUD.h"

// 统一的显示时长
#define kHudShowTime 2.f

@interface MBProgressHUD (CTF)

#pragma mark 在指定的view上显示hud
+ (void)ctfShowMessage:(NSString *)message toView:(UIView *)view;
+ (void)ctfShowSuccess:(NSString *)success toView:(UIView *)view;
+ (void)ctfShowError:(NSString *)error toView:(UIView *)view;
+ (void)ctfShowWarning:(NSString *)warning toView:(UIView *)view;
+ (void)ctfShowMessageWithImageName:(NSString *)imageName message:(NSString *)message toView:(UIView *)view;
+ (MBProgressHUD *)ctfShowActivityMessage:(NSString*)message view:(UIView *)view;
+ (MBProgressHUD *)ctfShowLoading:(UIView *)view title:(NSString *)title;
+ (MBProgressHUD *)ctfShowProgressBarToView:(UIView *)view;
+ (MBProgressHUD *)ctfShowProgressingToView:(UIView *)view;

#pragma mark 在window上显示hud
+ (void)ctfShowMessage:(NSString *)message;
+ (void)ctfShowSuccess:(NSString *)success;
+ (void)ctfShowError:(NSString *)error;
+ (void)ctfShowWarning:(NSString *)warning;
+ (void)ctfShowMessageWithImageName:(NSString *)imageName message:(NSString *)message;
+ (MBProgressHUD *)ctfShowActivityMessage:(NSString*)message;

#pragma mark 移除hud
+ (void)ctfHideHUDForView:(UIView *)view;
+ (void)ctfHideHUD;

@end

/* 纯文字说明
 
 [MBProgressHUD ctfShowMessage:@"网络出现了异常"];
 */


/* Loading 小菊花
 
MBProgressHUD *hub = [MBProgressHUD ctfShowLoading:self.view title:@""];
[hub hideAnimated:YES afterDelay:1.5];
*/


/* Progress 进度显示
 
MBProgressHUD *hud = [MBProgressHUD ctfShowProgressingToView:nil];
// 模拟网络请求进度
dispatch_async(dispatch_get_global_queue(0, 0), ^{

    float progress = 0.01f;

    while (progress < 0.99f) {
        progress += 0.01f;
        // 主线程刷新进度
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.progress = progress;
        });
        // 进程挂起50毫秒
        usleep(50000);
    }
    // 100%后移除
    dispatch_async(dispatch_get_main_queue(), ^{
        [hud hideAnimated:YES];
    });
});
*/

