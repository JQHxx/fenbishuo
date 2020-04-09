//
//  CTFMineCareTopicListCell.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/19.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFMineCareTopicListCell.h"
#import "CTFNewCareEventView.h"
#import "CTFTopicAuthorView.h"
#import "CTFCommonManager.h"

@interface CTFMineCareTopicListCell ()

@property (nonatomic, strong) UILabel             *careTimeLabel;
@property (nonatomic, strong) UILabel             *titleLable;
@property (nonatomic, strong) CTFTopicAuthorView  *authorView;//前缀+头像+名字
@property (nonatomic, strong) UILabel             *replyAccouontLabel;
@property (nonatomic, strong) CTFNewCareEventView *careEventView;
@property (nonatomic, strong) UIView              *gapView;

@end

@implementation CTFMineCareTopicListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self setupViewContent];
    }
    return self;
}

- (void)fillContentWithData:(CTFQuestionsModel *)model {
    NSString *timeString = [CTDateUtils formatTimeAgoWithTimestamp:model.votedAt];;
    self.careTimeLabel.text = [NSString stringWithFormat:@"%@ 关心", timeString];
    
    if (kIsEmptyString(model.shortTitle)) {
        self.titleLable.text = model.title;
    } else {
        self.titleLable.attributedText = [CTFCommonManager setTopicTitleWithType:model.type shortTitle:model.shortTitle suffix:model.suffix];
    }
    AuthorModel *temp_authorModel = [[AuthorModel alloc] init];
    temp_authorModel.authorId = model.author.authorId;
    temp_authorModel.avatarUrl = model.author.avatarUrl;
    temp_authorModel.name = model.author.name;
    temp_authorModel.city = model.author.city;
    temp_authorModel.gender = model.author.gender;
    temp_authorModel.headline = model.author.headline;
    temp_authorModel.isFollowing = NO;//CTFQuestionsModel中的缺省值
    self.authorView.showAvatar = YES;
    [self.authorView fillDataWithType:model.type author:temp_authorModel];
    self.replyAccouontLabel.text = [NSString stringWithFormat:@"%ld个回答", model.answerCount];
    [self.careEventView fillCareEventWithModel:model indexPath:self.cardIndexPath];
}

- (void)setupViewContent {
    //
    self.careTimeLabel = [[UILabel alloc] init];
    self.careTimeLabel.font = [UIFont systemFontOfSize:14];
    self.careTimeLabel.textColor = UIColorFromHEX(0x666666);
    [self.contentView addSubview:self.careTimeLabel];
    [self.careTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(16);
        make.top.mas_equalTo(self.contentView.mas_top).offset(16);
        make.width.mas_equalTo(kScreen_Width - 32);
        make.height.mas_greaterThanOrEqualTo(22);
    }];
    
    //
    self.titleLable = [[UILabel alloc] init];
    self.titleLable.numberOfLines = 0;
    self.titleLable.font = [UIFont mediumFontWithSize:18];
    self.titleLable.textColor = UIColorFromHEX(0x333333);
    [self.contentView addSubview:self.titleLable];
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.careTimeLabel.mas_bottom).offset(6);
        make.left.mas_equalTo(self.contentView.mas_left).offset(16);
        make.width.mas_equalTo(kScreen_Width - 32);
        make.height.mas_greaterThanOrEqualTo(22);
    }];
    
    //
    self.replyAccouontLabel = [[UILabel alloc] init];
    self.replyAccouontLabel.font = [UIFont systemFontOfSize:11];
    self.replyAccouontLabel.textColor = UIColorFromHEX(0xC2C2C2);
    [self.contentView addSubview:self.replyAccouontLabel];
    [self.replyAccouontLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-16);
        make.top.mas_equalTo(self.titleLable.mas_bottom).offset(6);
        make.width.mas_greaterThanOrEqualTo(40);
        make.height.mas_greaterThanOrEqualTo(14);
    }];
    
    //
    self.authorView = [[CTFTopicAuthorView alloc] init];
    [self.contentView addSubview:self.authorView];
    [self.authorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.replyAccouontLabel.mas_centerY);
        make.left.mas_equalTo(self.contentView.mas_left).offset(0);
    }];
    
    self.careEventView = [[CTFNewCareEventView alloc] init];
    [self.contentView addSubview:self.careEventView];
    [self.careEventView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(16);
        make.top.mas_equalTo(self.replyAccouontLabel.mas_bottom).offset(12);
        make.height.mas_equalTo(34);
        make.width.mas_equalTo(220);
    }];
    
    self.gapView = [[UIView alloc] init];
    self.gapView.backgroundColor = UIColorFromHEX(0xF8F8F8);
    [self.contentView addSubview:self.gapView];
    [self.gapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.careEventView.mas_bottom).offset(16);
        make.left.mas_equalTo(self.contentView.mas_left);
        make.width.mas_equalTo(kScreen_Width);
        make.height.mas_equalTo(2);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
    
    [self setupSkeletonabelView];
}

- (void)setupSkeletonabelView {
    [self ctf_skeletonable:YES];
    [self.careTimeLabel ctf_skeletonable:YES];
    [self.titleLable ctf_skeletonable:YES];
    [self.authorView ctf_skeletonable:YES];
    [self.replyAccouontLabel ctf_skeletonable:YES];
    [self.careEventView ctf_skeletonable:YES];
}

@end
