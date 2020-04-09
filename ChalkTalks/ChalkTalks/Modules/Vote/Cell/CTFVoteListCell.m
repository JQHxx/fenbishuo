//
//  CTFVoteListCell.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/1/10.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFVoteListCell.h"
#import "CTFVoteListVC.h"
#import "CTFTopicAuthorView.h"
#import "CTFCommonManager.h"

typedef void(^Block)(void);

@interface CTFVoteListCell ()
@property (nonatomic, strong) UIView *shadowBgView;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIControl *skipQuestionDetailControl;
@property (nonatomic, strong) UILabel *titleLable;//标题
@property (nonatomic, strong) CTFTopicAuthorView *authorView;//前缀+头像+名字
@property (nonatomic, strong) UILabel *replyAccouontLabel;//回答数量、创建时间
@property (nonatomic, strong) UIImageView *replySignImageView;
@property (nonatomic, strong) UIImageView *hotValueProgressView;//热度值View
@property (nonatomic, strong) UILabel *hotTitleLable;//“热度”
@property (nonatomic, strong) UILabel *hotValueLable;//热度值Label
@property (nonatomic, strong) UILabel *tipLabel;//投票操作的影响力说明文字

@property (nonatomic, strong) UIView *careBtn_bgView;
@property (nonatomic, strong) UIView *stepBtn_bgView;
@property (nonatomic, strong) CTFBlockButton *careButton;//关心按钮
@property (nonatomic, strong) CTFBlockButton *stepButton;//踩的按钮

@property (nonatomic, assign) NSInteger indexNumber;
@property (nonatomic, strong) CTFQuestionsModel *questionsModel;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSArray<NSNumber *> *> *stateAttentionDictionary;

@property (nonatomic, copy) NSString *originalStateString_userWhenSvrError;

@property (nonatomic, strong) UIView *animationView_care;
@property (nonatomic, strong) UIView *animationView_step;

@property (nonatomic, strong) AnimationView *av_care;
@property (nonatomic, strong) AnimationView *av_step;

@end

@implementation CTFVoteListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.stateAttentionDictionary = [NSMutableDictionary dictionary];
        [self setupViewContent];
    }
    return self;
}

- (void)setupStateAttentionDictionaryByQuestionsModel:(CTFQuestionsModel *)questionsModel {
    
    CGFloat attention = questionsModel.attention;
    CGFloat maxAttention = questionsModel.maxAttention;
    NSString *state = questionsModel.attitude;
    
    if ([state isEqualToString:@"like"]) {
        self.stateAttentionDictionary[@"like"] = @[@(attention), @(maxAttention)];
        self.stateAttentionDictionary[@"unlike"] = @[@(attention-2<0 ? 0 : attention-2), @(maxAttention-2<0 ? 0 : maxAttention-2)];
        self.stateAttentionDictionary[@"neutral"] = @[@(attention-1<0 ? 0 : attention-1), @(maxAttention-1<0 ? 0 : maxAttention-1)];
    }
    
    if ([state isEqualToString:@"unlike"]) {
        self.stateAttentionDictionary[@"like"] = @[@(attention+2), @(maxAttention+2)];
        self.stateAttentionDictionary[@"unlike"] = @[@(attention), @(maxAttention)];
        self.stateAttentionDictionary[@"neutral"] = @[@(attention+1), @(maxAttention+1)];
    }
    
    if ([state isEqualToString:@"neutral"]) {
        self.stateAttentionDictionary[@"neutral"] = @[@(attention), @(maxAttention)];
        self.stateAttentionDictionary[@"like"] = @[@(attention+1), @(maxAttention+1)];
        self.stateAttentionDictionary[@"unlike"] = @[@(attention-1<0 ? 0 : attention-1), @(maxAttention-1<0 ? 0 : maxAttention-1)];
    }
}

