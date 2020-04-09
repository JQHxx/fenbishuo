//
//  CTFSearchHistoryCell.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/28.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFSearchHistoryCell.h"

@interface CTFSearchHistoryCell ()
@property (nonatomic, strong) UILabel *historyLabel;
@property (nonatomic, strong) UIButton *deleteBtn;
@end

@implementation CTFSearchHistoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViewContent];
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = UIColorFromHEX(0xFAFAFA);
    }
    return self;
}

- (void)fillContentWithData:(NSString *)historyText {
    self.historyLabel.text = historyText;
}

- (void)setupViewContent {
    
    self.historyLabel = [[UILabel alloc] init];
    self.historyLabel.text = @"";
    self.historyLabel.font = [UIFont systemFontOfSize:16];
    self.historyLabel.textColor = UIColorFromHEX(0x333333);
    [self.contentView addSubview:self.historyLabel];
    [self.historyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(14);
        make.top.mas_equalTo(self.contentView.mas_top).offset(15);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-15);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-30);
    }];
    
    self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.deleteBtn setImage:[UIImage imageNamed:@"icon_delete_history"] forState:UIControlStateNormal];
    [self.deleteBtn addTarget:self action:@selector(deleteBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.deleteBtn];
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(0);
        make.width.mas_equalTo(46);
        make.height.mas_equalTo(self.contentView.mas_height);
        make.centerY.mas_equalTo(self.historyLabel.mas_centerY);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = UIColorFromHEX(0xF8F8F8);
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(kScreen_Width, 1));
        make.left.mas_equalTo(self.contentView.mas_left);
    }];
}

//删除当条历史数据
- (void)deleteBtnAction {
    if (self.deleteHistory) {
        self.deleteHistory();
    }
}

@end
