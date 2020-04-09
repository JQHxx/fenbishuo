//
//  CTFCommentBottomView.m
//  ChalkTalks
//
//  Created by vision on 2019/12/24.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFCommentBottomView.h"
#import "UIView+FrameExpand.h"

@interface CTFCommentBottomView ()

@property (nonatomic, strong) UILabel  *tipsLabel;
@property (nonatomic, strong) UIButton *submitBtn;

@end

@implementation CTFCommentBottomView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addTopLineWithStartX:0 withEnd:YES];
        
        UIButton *btn = [[UIButton alloc] init];
        [btn setTitle:@"发布" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor ctMainColor] forState:UIControlStateNormal];
        [btn setTitleColor:UIColorFromHEXWithAlpha(0xFF6885, 0.6f) forState:UIControlStateDisabled];
        btn.titleLabel.font = [UIFont mediumFontWithSize:16];
        [btn addTarget:self action:@selector(submitCommentAction) forControlEvents:UIControlEventTouchUpInside];
        btn.enabled = NO;
        [self addSubview:btn];
        self.submitBtn = btn;
        [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-16);
            make.top.mas_equalTo(14);
            make.size.mas_equalTo(CGSizeMake(32, 22));
        }];
        
        UILabel *tipsLabel = [[UILabel alloc] init];
        tipsLabel.font = [UIFont regularFontWithSize:16];
        tipsLabel.textColor = [UIColor ctColorBB];
        tipsLabel.text = @"友善的评论是交流的起点";
        tipsLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [tipsLabel addTapPressed:@selector(showCommentInputAction) target:self];
        [self addSubview:tipsLabel];
        self.tipsLabel = tipsLabel;
        [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(16);
            make.right.mas_equalTo(self.submitBtn.mas_left).offset(-10);
            make.top.mas_equalTo(self.submitBtn.mas_top);
        }];
    }
    return self;
}

#pragma mark -- Event response
#pragma mark 发布
- (void)submitCommentAction {
    self.handleBlock(1);
}

#pragma mark 显示输入框
- (void)showCommentInputAction {
    self.handleBlock(0);
}

#pragma mark -- Setters
- (void)setContent:(NSString *)content{
    _content = content;
    if (kIsEmptyString(content)) {
        self.tipsLabel.textColor = [UIColor ctColorBB];
        self.tipsLabel.text = @"友善的评论是交流的起点";
        self.submitBtn.enabled = NO;
    } else {
        self.tipsLabel.textColor = [UIColor ctColor33];
        self.tipsLabel.text = content;
        self.submitBtn.enabled = content.length < 201;
    }
}

@end