- (void)fillContentWithData:(CTFQuestionsModel *)questionsModel indexNum:(NSInteger)indexNum sortType:(NSString *)sort {
    
    self.originalStateString_userWhenSvrError = questionsModel.attitude;
    self.indexNumber = indexNum;
    self.questionsModel = questionsModel;
    [self setupStateAttentionDictionaryByQuestionsModel:self.questionsModel];
    
    //
    if (self.av_care) {
        [self.animationView_care stopAnimation:self.av_care];
        self.av_care = nil;
    }
    [self.animationView_care removeFromSuperview];
    self.animationView_care = nil;
    
    if (self.av_step) {
        [self.animationView_step stopAnimation:self.av_step];
        self.av_step = nil;
    }
    [self.animationView_step removeFromSuperview];
    self.animationView_step = nil;
    
    //
    if (indexNum == 0 && [sort isEqualToString:@"default"]) {
        NSTextAttachment *attchImage = [[NSTextAttachment alloc] init];
        attchImage.image = [UIImage imageNamed:@"icon_hot_max"];
        attchImage.bounds = CGRectMake(0, -4, 30, 20);
        NSAttributedString *stringImage = [NSAttributedString attributedStringWithAttachment:attchImage];
        
        NSMutableAttributedString *titleAttribut = [[NSMutableAttributedString alloc]initWithString:@"  "];
        if (kIsEmptyString(questionsModel.shortTitle)) {
            [titleAttribut appendAttributedString:[[NSMutableAttributedString alloc]initWithString:questionsModel.title]];
        } else {
            [titleAttribut appendAttributedString:[CTFCommonManager setTopicTitleWithType:questionsModel.type shortTitle:questionsModel.shortTitle suffix:questionsModel.suffix]];
        }
        [titleAttribut insertAttributedString:stringImage atIndex:0];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        [paragraphStyle setLineSpacing:4.f];
        [titleAttribut addAttribute:NSParagraphStyleAttributeName
                              value:paragraphStyle
                              range:NSMakeRange(0, [titleAttribut length])];
        
        self.titleLable.attributedText = titleAttribut;
    } else {
        if (kIsEmptyString(questionsModel.shortTitle)) {
            self.titleLable.text = questionsModel.title;
        } else {
            NSMutableAttributedString *titleAttribut = [CTFCommonManager setTopicTitleWithType:questionsModel.type shortTitle:questionsModel.shortTitle suffix:questionsModel.suffix];
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            [paragraphStyle setLineSpacing:4.f];
            [titleAttribut addAttribute:NSParagraphStyleAttributeName
                                  value:paragraphStyle
                                  range:NSMakeRange(0, [titleAttribut length])];
            
            self.titleLable.attributedText = titleAttribut;
        }
    }
    //
    AuthorModel *temp_authorModel = [[AuthorModel alloc] init];
    temp_authorModel.authorId = questionsModel.author.authorId;
    temp_authorModel.avatarUrl = questionsModel.author.avatarUrl;
    temp_authorModel.name = questionsModel.author.name;
    temp_authorModel.city = questionsModel.author.city;
    temp_authorModel.gender = questionsModel.author.gender;
    temp_authorModel.headline = questionsModel.author.headline;
    temp_authorModel.isFollowing = NO;//CTFQuestionsModel中的缺省值
    [self.authorView fillDataWithType:questionsModel.type author:temp_authorModel];
    //回答数、创建时间
    if ([sort isEqualToString:@"default"]) {//默认排序下显示回答数
        self.replyAccouontLabel.text = [NSString stringWithFormat:@"%ld个回答", questionsModel.answerCount];
        self.replySignImageView.image = [UIImage imageNamed:@"icon_reply_account"];
        [self.replySignImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(18, 14));
            make.right.mas_equalTo(self.replyAccouontLabel.mas_left).offset(-3);
            make.centerY.mas_equalTo(self.replyAccouontLabel.mas_centerY);
        }];
    } else {
        self.replyAccouontLabel.text = [CTDateUtils formatTimeAgoWithTimestamp:questionsModel.createdAt];
        self.replySignImageView.image = [UIImage imageNamed:@"icon_reply_time"];
        [self.replySignImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(16, 16));
            make.right.mas_equalTo(self.replyAccouontLabel.mas_left).offset(-3);
            make.centerY.mas_equalTo(self.replyAccouontLabel.mas_centerY);
        }];
    }
    //
    CGFloat hotValue;
    if (questionsModel.attention == 0) {
        hotValue = 0;
    } else {
        hotValue = (questionsModel.attention / questionsModel.maxAttention);
    }
    [self.hotValueProgressView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(85 + (kScreen_Width-30-56-80-85)*hotValue);
    }];
    //
    CGFloat hotValueForShow = questionsModel.attention;
    if (hotValueForShow > 999) {
        hotValueForShow = hotValueForShow / 1000.f;
        self.hotValueLable.text = [NSString stringWithFormat:@"%0.2lfK", hotValueForShow];
    } else {
        self.hotValueLable.text = [NSString stringWithFormat:@"%0.2lf", hotValueForShow];
    }
    if (hotValueForShow < 0.01) {
        self.hotValueProgressView.image = [[UIImage imageNamed:@"bg_vote_progress_disable"] ctfResizingImageState];
        self.hotTitleLable.textColor = UIColorFromHEX(0x999999);
        self.hotValueLable.textColor = UIColorFromHEX(0x999999);
    } else {
        self.hotValueProgressView.image = [[UIImage imageNamed:@"bg_vote_progress_normal"] ctfResizingImageState];
        self.hotTitleLable.textColor = UIColorFromHEX(0xFFFFFF);
        self.hotValueLable.textColor = UIColorFromHEX(0xFFFFFF);
    }
    //
    [self updateButtonBackgroundColorByState:questionsModel.attitude];
    
}

