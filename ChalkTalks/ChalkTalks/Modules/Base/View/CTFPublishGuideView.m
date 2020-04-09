//
//  CTFPublishGuideView.m
//  ChalkTalks
//
//  Created by vision on 2020/2/10.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFPublishGuideView.h"

@implementation CTFPublishGuideView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *maskView = [[UIView alloc] initWithFrame:self.bounds];
        maskView.backgroundColor = UIColorFromHEXWithAlpha(0x000000, 0.8);
        [self addSubview:maskView];
        
        UIButton  *publishBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreen_Width-67)/2.0+5, kScreen_Height-kTabBar_Height-10, 67, 50)];
        [publishBtn setImage:ImageNamed(@"tabbar_guide_publish") forState:UIControlStateNormal];
        [publishBtn addTarget:self action:@selector(publishTopicAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:publishBtn];

        UIImageView *publishGuideImgView = [[UIImageView alloc] initWithFrame:CGRectMake(publishBtn.right-16, kScreen_Height-137-kTabBar_Height+10, 137, 137)];
        publishGuideImgView.image = ImageNamed(@"tabbar_guide_tips");
        [self addSubview:publishGuideImgView];
        
        UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(publishGuideImgView.right-20, publishGuideImgView.top-10, 30, 30)];
        [closeBtn setImage:ImageNamed(@"tabbar_guide_close") forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeBtn];
    }
    return self;
}

#pragma mark -- Event response
#pragma mark 发布
- (void)publishTopicAction:(UIButton *)sender{
    self.publishBlock();
}

#pragma mark 关闭
- (void)closeAction:(UIButton *)sender{
    self.closeBlock();
}

@end
