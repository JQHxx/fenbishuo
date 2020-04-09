//
//  CTFSearchAnswerListCell.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/26.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFSearchAnswerListCell.h"

@interface CTFSearchAnswerListCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *autherLable;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *careAccountLabel;
@property (nonatomic, strong) UILabel *replyAccountLabel;
@end

@implementation CTFSearchAnswerListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViewContent];
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = UIColorFromHEX(0xFAFAFA);
    }
    return self;
}

- (void)fillContentWithData:(CTFSearchAnswerModel *)model {
    
    self.titleLabel.text = model.question.title;
    
    self.autherLable.text = [NSString stringWithFormat:@"%@回答了：", model.author.name];
    
    // 设置行间距
    NSMutableAttributedString *contentAttribut = [[NSMutableAttributedString alloc] initWithString:model.summary];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:4.f];
    [contentAttribut addAttribute:NSParagraphStyleAttributeName
                          value:paragraphStyle
                          range:NSMakeRange(0, [contentAttribut length])];
    self.contentLabel.attributedText = contentAttribut;
    self.contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    self.careAccountLabel.text = [NSString stringWithFormat:@"%ld靠谱  ·", model.voteupCount];
    
    self.replyAccountLabel.text = [NSString stringWithFormat:@"  %ld评论", model.commentCount];
    
    if (model.summary.length == 0) {
        //
        [self.careAccountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView.mas_left).offset(16);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(13);
        }];
        //
        [self.replyAccountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.careAccountLabel.mas_right);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(13);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-13);
        }];
    } else {
        [self.careAccountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView.mas_left).offset(16);
            make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(13);
        }];
        //
        [self.replyAccountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.careAccountLabel.mas_right);
            make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(13);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-13);
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
    self.titleLabel.numberOfLines = 1;
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(16);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-16);
        make.top.mas_equalTo(lineView.mas_bottom).offset(16);
    }];
    
    self.autherLable = [[UILabel alloc] init];
    self.autherLable.font = [UIFont systemFontOfSize:14];
    self.autherLable.textColor = UIColorFromHEX(0x333333);
    self.autherLable.text = @"";
    self.autherLable.numberOfLines = 1;
    [self.contentView addSubview:self.autherLable];
    [self.autherLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(16);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-16);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(10);
    }];
    
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.font = [UIFont systemFontOfSize:14];
    self.contentLabel.textColor = UIColorFromHEX(0x666666);
    self.contentLabel.text = @"";
    self.contentLabel.numberOfLines = 3;
    [self.contentView addSubview:self.contentLabel];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(16);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-16);
        make.top.mas_equalTo(self.autherLable.mas_bottom).offset(2);
    }];
    
    self.careAccountLabel = [[UILabel alloc] init];
    self.careAccountLabel.font = [UIFont systemFontOfSize:11];
    self.careAccountLabel.textColor = UIColorFromHEX(0xc2c2c2);
    self.careAccountLabel.text = @"";
    self.careAccountLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.careAccountLabel];
    [self.careAccountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(16);
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(13);
    }];
    
    self.replyAccountLabel = [[UILabel alloc] init];
    self.replyAccountLabel.font = [UIFont systemFontOfSize:11];
    self.replyAccountLabel.textColor = UIColorFromHEX(0xc2c2c2);
    self.replyAccountLabel.text = @"";
    self.replyAccountLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.replyAccountLabel];
    [self.replyAccountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.careAccountLabel.mas_right);
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(13);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-13);
    }];
}

@end