- (void)setupViewContent {
    //
    self.shadowBgView = [[UIView alloc] init];
    self.shadowBgView.backgroundColor = UIColorFromHEX(0xFFFFFF);
    self.shadowBgView.layer.shadowColor = UIColorFromHEXWithAlpha(0x999999, 0.2).CGColor;
    self.shadowBgView.layer.shadowOpacity = 0.8;
    self.shadowBgView.layer.shadowOffset = CGSizeMake(0, 2);
    self.shadowBgView.layer.shadowRadius = 8;
    [self.contentView addSubview:self.shadowBgView];
    [self.shadowBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(16);
        make.top.mas_equalTo(self.contentView.mas_top).offset(8);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-8);
        make.width.mas_equalTo(kScreen_Width - 32);
        make.height.mas_greaterThanOrEqualTo(137);
    }];
    //
    self.bgView = [[UIView alloc] init];
    self.bgView.backgroundColor = UIColorFromHEX(0xFFFFFF);
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.cornerRadius = 8;
    [self.contentView addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.shadowBgView);
    }];
    //
    self.skipQuestionDetailControl = [[UIControl alloc] init];
    [self.skipQuestionDetailControl addTarget:self action:@selector(skipQuestionDetailControlAction) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:self.skipQuestionDetailControl];
    [self.skipQuestionDetailControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView.mas_left);
        make.top.mas_equalTo(self.bgView.mas_top);
        make.bottom.mas_equalTo(self.bgView.mas_bottom);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-40);
    }];
    //
    self.titleLable = [[UILabel alloc] init];
    self.titleLable.numberOfLines = 0;
    self.titleLable.lineBreakMode = UILineBreakModeCharacterWrap;
//    self.titleLable.preferredMaxLayoutWidth = kScreen_Width - 20;
    self.titleLable.font = [UIFont systemFontOfSize:18];
    self.titleLable.textColor = UIColorFromHEX(0x333333);
    [self.skipQuestionDetailControl addSubview:self.titleLable];
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.skipQuestionDetailControl.mas_top).offset(14);
        make.right.mas_equalTo(self.skipQuestionDetailControl.mas_right).offset(-3);
        make.left.mas_equalTo(self.skipQuestionDetailControl.mas_left).offset(15);
        make.height.mas_greaterThanOrEqualTo(25);
        make.width.mas_greaterThanOrEqualTo(270);
    }];
    //
    self.replyAccouontLabel = [[UILabel alloc] init];
    self.replyAccouontLabel.font = [UIFont systemFontOfSize:12];
    self.replyAccouontLabel.textColor = UIColorFromHEX(0xc2c2c2);
    [self.skipQuestionDetailControl addSubview:self.replyAccouontLabel];
    [self.replyAccouontLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.skipQuestionDetailControl.mas_right).offset(-17);
        make.top.mas_equalTo(self.titleLable.mas_bottom).offset(11);
