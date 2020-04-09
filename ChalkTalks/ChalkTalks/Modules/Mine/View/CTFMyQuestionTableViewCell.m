//
//  CTFMyQuestionTableViewCell.m
//  ChalkTalks
//
//  Created by vision on 2019/12/27.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFMyQuestionTableViewCell.h"
#import "CTFNewCareEventView.h"
#import "CTFTopicAuthorView.h"
#import "NSString+Size.h"
#import "CTFCommonManager.h"

@interface CTFMyQuestionTableViewCell ()

@property (nonatomic,strong) UILabel             *titleLab;
@property (nonatomic,strong) UILabel             *contentLab;
@property (nonatomic,strong) CTFTopicAuthorView  *authorView;
@property (nonatomic,strong) UILabel             *replyAccouontLabel;
@property (nonatomic,strong) CTFNewCareEventView *careEventView;
@property (nonatomic,strong) UIView              *lineView;

@end

@implementation CTFMyQuestionTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupView];
    }
    return self;
}

#pragma mark 填充数据
-(void)setActivityModel:(CTFActivityModel *)activityModel{
    _activityModel = activityModel;
    
    CTFQuestionsModel *model = activityModel.question;
    NSString *timeString = [CTDateUtils formatTimeAgoWithTimestamp:model.createdAt];
    self.titleLab.text = [NSString stringWithFormat:@"%@ %@",timeString,activityModel.actionText];
    
    if (kIsEmptyString(model.shortTitle)&&kIsEmptyString(model.suffix)) {
        self.contentLab.text = model.title;
    } else {
       self.contentLab.attributedText = [CTFCommonManager setTopicTitleWithType:model.type shortTitle:model.shortTitle suffix:model.suffix];
    }
    AuthorModel *author = [[AuthorModel alloc] init];
    author.authorId = model.author.authorId;
    author.avatarUrl = model.author.avatarUrl;
    author.name = model.author.name;
    [self.authorView fillDataWithType:model.type author:author];
    self.replyAccouontLabel.text = [NSString stringWithFormat:@"%ld个回答", model.answerCount];
    [self.careEventView fillCareEventWithModel:model indexPath:self.cardIndexPath];
}

#pragma mark 计算高度
+(CGFloat)getMyQuestionCellHeightWithMode:(CTFActivityModel *)model{
    CGFloat titleHeight = [model.question.title boundingRectWithSize:CGSizeMake(kScreen_Width-32, CGFLOAT_MAX) withTextFont:[UIFont mediumFontWithSize:18]].height;
    return titleHeight+150;
}

#pragma mark -- Private methods
#pragma mark 初始化界面
-(void)setupView{
    [self.contentView addSubview:self.titleLab];
    [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(16);
        make.left.mas_equalTo(self.contentView.mas_left).offset(16);
        make.width.mas_equalTo(kScreen_Width-32);
        make.height.mas_equalTo(20);
    }];
    
    [self.contentView addSubview:self.contentLab];
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLab.mas_bottom).offset(6);
        make.left.mas_equalTo(self.contentView.mas_left).offset(16);
        make.width.mas_equalTo(kScreen_Width-32);
    }];
    
    [self.contentView addSubview:self.authorView];
    [self.authorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLab.mas_bottom).offset(8);
        make.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(30);
    }];
    
    [self.contentView addSubview:self.replyAccouontLabel];
    [self.replyAccouontLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-16);
        make.centerY.mas_equalTo(self.authorView.mas_centerY);
    }];
    
    [self.contentView addSubview:self.careEventView];
    [self.careEventView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.authorView.mas_bottom).offset(8);
        make.left.mas_equalTo(self.contentView).offset(16);
        make.height.mas_equalTo(54);
        make.width.mas_equalTo(220);
    }];
    
    [self.contentView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_bottom).offset(-7);
        make.width.mas_equalTo(self.contentView.mas_width);
        make.height.mas_equalTo(2);
    }];
}

#pragma mark -- getters
#pragma mark 标题
-(UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont regularFontWithSize:14];
        _titleLab.textColor = [UIColor ctColor66];
    }
    return _titleLab;
}

#pragma mark 话题标题
-(UILabel *)contentLab{
    if (!_contentLab) {
        _contentLab = [[UILabel alloc] init];
        _contentLab.numberOfLines = 0;
        _contentLab.font = [UIFont mediumFontWithSize:18];
        _contentLab.textColor = UIColorFromHEX(0x333333);
    }
    return _contentLab;
}

#pragma mark 发布者
-(CTFTopicAuthorView *)authorView{
    if (!_authorView) {
        _authorView = [[CTFTopicAuthorView alloc] init];
        _authorView.showAvatar = YES;
    }
    return _authorView;
}

#pragma mark 回答数
-(UILabel *)replyAccouontLabel{
    if (!_replyAccouontLabel) {
        _replyAccouontLabel = [[UILabel alloc] init];
        _replyAccouontLabel.font = [UIFont regularFontWithSize:11];
        _replyAccouontLabel.textColor = UIColorFromHEX(0xC2C2C2);
        _replyAccouontLabel.textAlignment = NSTextAlignmentRight;
    }
    return _replyAccouontLabel;
}

#pragma mark 关心、踩事件
-(CTFNewCareEventView *)careEventView{
    if (!_careEventView) {
        _careEventView = [[CTFNewCareEventView alloc] init];
    }
    return _careEventView;
}

#pragma mark  线
-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor ctColorEE];
    }
    return _lineView;
}

@end
