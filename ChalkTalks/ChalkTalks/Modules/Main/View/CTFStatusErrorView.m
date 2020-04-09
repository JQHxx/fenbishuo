//
//  CTFStatusErrorView.m
//  ChalkTalks
//
//  Created by vision on 2020/3/30.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFStatusErrorView.h"
#import "NSURL+Ext.h"

@interface CTFStatusErrorView ();

@property (nonatomic,strong) UIImageView         *coverImageView;
@property (nonatomic,strong) UIView              *maskView;
@property (nonatomic,strong) UIVisualEffectView  *effectView;
@property (nonatomic,strong) UIImageView         *iconImageView;
@property (nonatomic,strong) UILabel             *tipsLabel;

@end

@implementation CTFStatusErrorView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

#pragma mark -- Public methods
#pragma mark 填充数据
- (void)fillErrorViewWithCoverImage:(NSString *)coverUrl status:(NSString *)status {
    [self.coverImageView sd_setImageWithURL:[NSURL safe_URLWithString:coverUrl] placeholderImage:[UIImage ctRoundRectImageWithFillColor:[UIColor ctColorEE] cornerRadius:kCornerRadius]];
    
    if([status isEqualToString:@"reviewing"] ){
        self.iconImageView.image = ImageNamed(@"video_content_reviewing");
        self.tipsLabel.text = @"审核中";
    } else if([status isEqualToString:@"failed"]){
        self.iconImageView.image = ImageNamed(@"video_decode_fail");
        self.tipsLabel.text = @"转码失败，文件损坏";
    } else {
        self.iconImageView.image = ImageNamed(@"video_decoding");
        self.tipsLabel.text = @"转码中，还需要等待几分钟哦~…";
    }
}

#pragma mark -- Private methods
#pragma mark 界面初始化
- (void)setupUI {
    [self addSubview:self.coverImageView];
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self addSubview:self.maskView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self addSubview:self.effectView];
    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY).offset(-15);
        make.size.mas_equalTo(CGSizeMake(28, 26));
    }];
    
    [self addSubview:self.tipsLabel];
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.centerX);
        make.top.mas_equalTo(self.iconImageView.mas_bottom).offset(10);
    }];
}

#pragma mark -- Getters
#pragma mark 背景
- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.backgroundColor = [UIColor ctColorEE];
        _coverImageView.layer.cornerRadius = kCornerRadius;
        _coverImageView.clipsToBounds = YES;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _coverImageView;
}

#pragma mark 蒙层
- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.layer.cornerRadius = kCornerRadius;
        _maskView.clipsToBounds = YES;
        _maskView.backgroundColor = UIColorFromHEXWithAlpha(0x444444, 0.5);
    }
    return _maskView;
}

- (UIVisualEffectView *)effectView {
    if (!_effectView) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
        _effectView.layer.cornerRadius = kCornerRadius;
        _effectView.clipsToBounds = YES;
    }
    return _effectView;
}

#pragma mark icon
- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
    }
    return _iconImageView;
}

#pragma mark 提示
- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.font = [UIFont regularFontWithSize:13.0f];
        _tipsLabel.textColor = [UIColor whiteColor];
    }
    return _tipsLabel;
}

@end