//        make.width.mas_greaterThanOrEqualTo(60);
        make.height.mas_greaterThanOrEqualTo(17);
    }];
    //
    self.replySignImageView = [[UIImageView alloc] init];
    self.replySignImageView.image = [UIImage imageNamed:@"icon_reply_account"];
    [self.skipQuestionDetailControl addSubview:self.replySignImageView];
    [self.replySignImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(18, 14));
        make.right.mas_equalTo(self.replyAccouontLabel.mas_left).offset(-3);
        make.centerY.mas_equalTo(self.replyAccouontLabel.mas_centerY);
    }];
    //
    self.authorView = [[CTFTopicAuthorView alloc] init];
    [self.skipQuestionDetailControl addSubview:self.authorView];
    [self.authorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.replyAccouontLabel.mas_centerY);
        make.left.mas_equalTo(self.skipQuestionDetailControl.mas_left).offset(0);
    }];
    
    //
    self.hotValueProgressView = [[UIImageView alloc] init];
    self.hotValueProgressView.image = [[UIImage imageNamed:@"bg_vote_progress_normal"] ctfResizingImageState];
    [self.skipQuestionDetailControl addSubview:self.hotValueProgressView];
    [self.hotValueProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.skipQuestionDetailControl.mas_left).offset(14);
        make.top.mas_equalTo(self.replyAccouontLabel.mas_bottom).offset(12);
        make.height.mas_equalTo(29);
        make.width.mas_greaterThanOrEqualTo(85);
    }];
    
    self.hotTitleLable = [[UILabel alloc] init];
    self.hotTitleLable.text = @"热度";
    self.hotTitleLable.font = [UIFont systemFontOfSize:12];
    self.hotTitleLable.textColor = UIColorFromHEX(0xFFFFFF);
    [self.hotValueProgressView addSubview:self.hotTitleLable];
    [self.hotTitleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.hotValueProgressView.mas_left).offset(14);
        make.centerY.mas_equalTo(self.hotValueProgressView.mas_centerY);
    }];
    
    self.hotValueLable = [[UILabel alloc] init];
    self.hotValueLable.text = @"0";
    self.hotValueLable.font = [UIFont systemFontOfSize:12];
    self.hotValueLable.textColor = UIColorFromHEX(0xFFFFFF);
    [self.hotValueProgressView addSubview:self.hotValueLable];
    [self.hotValueLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.hotValueProgressView.mas_right).offset(-14);
        make.centerY.mas_equalTo(self.hotValueProgressView.mas_centerY);
    }];
    
    //
    self.tipLabel = [[UILabel alloc] init];
    self.tipLabel.font = [UIFont systemFontOfSize:12];
    self.tipLabel.textColor = UIColorFromHEX(0xFF6885);
    self.tipLabel.text = @" ";
    [self.skipQuestionDetailControl addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.skipQuestionDetailControl.mas_left).offset(14);
        make.top.mas_equalTo(self.hotValueProgressView.mas_bottom).offset(5);
        make.bottom.mas_equalTo(self.skipQuestionDetailControl.mas_bottom).offset(-8);
        make.height.mas_greaterThanOrEqualTo(17);
    }];
    //
    self.careBtn_bgView = [[UIView alloc] init];
    self.careBtn_bgView.layer.masksToBounds = YES;
    self.careBtn_bgView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:self.careBtn_bgView];
    [self.careBtn_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView.mas_top);
        make.right.mas_equalTo(self.bgView.mas_right);
        make.width.mas_equalTo(40);
        make.height.mas_greaterThanOrEqualTo(68);
        make.bottom.mas_equalTo(self.bgView.mas_centerY);
    }];
    //
    self.careButton = [CTFBlockButton buttonWithType:UIButtonTypeCustom];
    self.careButton.eventTimeInterval = 0.8;
    self.careButton.exclusiveTouch = YES;
    
    [self.careButton setImage:[UIImage imageNamed:@"icon_care_normal"] forState:UIControlStateNormal];
    [self.careButton setImage:[UIImage imageNamed:@"icon_care_press"] forState:UIControlStateSelected];
    [self.careButton setImage:[UIImage imageNamed:@"icon_care_press"] forState:UIControlStateDisabled];
    
    [self.careButton addTarget:self action:@selector(careButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.careBtn_bgView addSubview:self.careButton];
    [self.careButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.careBtn_bgView);
    }];
    //
    self.stepBtn_bgView = [[UIView alloc] init];
    self.stepBtn_bgView.layer.masksToBounds = YES;
    self.stepBtn_bgView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:self.stepBtn_bgView];
    [self.stepBtn_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView.mas_centerY);
        make.right.mas_equalTo(self.bgView.mas_right);
        make.width.mas_equalTo(40);
        make.height.mas_greaterThanOrEqualTo(68);
        make.bottom.mas_equalTo(self.bgView.mas_bottom);
    }];
    //
    self.stepButton = [CTFBlockButton buttonWithType:UIButtonTypeCustom];
    self.stepButton.eventTimeInterval = 0.8;
    self.stepButton.exclusiveTouch = YES;
    
    [self.stepButton setImage:[UIImage imageNamed:@"icon_step_normal"] forState:UIControlStateNormal];
    [self.stepButton setImage:[UIImage imageNamed:@"icon_step_press"] forState:UIControlStateSelected];
    [self.stepButton setImage:[UIImage imageNamed:@"icon_step_press"] forState:UIControlStateDisabled];
        
    [self.stepButton addTarget:self action:@selector(stepButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.stepBtn_bgView addSubview:self.stepButton];
    [self.stepButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.stepBtn_bgView);
    }];
    //
    UIView *lineView_V = [[UIView alloc] init];
    lineView_V.backgroundColor = UIColorFromHEX(0xEEEEEE);
    [self.bgView addSubview:lineView_V];
    [lineView_V mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView.mas_top);
        make.height.mas_equalTo(self.bgView.mas_height);
        make.width.mas_equalTo(1);
        make.right.mas_equalTo(self.bgView.mas_right).offset(-40);
    }];
    //
    UIView *lineView_H = [[UIView alloc] init];
    lineView_H.backgroundColor = UIColorFromHEX(0xEEEEEE);
    [self.bgView addSubview:lineView_H];
    [lineView_H mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView.mas_centerY);
        make.height.mas_equalTo(1);
        make.right.mas_equalTo(self.bgView.mas_right);
        make.width.mas_equalTo(40);
    }];
}

- (void)updateButtonBackgroundColorByState:(NSString *)state {
    
    if ([state isEqualToString:@"neutral"]) {
        
        //careBtn
        [self.careButton setBackgroundColor:UIColorFromHEXWithAlpha(0xFFFFFF, 0.05)];
        [self.careButton setSelected:NO];
        //stepBtn
        [self.stepButton setBackgroundColor:UIColorFromHEXWithAlpha(0xFFFFFF, 0.05)];
        [self.stepButton setSelected:NO];
    }
    
    if ([state isEqualToString:@"unlike"]) {
        
        //careBtn
        [self.careButton setBackgroundColor:UIColorFromHEXWithAlpha(0xFFFFFF, 0.05)];
        [self.careButton setSelected:NO];
        //stepBtn
        [self.stepButton setBackgroundColor:UIColorFromHEX(0x4D9FFF)];
        [self.stepButton setSelected:YES];
    }
    
    if ([state isEqualToString:@"like"]) {
        
        //careBtn
        [self.careButton setBackgroundColor:UIColorFromHEX(0xFF6885)];
        [self.careButton setSelected:YES];
        //stepBtn
        [self.stepButton setBackgroundColor:UIColorFromHEXWithAlpha(0xFFFFFF, 0.05)];
        [self.stepButton setSelected:NO];
    }
}

- (NSString *)queryStatesByBeans {
    
    NSString *stateString = @"";
    
    CTFVoteListVC *voteListVC = (CTFVoteListVC *)self.findViewController;
    CTFQuestionsModel *questionsModel = [voteListVC.adpater voteModelForCategoryId:voteListVC.categoryId index:self.indexNumber];
    stateString = questionsModel.attitude;
    
    return stateString;
}

