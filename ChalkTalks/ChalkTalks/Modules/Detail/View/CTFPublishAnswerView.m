//
//  CTFPublishAnswerView.m
//  ChalkTalks
//
//  Created by vision on 2020/2/26.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFPublishAnswerView.h"
#import "NSString+Size.h"
#import "NSURL+Ext.h"

@interface CTFPublishAnswerView ()

@property (nonatomic,strong) UIView      *bgView;
@property (nonatomic,strong) UIImageView *headImgView;
@property (nonatomic,strong) UILabel     *titleLab;

@end

@implementation CTFPublishAnswerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.bgView];
        [self addSubview:self.headImgView];
        [self addSubview:self.titleLab];
    }
    return self;
}

- (void)setTitle:(NSString *)title{
    _title = title;
    self.titleLab.text = title;
    CGFloat titleWidth = [title boundingRectWithSize:CGSizeMake(kScreen_Width, 22) withTextFont:self.titleLab.font].width;
    self.headImgView.frame = CGRectMake((kScreen_Width-titleWidth-28)/2.0, 13, 22, 22);
    [self.headImgView setBorderWithCornerRadius:11 type:UIViewCornerTypeAll];
    self.titleLab.frame = CGRectMake(self.headImgView.right+8, 13, titleWidth+10, 22);
}

- (void)setHideImage:(BOOL)hideImage {
    _hideImage = hideImage;
    self.headImgView.hidden = hideImage;
    CGFloat titleWidth = [self.title boundingRectWithSize:CGSizeMake(kScreen_Width, 22) withTextFont:self.titleLab.font].width;
    self.titleLab.frame = CGRectMake((kScreen_Width - titleWidth)/2.0, 13, titleWidth, 22);
}

#pragma mark -- Getters
#pragma mark 背景
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 50)];
        _bgView.backgroundColor = [UIColor ctMainColor];
    }
    return _bgView;
}

#pragma mark 头像
- (UIImageView *)headImgView {
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] init];
        UserModel *user = [UserCache getUserInfo];
        [_headImgView sd_setImageWithURL:[NSURL safe_URLWithString:user.avatarUrl] placeholderImage:[UIImage ctUserPlaceholderImage]];
    }
    return _headImgView;
}

#pragma mark 标题
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont mediumFontWithSize:16];
        _titleLab.textColor = [UIColor whiteColor];
    }
    return _titleLab;
}

@end
