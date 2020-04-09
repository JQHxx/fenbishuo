//
//  CTFMineVoteListCell.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/19.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFMineVoteListCell.h"
#import "CTFNewCareEventView.h"
#import "CTFCommonManager.h"

@interface CTFMineVoteListCell ()

@property (nonatomic, strong) UILabel             *titleLabel;
@property (nonatomic, strong) UILabel             *createTimeLabel;
@property (nonatomic, strong) UILabel             *replyAccouontLabel;
@property (nonatomic, strong) CTFNewCareEventView *careEventView;

@end

@implementation CTFMineVoteListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self setupViewContent];
    }
    return self;
}

- (void)fillContentWithData:(CTFQuestionsModel *)model {
    if (kIsEmptyString(model.shortTitle)&&kIsEmptyString(model.suffix)) {
        self.titleLabel.text = model.title;
    } else {
       self.titleLabel.attributedText = [CTFCommonManager setTopicTitleWithType:model.type shortTitle:model.shortTitle suffix:model.suffix];
    }
    
    self.createTimeLabel.text = [CTDateUtils formatTimeAgoWithTimestamp:model.createdAt];
    
    self.replyAccouontLabel.text = [NSString stringWithFormat:@"%ld个回答",model.answerCount];
    [self.careEventView fillCareEventWithModel:model indexPath:self.cardIndexPath];
}

- (void)setupViewContent {
    //
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = [UIFont mediumFontWithSize:18];
    self.titleLabel.textColor = UIColorFromHEX(0x333333);
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(16);
        make.left.mas_equalTo(self.contentView.mas_left).offset(16);
        make.width.mas_equalTo(kScreen_Width - 32);
    }];
    
    //
    self.createTimeLabel = [[UILabel alloc] init];
    self.createTimeLabel.font = [UIFont systemFontOfSize:10];
    self.createTimeLabel.textColor = UIColorFromHEX(0x666666);
    [self.contentView addSubview:self.createTimeLabel];
    [self.createTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(16);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(10);
    }];
    
    //
    self.replyAccouontLabel = [[UILabel alloc] init];
    self.replyAccouontLabel.font = [UIFont systemFontOfSize:10];
    self.replyAccouontLabel.textColor = UIColorFromHEX(0xC2C2C2);
    [self.contentView addSubview:self.replyAccouontLabel];
    [self.replyAccouontLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-38);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(10);
    }];
    
    self.careEventView = [[CTFNewCareEventView alloc] init];
    [self.contentView addSubview:self.careEventView];
    [self.careEventView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(16);
        make.top.mas_equalTo(self.replyAccouontLabel.mas_bottom).offset(12);
        make.height.mas_equalTo(34);
        make.width.mas_equalTo(220);
    }];
    
    UIView *gapView = [[UIView alloc] init];
    gapView.backgroundColor = UIColorFromHEX(0xF8F8F8);
    [self.contentView addSubview:gapView];
    [gapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.careEventView.mas_bottom).offset(16);
        make.left.mas_equalTo(self.contentView.mas_left);
        make.right.mas_equalTo(self.contentView.mas_right);
        make.width.mas_equalTo(kScreen_Width);
        make.height.mas_equalTo(2);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
}

@end