#pragma mark - 点击事件

- (void)careButtonAction:(UIButton *)btn {
    
    //没有网络直接不进行任何操作
    if ([[CTFNetReachabilityManager sharedInstance] currentNetStatus] == AFNetworkReachabilityStatusNotReachable) {
        [kKeyWindow makeToast:@"请检查网络！"];
        return ;
    }
    
    //检测登录状态
    if (![self.findViewController ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded]) {
        return;
    }
    
    [self lockButton:YES];
    
    @weakify(self);
    void(^careBtnAnimationFun)(void) = ^{
        @strongify(self);
        CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.fromValue=[NSNumber numberWithFloat:1.0];
        animation.toValue=[NSNumber numberWithFloat:1.5];
        animation.duration=0.3;
        animation.autoreverses=YES;
        animation.repeatCount=70;
        animation.removedOnCompletion=YES;
        animation.fillMode=kCAFillModeRemoved;
        [self.careButton.layer addAnimation:animation forKey:@"zoom"];
    };

    //UI交互
    NSString *currentStateString = [self queryStatesByBeans];
    NSString *nextStateString = @"";
    if ([currentStateString isEqualToString:@"neutral"]) {
        nextStateString = @"like";
        [self updateButtonBackgroundColorByState:nextStateString];
        careBtnAnimationFun();
    }
    
    if ([currentStateString isEqualToString:@"unlike"]) {
        nextStateString = @"like";
        [self updateButtonBackgroundColorByState:nextStateString];
        careBtnAnimationFun();
        
        if (self.av_step) {
            [self.animationView_step stopAnimation:self.av_step];
            self.av_step = nil;
        }
        [self.animationView_step removeFromSuperview];
        self.animationView_step = nil;
    }
    
    if ([currentStateString isEqualToString:@"like"]) {
        nextStateString = @"neutral";
        careBtnAnimationFun();
    }
    
    if (self.av_care) {
        [self.animationView_care stopAnimation:self.av_care];
        self.av_care = nil;
    }
    [self.animationView_care removeFromSuperview];
    self.animationView_care = nil;
    
    //数据源交互
    CTFVoteListVC *voteListVC = (CTFVoteListVC *)self.findViewController;
    CTFQuestionsModel *questionsModel = [voteListVC.adpater voteModelForCategoryId:voteListVC.categoryId index:self.indexNumber];
    questionsModel.attitude = nextStateString;
    questionsModel.attention = [self.stateAttentionDictionary[nextStateString] objectAtIndex:0].floatValue;
    questionsModel.maxAttention = [self.stateAttentionDictionary[nextStateString] objectAtIndex:1].floatValue;
    [voteListVC.adpater reviseModel:questionsModel toCategoryId:voteListVC.categoryId toQuestionId:questionsModel.questionId];

    //网络交互
    [voteListVC.adpater svr_voteQuestionId:self.questionsModel.questionId toState:nextStateString complete:^(BOOL isSuccess) {
        @strongify(self);
        [self.careButton.layer removeAllAnimations];
        if (!isSuccess) {
            @weakify(self);
            dispatch_queue_t queue = dispatch_get_main_queue();
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), queue, ^{
                @strongify(self);
                [self lockButton:NO];
                });
            
            NSString *beforeStateString = @"";
            beforeStateString = self.originalStateString_userWhenSvrError;
            
            [self updateButtonBackgroundColorByState:beforeStateString];
            
            //数据源交互
            CTFVoteListVC *voteListVC = (CTFVoteListVC *)self.findViewController;
            CTFQuestionsModel *questionsModel = [voteListVC.adpater voteModelForCategoryId:voteListVC.categoryId index:self.indexNumber];
            questionsModel.attitude = beforeStateString;
            questionsModel.attention = [self.stateAttentionDictionary[beforeStateString] objectAtIndex:0].floatValue;
            questionsModel.maxAttention = [self.stateAttentionDictionary[beforeStateString] objectAtIndex:1].floatValue;
            [voteListVC.adpater reviseModel:questionsModel toCategoryId:voteListVC.categoryId toQuestionId:questionsModel.questionId];
            
            //按照新数据进行展示
            CGFloat hotValue;
            if (questionsModel.attention == 0) {
                hotValue = 0;
            } else {
                hotValue = (self.stateAttentionDictionary[beforeStateString].firstObject.floatValue / self.stateAttentionDictionary[beforeStateString].lastObject.floatValue);
            }
            [self.hotValueProgressView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(85 + (kScreen_Width-30-56-80-85)*hotValue);
            }];
            //
            CGFloat hotValueForShow = questionsModel.attention;
            if (hotValueForShow > 999) {
                hotValueForShow = hotValueForShow / 1000.f;
                self.hotValueLable.text = [NSString stringWithFormat:@"%0.2lfK", hotValueForShow];
            } else {
                self.hotValueLable.text = [NSString stringWithFormat:@"%0.2lf", hotValueForShow];
            }
            if (hotValueForShow < 0.01) {
                self.hotValueProgressView.image = [[UIImage imageNamed:@"bg_vote_progress_disable"] ctfResizingImageState];
                self.hotTitleLable.textColor = UIColorFromHEX(0x999999);
                self.hotValueLable.textColor = UIColorFromHEX(0x999999);
            } else {
                self.hotValueProgressView.image = [[UIImage imageNamed:@"bg_vote_progress_normal"] ctfResizingImageState];
                self.hotTitleLable.textColor = UIColorFromHEX(0xFFFFFF);
                self.hotValueLable.textColor = UIColorFromHEX(0xFFFFFF);
            }
            
            [kKeyWindow makeToast:voteListVC.adpater.errorString];
        } else {
            [self lockButton:NO];
            self.originalStateString_userWhenSvrError = nextStateString;
            [voteListVC removeVoteLearningView];
            
            //按照新数据进行展示
            CGFloat hotValue;
            if (questionsModel.attention == 0) {
                hotValue = 0;
            } else {
                hotValue = (self.stateAttentionDictionary[nextStateString].firstObject.floatValue / self.stateAttentionDictionary[nextStateString].lastObject.floatValue);
            }
            [self.hotValueProgressView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(85 + (kScreen_Width-30-56-80-85)*hotValue);
            }];
            //
            CGFloat hotValueForShow = questionsModel.attention;
            if (hotValueForShow > 999) {
                hotValueForShow = hotValueForShow / 1000.f;
                self.hotValueLable.text = [NSString stringWithFormat:@"%0.2lfK", hotValueForShow];
            } else {
                self.hotValueLable.text = [NSString stringWithFormat:@"%0.2lf", hotValueForShow];
            }
            if (hotValueForShow < 0.01) {
                self.hotValueProgressView.image = [[UIImage imageNamed:@"bg_vote_progress_disable"] ctfResizingImageState];
                self.hotTitleLable.textColor = UIColorFromHEX(0x999999);
                self.hotValueLable.textColor = UIColorFromHEX(0x999999);
            } else {
                self.hotValueProgressView.image = [[UIImage imageNamed:@"bg_vote_progress_normal"] ctfResizingImageState];
                self.hotTitleLable.textColor = UIColorFromHEX(0xFFFFFF);
                self.hotValueLable.textColor = UIColorFromHEX(0xFFFFFF);
            }
            
            //成功之后再有动画效果
            if ([nextStateString isEqualToString:@"like"]) {
                
                //将会增加。。。。。
                [self.tipLabel setAlpha:1.f];
                NSInteger temp_random = [self fetchRandomNumber:self.questionsModel.referenceValue/2 to:self.questionsModel.referenceValue];
                self.tipLabel.text = [NSString stringWithFormat:@"将会增加%ld人看到该话题", temp_random];
                self.tipLabel.textColor = UIColorFromHEX(0xFF6885);
                [UIView animateWithDuration:4.f animations:^{
                    @strongify(self);
                    [self.tipLabel setAlpha:0.f];
                } completion:^(BOOL finished) {
                }];
                
                //撒爱心的动画。。。。。
                self.av_care = [self.animationView_care showVoteSuccessedCareAnimation:CTLottieAnimationTypeVoteCare completion:nil];
                dispatch_queue_t queue = dispatch_get_main_queue();
                @weakify(self);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), queue, ^{
                    @strongify(self);
                    if (self.av_care) {
                        [self.animationView_care stopAnimation:self.av_care];
                        self.av_care = nil;;
                    }
                    [self.animationView_care removeFromSuperview];
                    self.animationView_care = nil;
                    });
                
            } else if ([nextStateString isEqualToString:@"neutral"]) {
                
                //根据产品UI的交互效果，如果是从like到neutral，使用like状态的按钮进行缩放
                [self updateButtonBackgroundColorByState:nextStateString];
                
                //将会减少。。。。。
                [self.tipLabel setAlpha:1.f];
                NSInteger temp_random = [self fetchRandomNumber:self.questionsModel.referenceValue/2 to:self.questionsModel.referenceValue];
                self.tipLabel.text = [NSString stringWithFormat:@"将会减少%ld人看到该话题", temp_random];
                self.tipLabel.textColor = UIColorFromHEX(0x4D9FFF);
                [UIView animateWithDuration:4.f animations:^{
                    @strongify(self);
                    [self.tipLabel setAlpha:0.f];
                } completion:^(BOOL finished) {
                }];
            }
        }
    }];
}

