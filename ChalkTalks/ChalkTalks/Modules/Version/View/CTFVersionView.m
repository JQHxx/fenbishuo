//
//  CTFVersionView.m
//  ChalkTalks
//
//  Created by vision on 2020/1/1.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFVersionView.h"
#import "CTFCustomAlertView.h"
#import "UIView+Frame.h"
#import "NSString+Size.h"
#import <UMAnalytics/MobClick.h>

#define kAppstoreUrl @"https://apps.apple.com/cn/app/id1482522769"

@interface CTFVersionView ()

@property (nonatomic,strong) CTFVersionModel *myVersion;

@end

@implementation CTFVersionView

-(instancetype)initWithFrame:(CGRect)frame version:(CTFVersionModel *)versionModel{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        [self setBorderWithCornerRadius:12.0 type:UIViewCornerTypeAll];
        
        self.myVersion = versionModel;
        
        //背景
        UIImageView *headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 260, 134)];
        headImgView.image = ImageNamed(@"version_icon_background");
        [self addSubview:headImgView];
        
        //标题
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(24, 20, 110, 28)];
        titleLab.font = [UIFont mediumFontWithSize:20];
        titleLab.textColor = [UIColor whiteColor];
        titleLab.text = @"发现新版本";
        [self addSubview:titleLab];
        
        UILabel *tipsLab = [[UILabel alloc] initWithFrame:CGRectMake(titleLab.left, titleLab.bottom+5, 78, 23)];
        tipsLab.backgroundColor = [UIColor whiteColor];
        tipsLab.textAlignment = NSTextAlignmentCenter;
        tipsLab.font = [UIFont regularFontWithSize:12];
        [tipsLab setBorderWithCornerRadius:15 type:UIViewCornerTypeAll];
        tipsLab.textColor = [UIColor ctMainColor];
        tipsLab.text = [NSString stringWithFormat:@"粉笔说%@",versionModel.version];
        [self addSubview:tipsLab];
        
        //更新内容
        UILabel *versionTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(24,tipsLab.bottom+34, 60, 20)];
        versionTitleLab.font = [UIFont regularFontWithSize:14];
        versionTitleLab.textColor = [UIColor ctColor33];
        versionTitleLab.text = @"更新内容";
        [self addSubview:versionTitleLab];
        
        UILabel *contentLab = [[UILabel alloc] initWithFrame:CGRectZero];
        contentLab.font = [UIFont regularFontWithSize:14];
        contentLab.textColor = [UIColor ctColor33];
        contentLab.numberOfLines = 0;
        CGFloat contentH = [versionModel.content boundingRectWithSize:CGSizeMake(220, CGFLOAT_MAX) withTextFont:contentLab.font].height;
        contentLab.frame = CGRectMake(24, versionTitleLab.bottom+10, 220, contentH);
        contentLab.text = versionModel.content;
        [self addSubview:contentLab];
        
        //提示
        UILabel *descLab = [[UILabel alloc] initWithFrame:CGRectMake(24, contentLab.bottom+15, 150, 36)];
        descLab.font = [UIFont regularFontWithSize:11];
        descLab.textColor = [UIColor ctColorC2];
        descLab.numberOfLines = 0;
        descLab.text = [NSString stringWithFormat:@"版本大小：%.2fMB \n非WIFI网络下降消耗下载流量",[versionModel.storageSize doubleValue]];
        [self addSubview:descLab];
        
        UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [confirmBtn setTitle:@"马上升级" forState:UIControlStateNormal];
        [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        confirmBtn.titleLabel.font = [UIFont mediumFontWithSize:16];
        [confirmBtn addTarget:self action:@selector(updateVersionAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:confirmBtn];
        
        if ([versionModel.status isEqualToString:@"forceUpdate"]) {  //强制更新
            confirmBtn.frame = CGRectMake(65, descLab.bottom+20, 130, 42);
            [confirmBtn setBorderWithCornerRadius:21 type:UIViewCornerTypeAll];
            confirmBtn.backgroundColor = [UIColor bm_colorGradientChangeWithSize:CGSizeMake(130, 42) direction:IHGradientChangeDirectionLevel startColor:UIColorFromHEX(0xFFABBB) endColor:[UIColor ctMainColor]];
        }else{
            UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(16, descLab.bottom+20, 102, 42)];
            [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
            [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            cancelBtn.titleLabel.font = [UIFont mediumFontWithSize:16];
            cancelBtn.backgroundColor = [UIColor ctColorC2];
            [cancelBtn setBorderWithCornerRadius:21 type:UIViewCornerTypeAll];
            [cancelBtn addTarget:self action:@selector(cancelUpdateVersionAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:cancelBtn];
            
            confirmBtn.frame = CGRectMake(cancelBtn.right+24, descLab.bottom+20, 102, 42);
            [confirmBtn setBorderWithCornerRadius:21 type:UIViewCornerTypeAll];
            confirmBtn.backgroundColor = [UIColor bm_colorGradientChangeWithSize:CGSizeMake(102, 42) direction:IHGradientChangeDirectionLevel startColor:UIColorFromHEX(0xFFABBB) endColor:[UIColor ctMainColor]];
        }
    }
    return self;
}

#pragma mark 版本弹出框
+(void)showVersionViewWithFrame:(CGRect)frame version:(CTFVersionModel *)model{
    CTFVersionView *view = [[CTFVersionView alloc] initWithFrame:frame version:model];
    [view show];
}

#pragma mark -- Event response
#pragma mark  取消
-(void)cancelUpdateVersionAction:(UIButton *)sender{
    [self hide];
}

#pragma mark 更新
-(void)updateVersionAction:(UIButton *)sender{
    [MobClick event:@"update"];
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:kAppstoreUrl];
    [application openURL:URL options:@{} completionHandler:^(BOOL success) {
        ZLLog(@"iOS10 Open %@: %d",kAppstoreUrl,success);
    }];
}

#pragma mark -- Private methods
#pragma mark 显示
-(void)show{
    [CTFCustomAlertView sharedMask].maskNoClick = YES; //禁止点击
    [[CTFCustomAlertView sharedMask] show:self withType:CTFCustomAlertViewStyleAlert];
}

#pragma mark 隐藏
-(void)hide{
    [[CTFCustomAlertView sharedMask] dismiss];
}




@end
