//
//  CTFNetErrorView.m
//  ChalkTalks
//
//  Created by vision on 2020/1/6.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//


// 9add0a99a51dfe5cd7dd4f6b62e9905080b911dd

#import "CTFNetErrorView.h"

@interface CTFNetErrorView ()

@end

@implementation CTFNetErrorView


- (instancetype)initWithFrame:(CGRect)frame errorType:(ERRORTYPE)errorType whetherLittleIconModel:(BOOL)isLittleIconModel {
    
    if (isLittleIconModel) {
        if (errorType == ERROR_NET) {
            self = [super initWithFrame:frame blankType:CTFBlankType_ErrorNetwork_LitterIcon imageOffY:112];
        } else {
            self = [super initWithFrame:frame blankType:CTFBlankType_ErrorServer_LitterIcon imageOffY:112];
        }
    } else {
        if (errorType == ERROR_NET) {
            self = [super initWithFrame:frame blankType:CTFBlankType_ErrorNetwork imageOffY:112];
        } else {
            self = [super initWithFrame:frame blankType:CTFBlankType_ErrorServer imageOffY:112];
        }
    }
    if (self) {
        UIButton *refreshBtn = [[UIButton alloc] init];
        [refreshBtn setTitle:@"刷新试试" forState:UIControlStateNormal];
        [refreshBtn setTitleColor:[UIColor ctMainColor] forState:UIControlStateNormal];
        refreshBtn.titleLabel.font = [UIFont mediumFontWithSize:16];
        refreshBtn.layer.cornerRadius = 21.0;
        refreshBtn.layer.borderColor = [UIColor ctMainColor].CGColor;
        refreshBtn.layer.borderWidth = 1;
        self.refreshBtn = refreshBtn;
        [self addSubview:refreshBtn];
        [self.refreshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset((kScreen_Width-131)/2.0);
            make.top.mas_equalTo(self.tipslab.mas_bottom).offset(30);
            make.size.mas_equalTo(CGSizeMake(131, 42));
        }];
    }
    return self;
}

@end