- (void)stepButtonAction:(UIButton *)btn {
    
    //没有网络直接不进行任何操作
    if ([[CTFNetReachabilityManager sharedInstance] currentNetStatus] == AFNetworkReachabilityStatusNotReachable) {
        [kKeyWindow makeToast:@"请检查网络！"];
        return ;
    }
    
    if (![self.findViewController ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded]) {
        return;
    }
    
    [self lockButton:YES];

    //UI交互
    @weakify(self);
    void(^stepBtnAnimationFun)(void) = ^{
        @strongify(self);
        CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.fromValue=[NSNumber numberWithFloat:1.0];
        animation.toValue=[NSNumber numberWithFloat:1.5];
        animation.duration=0.3;
        animation.autoreverses=YES;
        animation.repeatCount=70;
        animation.removedOnCompletion=YES;
        animation.fillMode=kCAFillModeRemoved;
        [self.stepButton.layer addAnimation:animation forKey:@"zoom"];
    };
    NSString *currentStateString = [self queryStatesByBeans];
    NSString *nextStateString = @"";
    if ([currentStateString isEqualToString:@"neutral"]) {
        nextStateString = @"unlike";
        [self updateButtonBackgroundColorByState:nextStateString];
        stepBtnAnimationFun();
    }
    
    if ([currentStateString isEqualToString:@"unlike"]) {
        nextStateString = @"neutral";
        stepBtnAnimationFun();
        
        if (self.av_step) {
            [self.animationView_step stopAnimation:self.av_step];
            self.av_step = nil;
        }
        [self.animationView_step removeFromSuperview];
        self.animationView_step = nil;
    }
    
    if ([currentStateString isEqualToString:@"like"]) {
        nextStateString = @"unlike";
        [self updateButtonBackgroundColorByState:nextStateString];
        stepBtnAnimationFun();
        
        if (self.av_care) {
            [self.animationView_care stopAnimation:self.av_care];
            self.av_care = nil;
        }
        [self.animationView_care removeFromSuperview];
        self.animationView_care = nil;
    }
    
    //数据源交互
    CTFVoteListVC *voteListVC = (CTFVoteListVC *)self.findViewController;
    CTFQuestionsModel *questionsModel = [voteListVC.adpater voteModelForCategoryId:voteListVC.categoryId index:self.indexNumber];
    questionsModel.attitude = nextStateString;
    questionsModel.attention = [self.stateAttentionDictionary[nextStateString] objectAtIndex:0].floatValue;
    questionsModel.maxAttention = [self.stateAttentionDictionary[nextStateString] objectAtIndex:1].floatValue;
    [voteListVC.adpater reviseModel:questionsModel toCategoryId:voteListVC.categoryId toQuestionId:questionsModel.questionId];
    
    //网络交互
    [voteListVC.adpater svr_voteQuestionId:self.questionsModel.questionId toState:nextStateString complete:^(BOOL isSuccess) {
        @strongify(self);
        [self.stepButton.layer removeAllAnimations];
        if (!isSuccess) {
            @weakify(self);
            dispatch_queue_t queue = dispatch_get_main_queue();
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), queue, ^{
                @strongify(self);
                [self lockButton:NO];
                });
            
            NSString *beforeStateString = @"";
            beforeStateString = self.originalStateString_userWhenSvrError;
            
            [self updateButtonBackgroundColorByState:beforeStateString];
            
            //数据源交互
            CTFVoteListVC *voteListVC = (CTFVoteListVC *)self.findViewController;
            CTFQuestionsModel *questionsModel = [voteListVC.adpater voteModelForCategoryId:voteListVC.categoryId index:self.indexNumber];
            questionsModel.attitude = beforeStateString;
            questionsModel.attention = [self.stateAttentionDictionary[beforeStateString] objectAtIndex:0].floatValue;
            questionsModel.maxAttention = [self.stateAttentionDictionary[beforeStateString] objectAtIndex:1].floatValue;
            [voteListVC.adpater reviseModel:questionsModel toCategoryId:voteListVC.categoryId toQuestionId:questionsModel.questionId];
            
            //按照新数据进行展示
            CGFloat hotValue;
            if (questionsModel.attention == 0) {
                hotValue = 0;
            } else {
                hotValue = (self.stateAttentionDictionary[beforeStateString].firstObject.floatValue / self.stateAttentionDictionary[beforeStateString].lastObject.floatValue);
            }
            [self.hotValueProgressView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(85 + (kScreen_Width-30-56-80-85)*hotValue);
            }];
            //
            CGFloat hotValueForShow = questionsModel.attention;
            if (hotValueForShow > 999) {
                hotValueForShow = hotValueForShow / 1000.f;
                self.hotValueLable.text = [NSString stringWithFormat:@"%0.2lfK", hotValueForShow];
            } else {
                self.hotValueLable.text = [NSString stringWithFormat:@"%0.2lf", hotValueForShow];
            }
            if (hotValueForShow < 0.01) {
                self.hotValueProgressView.image = [[UIImage imageNamed:@"bg_vote_progress_disable"] ctfResizingImageState];
                self.hotTitleLable.textColor = UIColorFromHEX(0x999999);
                self.hotValueLable.textColor = UIColorFromHEX(0x999999);
            } else {
                self.hotValueProgressView.image = [[UIImage imageNamed:@"bg_vote_progress_normal"] ctfResizingImageState];
                self.hotTitleLable.textColor = UIColorFromHEX(0xFFFFFF);
                self.hotValueLable.textColor = UIColorFromHEX(0xFFFFFF);
            }
            
            [kKeyWindow makeToast:voteListVC.adpater.errorString];
        } else {
            [self lockButton:NO];
            self.originalStateString_userWhenSvrError = nextStateString;
            [voteListVC removeVoteLearningView];
            
            //按照新数据进行展示
            CGFloat hotValue;
            if (questionsModel.attention == 0) {
                hotValue = 0;
            } else {
                hotValue = (self.stateAttentionDictionary[nextStateString].firstObject.floatValue / self.stateAttentionDictionary[nextStateString].lastObject.floatValue);
            }
            [self.hotValueProgressView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(85 + (kScreen_Width-30-56-80-85)*hotValue);
            }];
            //
            CGFloat hotValueForShow = questionsModel.attention;
            if (hotValueForShow > 999) {
                hotValueForShow = hotValueForShow / 1000.f;
                self.hotValueLable.text = [NSString stringWithFormat:@"%0.2lfK", hotValueForShow];
            } else {
                self.hotValueLable.text = [NSString stringWithFormat:@"%0.2lf", hotValueForShow];
            }
            if (hotValueForShow < 0.01) {
                self.hotValueProgressView.image = [[UIImage imageNamed:@"bg_vote_progress_disable"] ctfResizingImageState];
                self.hotTitleLable.textColor = UIColorFromHEX(0x999999);
                self.hotValueLable.textColor = UIColorFromHEX(0x999999);
            } else {
                self.hotValueProgressView.image = [[UIImage imageNamed:@"bg_vote_progress_normal"] ctfResizingImageState];
                self.hotTitleLable.textColor = UIColorFromHEX(0xFFFFFF);
                self.hotValueLable.textColor = UIColorFromHEX(0xFFFFFF);
            }
            
            //回调成功之后再进行动画效果
            if ([nextStateString isEqualToString:@"unlike"]) {
                
                //将会减少。。。。。
                [self.tipLabel setAlpha:1.f];
                NSInteger temp_random = [self fetchRandomNumber:self.questionsModel.referenceValue/2 to:self.questionsModel.referenceValue];
                self.tipLabel.text = [NSString stringWithFormat:@"将会减少%ld人看到该话题", temp_random];
                self.tipLabel.textColor = UIColorFromHEX(0x4D9FFF);
                [UIView animateWithDuration:4.f animations:^{
                    @strongify(self);
                    [self.tipLabel setAlpha:0.f];
                } completion:^(BOOL finished) {
                }];
                
                //脚印的动画。。。。。
                @weakify(self);
                self.av_step = [self.animationView_step showVoteSuccessedStepAnimation:CTLottieAnimationTypeVoteStep completion:nil];
                dispatch_queue_t queue = dispatch_get_main_queue();
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), queue, ^{
                    @strongify(self);
                    if (self.av_step) {
                        [self.animationView_step stopAnimation:self.av_step];
                        self.av_step = nil;
                    }
                    [self.animationView_step removeFromSuperview];
                    self.animationView_step = nil;
                    });
                
            } else if ([nextStateString isEqualToString:@"neutral"]) {
                
                //根据产品UI的交互效果，如果是从unlike到neutral，使用like状态的按钮进行缩放
                [self updateButtonBackgroundColorByState:nextStateString];
                
                //将会增加。。。。。
                [self.tipLabel setAlpha:1.f];
                NSInteger temp_random = [self fetchRandomNumber:self.questionsModel.referenceValue/2 to:self.questionsModel.referenceValue];
                self.tipLabel.text = [NSString stringWithFormat:@"将会增加%ld人看到该话题", temp_random];
                self.tipLabel.textColor = UIColorFromHEX(0xFF6885);
                [UIView animateWithDuration:4.f animations:^{
                    @strongify(self);
                    [self.tipLabel setAlpha:0.f];
                } completion:^(BOOL finished) {
                }];
            }
        }
    }];
    
}

