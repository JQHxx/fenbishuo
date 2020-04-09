//
//  CTFMoreHandleView.m
//  ChalkTalks
//
//  Created by vision on 2020/2/22.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFMoreHandleView.h"
#import "CTFCustomAlertView.h"
#import "UIImage+Size.h"

@interface CTFMoreHandleView ()

@property (nonatomic, copy ) HandleBlock handle;

@end

@implementation CTFMoreHandleView

- (instancetype)initWithFrame:(CGRect)frame
                     isAuthor:(BOOL )isAuthor
                      isReply:(BOOL)isReply
                       handle:(HandleBlock)handle{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromHEX(0xF4F4F4);
        [self setBorderWithCornerRadius:8 type:UIViewCornerTypeTop];
        self.handle = handle;
    
        NSString *btnTitle = nil;
        if (isAuthor) {
            btnTitle = [NSString stringWithFormat:@"删除%@",isReply?@"回复":@"评论"];
        } else {
            btnTitle = [NSString stringWithFormat:@"举报%@",isReply?@"回复":@"评论"];
        }
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width-60)/2.0, 20, 60, 60)];
        [btn setTitle:btnTitle forState:UIControlStateNormal];
        [btn setImage:[UIImage drawImageWithName:isAuthor?@"share_icon_delete":@"share_icon_report" size:CGSizeMake(60, 60)] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor ctColor66] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont regularFontWithSize:13];
        CGFloat imageWith = btn.imageView.intrinsicContentSize.width;
        CGFloat imageHeight = btn.imageView.intrinsicContentSize.height;
        CGFloat labelWidth = btn.titleLabel.intrinsicContentSize.width;
        CGFloat labelHeight = btn.titleLabel.intrinsicContentSize.height;
        btn.imageEdgeInsets = UIEdgeInsetsMake(-labelHeight-5, -(btn.width-imageWith)/2.0, 0, -labelWidth);
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight-10, 0);
        [btn addTarget:self action:@selector(moreHandleAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, btn.bottom+20, kScreen_Width, 1)];
        lineView.backgroundColor = [UIColor ctColorEE];
        [self addSubview:lineView];
        
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width-100)/2.0,lineView.bottom+5, 100, 36)];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor ctColor33] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont mediumFontWithSize:16];
        [cancelBtn addTarget:self action:@selector(cancelHandleAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelBtn];
        
    }
    return self;
}

+ (void)showMoreHandleViewWithFrame:(CGRect)frame
                           isAuthor:(BOOL )isAuthor
                            isReply:(BOOL)isReply
                             handle:(HandleBlock)handle{
    CTFMoreHandleView *view = [[CTFMoreHandleView alloc] initWithFrame:frame isAuthor:isAuthor isReply:isReply handle:handle];
    [view handleViewShow];
}

#pragma mark 显示弹出框
- (void)handleViewShow {
    [[CTFCustomAlertView sharedMask] show:self withType:CTFCustomAlertViewStyleActionSheetDown];
}

#pragma mark 隐藏
- (void)handleViewDismiss {
    [[CTFCustomAlertView sharedMask] dismiss];
}

#pragma mark -- Event response
#pragma mark 删除或举报评论
- (void)moreHandleAction:(UIButton *)sender {
    [self handleViewDismiss];
    if (self.handle) {
        self.handle();
    }
}

#pragma mark 取消
- (void)cancelHandleAction:(UIButton *)sender {
    [self handleViewDismiss];
}

@end
