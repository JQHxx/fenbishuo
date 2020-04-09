//
//  CTFSearchQuestionListCell.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/26.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFSearchQuestionListCell.h"

@interface CTFSearchQuestionListCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *careAccountLabel;
@property (nonatomic, strong) UILabel *replyAccountLabel;
@end

@implementation CTFSearchQuestionListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViewContent];
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = UIColorFromHEX(0xFAFAFA);
    }
    return self;
}

- (void)fillContentWithData:(CTFSearchQuestionModel *)model {
    
    self.titleLabel.text = model.title;
    
    self.contentLabel.text = model.summary;
    
    self.careAccountLabel.text = [NSString stringWithFormat:@"%ld关心  ·", model.voteupCount];
    
    self.replyAccountLabel.text = [NSString stringWithFormat:@"  %ld回复", model.answerCount];
    
    if (model.summary.length == 0) {
        //
        [self.careAccountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView.mas_left).offset(16);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(10);
        }];
        //
        [self.replyAccountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.careAccountLabel.mas_right).offset(0);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(10);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-10);
        }];
    } else {
        //
        [self.careAccountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView.mas_left).offset(16);
            make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(7);
        }];
        //
        [self.replyAccountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.careAccountLabel.mas_right).offset(0);
            make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(7);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-10);
        }];
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
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.textColor = UIColorFromHEX(0x333333);
    self.titleLabel.text = @"";
    self.titleLabel.numberOfLines = 0;
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(16);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-16);
        make.top.mas_equalTo(lineView.mas_bottom).offset(14);
    }];
    
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.font = [UIFont systemFontOfSize:14];
    self.contentLabel.textColor = UIColorFromHEX(0x666666);
    self.contentLabel.text = @"";
    self.contentLabel.numberOfLines = 2;
    [self.contentView addSubview:self.contentLabel];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(16);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-16);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(6);
    }];
    
    self.careAccountLabel = [[UILabel alloc] init];
    self.careAccountLabel.font = [UIFont systemFontOfSize:12];
    self.careAccountLabel.textColor = UIColorFromHEX(0x999999);
    self.careAccountLabel.text = @"";
    self.careAccountLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.careAccountLabel];
    [self.careAccountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(16);
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(7);
    }];
    
    self.replyAccountLabel = [[UILabel alloc] init];
    self.replyAccountLabel.font = [UIFont systemFontOfSize:12];
    self.replyAccountLabel.textColor = UIColorFromHEX(0x999999);
    self.replyAccountLabel.text = @"";
    self.replyAccountLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.replyAccountLabel];
    [self.replyAccountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.careAccountLabel.mas_right).offset(0);
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(7);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-10);
    }];
}

@end
