//
//  MBProgressHUD+CTF.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/9.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "MBProgressHUD+CTF.h"
#import "UIImage+Ext.h"
#import "CTFSectorProgressView.h"

@implementation MBProgressHUD (CTF)

#pragma mark 显示一条信息
+ (void)ctfShowMessage:(NSString *)message toView:(UIView *)view {
    [self show:message icon:nil view:view];
}

#pragma mark 显示带图片或者不带图片的信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = text;
    hud.label.numberOfLines = 0;
    
    CGFloat bottomOffset = 19;
    CGFloat yOffset = view.bounds.size.height / 2.f - bottomOffset - 64 - 49;
    [hud setOffset:CGPointMake(0, yOffset)];
    // 判断是否显示图片
    if (icon == nil) {
        hud.mode = MBProgressHUDModeText;
        hud.userInteractionEnabled = NO;
    }else {
        // 设置图片
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]];
        img = img == nil ? [UIImage imageNamed:icon] : img;
        hud.customView = [[UIImageView alloc] initWithImage:img];
        // 再设置模式
        hud.mode = MBProgressHUDModeCustomView;
    }
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // 指定时间之后再消失
    [hud hideAnimated:YES afterDelay:kHudShowTime];
}

#pragma mark 显示成功信息
+ (void)ctfShowSuccess:(NSString *)success toView:(UIView *)view {
    [self show:success icon:@"success.png" view:view];
}

#pragma mark 显示错误信息
+ (void)ctfShowError:(NSString *)error toView:(UIView *)view {
    [self show:error icon:@"error.png" view:view];
}

#pragma mark 显示警告信息
+ (void)ctfShowWarning:(NSString *)warning toView:(UIView *)view {
    [self show:warning icon:@"warn" view:view];
}

#pragma mark 显示自定义图片信息
+ (void)ctfShowMessageWithImageName:(NSString *)imageName message:(NSString *)message toView:(UIView *)view {
    [self show:message icon:imageName view:view];
}

#pragma mark 加载中
+ (MBProgressHUD *)ctfShowActivityMessage:(NSString*)message view:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    // 细节文字
    //hud.detailsLabel.text = @"请耐心等待";
    // 再设置模式
    hud.mode = MBProgressHUDModeIndeterminate;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    return hud;
}

+ (MBProgressHUD *)ctfShowProgressBarToView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeDeterminate;
    hud.label.text = @"上传中···";
    return hud;
}

+ (void)ctfShowMessage:(NSString *)message {
    [self ctfShowMessage:message toView:nil];
}

+ (void)ctfShowSuccess:(NSString *)success {
    [self ctfShowSuccess:success toView:nil];
}

+ (void)ctfShowError:(NSString *)error {
    [self ctfShowError:error toView:nil];
}

+ (void)ctfShowWarning:(NSString *)warning {
    [self ctfShowWarning:warning toView:nil];
}

+ (void)ctfShowMessageWithImageName:(NSString *)imageName message:(NSString *)message {
    [self ctfShowMessageWithImageName:imageName message:message toView:nil];
}

+ (MBProgressHUD *)ctfShowActivityMessage:(NSString*)message {
    return [self ctfShowActivityMessage:message view:nil];
}

+ (void)ctfHideHUDForView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    [self hideHUDForView:view animated:YES];
}

+ (void)ctfHideHUD {
    [self ctfHideHUDForView:nil];
}

+ (MBProgressHUD *)ctfShowLoading:(UIView *)view title:(NSString *)title {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view==nil?[[UIApplication sharedApplication].windows lastObject]:view animated:NO];
    hud.mode = MBProgressHUDModeCustomView;
    hud.minSize = CGSizeMake(60, 60);//定义弹窗的大小
    
    UIView *mainImageView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    AnimationView *loadingAnimationView = [mainImageView showLoadingAnimation:CTLottieAnimationTypeLoading completion:nil];
    
    hud.customView = mainImageView;
    hud.animationType = MBProgressHUDAnimationFade;
    hud.bezelView.color = UIColorFromHEXWithAlpha(0xFFFFFF, 0.3);
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    
    [hud showAnimated:YES];
    
    [hud hideAnimated:YES afterDelay:10];
    
    return hud;
}

/*
+ (MBProgressHUD *)ctfShowLoading:(UIView *)view title:(NSString *)title {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view==nil?[[UIApplication sharedApplication].windows lastObject]:view animated:NO];
    hud.mode = MBProgressHUDModeCustomView;
    hud.minSize = CGSizeMake(34,34);//定义弹窗的大小
    
    UIImage *image = [[UIImage imageNamed:@"icon_loading"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIImageView *mainImageView= [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
    mainImageView.image = [image ctfResizingImageState];
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.fillMode = kCAFillModeForwards;
    [mainImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];

    hud.customView = mainImageView;
    hud.animationType = MBProgressHUDAnimationFade;
    hud.bezelView.color = [UIColor clearColor];
    
    [hud showAnimated:YES];
    
    [hud hideAnimated:YES afterDelay:10];
    
    return hud;
}
 */

+ (MBProgressHUD *)ctfShowProgressingToView:(UIView *)view {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view==nil?[[UIApplication sharedApplication].windows lastObject]:view animated:NO];
    hud.backgroundColor = UIColorFromHEXWithAlpha(0x000000, 0.5);
    hud.mode = MBProgressHUDModeCustomView;
    hud.minSize = CGSizeMake(100,100);//定义弹窗的大小
    
    CTFSectorProgressView *mainImageView= [[CTFSectorProgressView alloc] init];
    mainImageView.progress = 0.01;
    hud.customView = mainImageView;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [UIColor blackColor];

    hud.removeFromSuperViewOnHide = YES;
    hud.label.text = @"视频上传中";
    hud.label.textColor = UIColorFromHEX(0x999999);
    
    [hud showAnimated:YES];
    
    return hud;
}

@end
