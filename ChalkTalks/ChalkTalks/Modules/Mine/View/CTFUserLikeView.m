//
//  CTFUserLikeView.m
//  ChalkTalks
//
//  Created by vision on 2019/12/31.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFUserLikeView.h"
#import "CTFCustomAlertView.h"
#import "UIView+Frame.h"
#import "CTFCommonManager.h"

@interface CTFUserLikeView ()

@property (nonatomic, copy ) ViewDismissBlock dismissBlock;

@end

@implementation CTFUserLikeView

- (instancetype)initWithFrame:(CGRect)frame isMine:(BOOL)isMine name:(NSString *)name like:(NSInteger)likeCount dismiss:(ViewDismissBlock)dismiss{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setBorderWithCornerRadius:8 type:UIViewCornerTypeAll];
        
        self.dismissBlock = dismiss;
        
        UIImageView *tipImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 247, 152)];
        if (likeCount > 0) {
            tipImageView.image = [UIImage imageNamed:@"view_havaAgree"];
        }else {
            tipImageView.image = [UIImage imageNamed:@"view_noAgree"];
        }
        [self addSubview:tipImageView];

        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, tipImageView.bottom, 247, 41)];
        tipLabel.numberOfLines = 0;
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.font = [UIFont systemFontOfSize:12];
        tipLabel.textColor = UIColorFromHEX(0x333333);
        if (likeCount > 0) {
            NSString *likeStr = [CTFCommonManager numberTransforByCount:likeCount];
            tipLabel.text = [NSString stringWithFormat:@"有%@个人认为\"%@\"【靠谱】", likeStr,name];
        }else {
            tipLabel.text = [NSString stringWithFormat:@"%@的回答还未获得\"靠谱\"数哦~",isMine?@"你":@"他"];
        }
        [self addSubview:tipLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, tipLabel.bottom, 247, 1)];
        lineView.backgroundColor = UIColorFromHEX(0xEEEEEE);
        [self addSubview:lineView];
        
        UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, lineView.bottom, 247, 46)];
        closeBtn.backgroundColor = UIColorFromHEX(0xFFFFFF);
        [closeBtn setTitle:@"确认" forState:UIControlStateNormal];
        closeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [closeBtn setTitleColor:UIColorFromHEX(0x333333) forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(closeBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeBtn];   
    }
    return self;
}

#pragma mark  --public methods
+ (void)showUserLikeViewWithFrame:(CGRect)frame isMine:(BOOL)isMine name:(NSString *)name like:(NSInteger)likeCount dismiss:(ViewDismissBlock)dismiss{
    CTFUserLikeView *view = [[CTFUserLikeView alloc] initWithFrame:frame isMine:isMine name:name like:likeCount dismiss:dismiss];
    [view show];
}

#pragma mark -- Private methods
#pragma mark 显示
- (void)show{
    [[CTFCustomAlertView sharedMask] show:self withType:CTFCustomAlertViewStyleAlert animationFinish:^{
        
    } dismissHandle:self.dismissBlock];
}

#pragma mark  隐藏
- (void)closeBtnAction{
    self.dismissBlock();
    [[CTFCustomAlertView sharedMask] dismiss];
}


@end
