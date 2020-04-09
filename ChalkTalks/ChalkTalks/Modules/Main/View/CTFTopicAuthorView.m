//
//  CTFTopicAuthorView.m
//  ChalkTalks
//
//  Created by vision on 2020/2/27.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFTopicAuthorView.h"

@interface CTFTopicAuthorView ()

@property (nonatomic,strong) UIImageView         *typeImgView;
@property (nonatomic,strong) UILabel             *byLab;
@property (nonatomic,strong) UIImageView         *headImgView;
@property (nonatomic,strong) UILabel             *nameLab;
@property (nonatomic,strong) AuthorModel         *author;

@end

@implementation CTFTopicAuthorView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

#pragma mark 填充数据
- (void)fillDataWithType:(NSString *)type author:(AuthorModel *)author {
    self.author = author;
    self.typeImgView.image = [type isEqualToString:@"demand"]?ImageNamed(@"home_topic_demand"):ImageNamed(@"home_topic_recommend");
    [self.headImgView sd_setImageWithURL:[NSURL URLWithString:author.avatarUrl] placeholderImage:ImageNamed(@"placeholder_head_78x78")];
    self.nameLab.text = author.name;
}

#pragma mark -- Private methods
#pragma mark 初始化
- (void)setupUI{
    [self addSubview:self.typeImgView];
    [self.typeImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMarginLeft);
        make.size.mas_equalTo(CGSizeMake(54, 18));
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self addSubview:self.byLab];
    [self.byLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.typeImgView.mas_right);
        make.size.mas_equalTo(CGSizeMake(20, 18));
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self addSubview:self.headImgView];
    [self.headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.byLab.mas_right);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeZero);
    }];
    
    [self addSubview:self.nameLab];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headImgView.mas_right);
        make.centerY.mas_equalTo(self.mas_centerY).offset(1);
    }];
}

#pragma mark -- Setters
- (void)setShowAvatar:(BOOL)showAvatar {
    _showAvatar = showAvatar;
    if (showAvatar) {
        [self.headImgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(14, 14));
        }];
        [self.nameLab mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.headImgView.mas_right).offset(2);
        }];
    }
}

#pragma mark -- Getters
#pragma mark 类型
- (UIImageView *)typeImgView {
    if (!_typeImgView) {
        _typeImgView = [[UIImageView alloc] init];
    }
    return _typeImgView;
}

#pragma mark by
- (UILabel *)byLab {
    if (!_byLab) {
        _byLab = [[UILabel alloc] init];
        _byLab.font = [UIFont regularFontWithSize:11];
        _byLab.textColor = [UIColor ctColor99];
        _byLab.textAlignment = NSTextAlignmentCenter;
        _byLab.text = @"by";
    }
    return _byLab;
}

#pragma mark 头像
- (UIImageView *)headImgView {
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] init];
        _headImgView.layer.cornerRadius = 7;
        _headImgView.clipsToBounds = YES;
    }
    return _headImgView;
}

#pragma mark 发布者
- (UILabel *)nameLab {
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        _nameLab.font = [UIFont regularFontWithSize:11];
        _nameLab.textColor = [UIColor ctColor99];
    }
    return _nameLab;
}

@end