//跳转到话题详情VC
- (void)skipQuestionDetailControlAction {
    if ([_delegate respondsToSelector:@selector(tableViewCell:touchedSkipQuestionDetailId:)]) {
        [_delegate tableViewCell:self touchedSkipQuestionDetailId:self.questionsModel.questionId];
    }
}

- (UIView *)animationView_care {
    if (!_animationView_care) {
        _animationView_care = [[UIView alloc] init];
        _animationView_care.userInteractionEnabled = NO;
        [self.contentView addSubview:_animationView_care];
        [_animationView_care mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView.mas_left).offset(16);
            make.top.mas_equalTo(self.contentView.mas_top).offset(8);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-8);
            make.width.mas_equalTo(kScreen_Width - 32 - 40);
        }];
    }
    return _animationView_care;
}

- (UIView *)animationView_step {
    if (!_animationView_step) {
        _animationView_step = [[UIView alloc] init];
        _animationView_step.userInteractionEnabled = NO;
        [self.contentView addSubview:_animationView_step];
        [_animationView_step mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.stepButton.mas_left).offset(0);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(0);
            make.size.mas_equalTo(CGSizeMake(80, 80));
        }];
    }
    return _animationView_step;
}

//获取[from, to]随机数
- (NSInteger)fetchRandomNumber:(NSInteger)from to:(NSInteger)to {
   return (NSInteger)(from + (arc4random() % (to - from + 1)));
}

- (void)lockButton:(BOOL)lock {
    self.userInteractionEnabled = !lock;
}

@end
