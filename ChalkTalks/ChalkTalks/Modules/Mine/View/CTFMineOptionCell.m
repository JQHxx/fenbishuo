//
//  CTFMineOptionCell.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/3/10.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFMineOptionCell.h"

@interface CTFMineOptionCell ()

@property (nonatomic, strong) UIImageView *titleImage;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIImageView *tipIamge;

@end

@implementation CTFMineOptionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self setupViewContent];
    }
    return self;
}

- (void)fillDataWithTitleImageName:(NSString *)titleImage
                         titleName:(NSString *)titleName
                           message:(NSString *)message {
    self.titleImage.image = [UIImage imageNamed:titleImage];
    self.titleLabel.text = titleName;
    self.messageLabel.text = message;
}

- (void)setupViewContent {
    
    self.titleImage = [[UIImageView alloc] init];
    [self.contentView addSubview:self.titleImage];
    [self.titleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(12);
        make.left.mas_equalTo(self.contentView.mas_left).offset(20);
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
    }];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.textColor = UIColorFromHEX(0x666666);
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleImage.mas_right).offset(20);
        make.centerY.mas_equalTo(self.titleImage.mas_centerY);
    }];
    
    self.tipIamge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_back_turnRight_10_14"]];
    [self.contentView addSubview:self.tipIamge];
    [self.tipIamge mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(10, 14));
    }];
    
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.font = [UIFont systemFontOfSize:12];
    self.messageLabel.textColor = UIColorFromHEX(0x333333);
    [self.contentView addSubview:self.messageLabel];
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.tipIamge.mas_left).offset(-20);
        make.centerY.mas_equalTo(self.titleImage.mas_centerY);
    }];
}

@end
