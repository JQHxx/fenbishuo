//
//  CTFSearchUserListCell.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/26.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFSearchUserListCell.h"

@interface CTFSearchUserListCell ()
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *headLineLabel;
@property (nonatomic, strong) UIButton *careBtn;

@property (nonatomic, strong) CTFSearchUserModel *model;

@end

@implementation CTFSearchUserListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViewContent];
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = UIColorFromHEX(0xFAFAFA);
    }
    return self;
}

- (void)fillContentWithData:(CTFSearchUserModel *)model {
    
    self.model = model;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:model.avatarUrl] placeholderImage:[UIImage imageNamed:@"placeholder_head_78x78"]];
    self.nameLabel.text = model.name;

    NSString *headLineText = model.headline.length > 0 ? model.headline : @"还没有签名...";
    self.headLineLabel.text = headLineText;
    
    if (model.userId == [UserCache getUserInfo].userId) {
        /* 2020.3.28 2.1.9版本
         更改为：搜索用户结果如果是自己，也要显示“+ 关注”按钮。
         理由是：为了看起来比较整齐对称。
         变更申请人：丽君
         */
        [self.careBtn setHidden:NO];
        [self.careBtn setTitle:@"+关注" forState:UIControlStateNormal];
        [self.careBtn setTitleColor:UIColorFromHEX(0x333333) forState:UIControlStateNormal];
        [self.careBtn setTitleColor:UIColorFromHEXWithAlpha(0x666666, 0.5) forState:UIControlStateHighlighted];
        [self.careBtn setBackgroundImage:[UIImage imageNamed:@"bg_care_normal"] forState:UIControlStateNormal];
        [self.careBtn setBackgroundImage:[UIImage imageNamed:@"bg_care_highlighted"] forState:UIControlStateHighlighted];
        self.careBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
        self.careBtn.layer.cornerRadius = 0;
        self.careBtn.layer.masksToBounds = YES;
    } else {
        [self.careBtn setHidden:NO];
        if (model.isFollowing && model.isMyFollower) {
            [self.careBtn setTitle:@"互相关注" forState:UIControlStateNormal];
            [self.careBtn setTitleColor:UIColorFromHEX(0x999999) forState:UIControlStateNormal];
            [self.careBtn setTitleColor:UIColorFromHEX(0x999999) forState:UIControlStateHighlighted];
            [self.careBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            [self.careBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
            self.careBtn.layer.backgroundColor = UIColorFromHEX(0xEEEEEE).CGColor;
            self.careBtn.layer.cornerRadius = 13;
            self.careBtn.layer.masksToBounds = YES;
        }
        if (model.isFollowing && !model.isMyFollower) {
            [self.careBtn setTitle:@"已关注" forState:UIControlStateNormal];
            [self.careBtn setTitleColor:UIColorFromHEX(0x999999) forState:UIControlStateNormal];
            [self.careBtn setTitleColor:UIColorFromHEX(0x999999) forState:UIControlStateHighlighted];
            [self.careBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            [self.careBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
            self.careBtn.layer.backgroundColor = UIColorFromHEX(0xEEEEEE).CGColor;
            self.careBtn.layer.cornerRadius = 13;
            self.careBtn.layer.masksToBounds = YES;
        }
        if (!model.isFollowing) {
            [self.careBtn setTitle:@"+关注" forState:UIControlStateNormal];
            [self.careBtn setTitleColor:UIColorFromHEX(0x333333) forState:UIControlStateNormal];
            [self.careBtn setTitleColor:UIColorFromHEXWithAlpha(0x666666, 0.5) forState:UIControlStateHighlighted];
            [self.careBtn setBackgroundImage:[UIImage imageNamed:@"bg_care_normal"] forState:UIControlStateNormal];
            [self.careBtn setBackgroundImage:[UIImage imageNamed:@"bg_care_highlighted"] forState:UIControlStateHighlighted];
            self.careBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            self.careBtn.layer.cornerRadius = 0;
            self.careBtn.layer.masksToBounds = YES;
        }
    }
}

- (void)setupViewContent {
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = UIColorFromHEX(0xF8F8F8);
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(0);
        make.right.mas_equalTo(self.contentView.mas_right).offset(0);
        make.top.mas_equalTo(self.contentView.mas_top).offset(0);
        make.height.mas_equalTo(1);
    }];
    
    self.headImageView = [[UIImageView alloc] init];
    self.headImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.headImageView.image = [UIImage imageNamed:@"placeholder_head_78x78"];
    self.headImageView.layer.cornerRadius = 20;
    self.headImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.headImageView];
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(16);
        make.top.mas_equalTo(lineView.mas_bottom).offset(16);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-14);
    }];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:14];
    self.nameLabel.text = @"";
    self.nameLabel.textColor = UIColorFromHEX(0x333333);
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headImageView.mas_right).offset(8);
        make.bottom.mas_equalTo(self.headImageView.mas_centerY).offset(-2);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-88);
    }];
    
    self.headLineLabel = [[UILabel alloc] init];
    self.headLineLabel.font = [UIFont systemFontOfSize:12];
    self.headLineLabel.text = @"";
    self.headLineLabel.textColor = UIColorFromHEX(0xc2c2c2);
    self.headLineLabel.numberOfLines = 1;
    [self.contentView addSubview:self.headLineLabel];
    [self.headLineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headImageView.mas_right).offset(8);
        make.top.mas_equalTo(self.headImageView.mas_centerY).offset(2);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-88);
    }];
    
    self.careBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.careBtn setTitle:@"" forState:UIControlStateNormal];
    [self.careBtn addTarget:self action:@selector(careBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.careBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.contentView addSubview:self.careBtn];
    [self.careBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.headImageView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(56, 26));
        make.right.mas_equalTo(self.contentView.mas_right).offset(-16);
    }];
}

- (void)careBtnAction:(UIButton *)btn {
    
    if (![self.findViewController ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded]) {
        return;
    }
    
    if ([btn.titleLabel.text isEqualToString:@"互相关注"] || [btn.titleLabel.text isEqualToString:@"已关注"]) {
        // TO DO : 取消关注
        if (self.deleteFollowBlock) {
            self.deleteFollowBlock(self.model.userId, self.indexRow);
        }
    } else {
        // TO DO : 关注
        if (self.addFollowBlock) {
            self.addFollowBlock(self.model.userId, self.indexRow);
        }
    }
}

@end
