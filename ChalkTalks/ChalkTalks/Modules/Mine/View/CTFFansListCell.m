//
//  CTFFansListCell.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/18.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFFansListCell.h"

@interface CTFFansListCell ()
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *headLineLabel;
@property (nonatomic, strong) UIButton *careBtn;
@property (nonatomic, strong) UIImageView *hotImage;//小红点

@property (nonatomic, strong) CTFFansUserModel *model;

@end

@implementation CTFFansListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self setupViewContent];
    }
    return self;
}

- (void)fillContentWithData:(CTFFansUserModel *)model {
    
    self.model = model;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:model.avatarUrl] placeholderImage:[UIImage imageNamed:@"placeholder_head_78x78"]];
    self.nameLabel.text = model.name;
    
    NSString *headLineText = model.headline.length > 0 ? model.headline : @"还没有签名...";
    self.headLineLabel.text = headLineText;
    
    if (!model.pull.isRead && model.pull.idString.length > 0) {
        [self.hotImage setHidden:NO];
    } else {
        [self.hotImage setHidden:YES];
    }
    
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

- (void)setupViewContent {
    self.headImageView = [[UIImageView alloc] init];
    self.headImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.headImageView.layer.cornerRadius = 20;
    self.headImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.headImageView];
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(20);
        make.top.mas_equalTo(self.contentView.mas_top).offset(15);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.bottom.mas_equalTo(self.contentView.bottom).offset(-15);
    }];
    
    self.hotImage = [[UIImageView alloc] init];
    self.hotImage.layer.cornerRadius = 3;
    self.hotImage.layer.masksToBounds = YES;
    self.hotImage.layer.backgroundColor = UIColorFromHEX(0xFF001F).CGColor;
    [self.contentView addSubview:self.hotImage];
    [self.hotImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(20);
        make.top.mas_equalTo(self.contentView.mas_top).offset(15);
        make.size.mas_equalTo(CGSizeMake(6, 6));
    }];
    self.hotImage.hidden = YES;
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:16];
    self.nameLabel.text = @" ";
    self.nameLabel.textColor = UIColorFromHEX(0x333333);
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headImageView.mas_right).offset(10);
        make.top.mas_equalTo(self.contentView.mas_top).offset(15);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-20);
    }];
    
    self.headLineLabel = [[UILabel alloc] init];
    self.headLineLabel.font = [UIFont systemFontOfSize:13];
    self.headLineLabel.text = @" ";
    self.headLineLabel.textColor = UIColorFromHEX(0x999999);
    [self.contentView addSubview:self.headLineLabel];
    [self.headLineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headImageView.mas_right).offset(10);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(1);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-88);
    }];
    
    self.careBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.careBtn setTitle:@"" forState:UIControlStateNormal];
    [self.careBtn addTarget:self action:@selector(careBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.careBtn.titleLabel setFont:[UIFont systemFontOfSize:11]];
    
    [self.contentView addSubview:self.careBtn];
    [self.careBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.headImageView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(56, 26));
        make.right.mas_equalTo(self.contentView.mas_right).offset(-16);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = UIColorFromHEXWithAlpha(0x999999, 0.1);
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left);
        make.width.mas_equalTo(self.contentView.mas_width);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(self.contentView.bottom).offset(-1);
    }];
}

- (void)careBtnAction:(UIButton *)btn {
    if (![self.findViewController ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded]) {
        return;
    }
    if ([btn.titleLabel.text isEqualToString:@"互相关注"] || [btn.titleLabel.text isEqualToString:@"已关注"]) {
        // TO DO : 取消关注
        if (self.deleteFollowBlock) {
            self.deleteFollowBlock(self.model.fansId, self.indexRow);
        }
    } else {
        // TO DO : 关注
        if (self.addFollowBlock) {
            self.addFollowBlock(self.model.fansId, self.indexRow);
        }
    }
}

@end
