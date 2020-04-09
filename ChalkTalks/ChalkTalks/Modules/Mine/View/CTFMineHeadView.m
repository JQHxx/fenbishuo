//
//  CTFMineHeadView.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/3/10.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFMineHeadView.h"
#import "CTFMineVC.h"

static NSString * const kHeadBgImage_headled_cacheKey = @"com.fenbishuo.ios.user.headBgImage_headled";
static NSString * const kHeadImage_headled_cacheKey = @"com.fenbishuo.ios.user.headImage_headled";

@interface CTFMineHeadView ()

@property (nonatomic, copy) NSString *placeholderImage_cacheURL;//缓存头像image的url
@property (nonatomic, strong) UIImage *placeholderImage_headBgImage;
@property (nonatomic, strong) UIImage *placeholderImage_headImage;

@property (nonatomic, strong) UIImageView *headBgImageView;//高斯模糊的头像背景图
@property (nonatomic, strong) UIView *contentBgView;//容器view
@property (nonatomic, strong) UIImageView *headImageView;//头像图
@property (nonatomic, strong) UIControl *headImageControl;//头像图上的点击事件
@property (nonatomic, strong) UILabel *nameLabel;//昵称
@property (nonatomic, strong) UILabel *signLabel;//签名
@property (nonatomic, strong) UIButton *homePageButton;//个人主页按钮

@property (nonatomic, strong) UILabel *agreeAccountLabel;//靠谱数量
@property (nonatomic, strong) UILabel *agreeTitleLabel;//靠谱title
@property (nonatomic, strong) UIControl *agreeControl;//靠谱的点击事件

@property (nonatomic, strong) UILabel *fansAccountLabel;//粉丝数量
@property (nonatomic, strong) UILabel *fansTitleLabel;//粉丝title
@property (nonatomic, strong) UIControl *fansControl;//粉丝的点击事件

@property (nonatomic, strong) UILabel *careAccountLabel;//关注数量
@property (nonatomic, strong) UILabel *careTitleLabel;//关注title
@property (nonatomic, strong) UIControl *careControl;//关注的点击事件

@property (nonatomic, strong) UIButton *mineTopicButton;//我发起的话题
@property (nonatomic, strong) UIButton *careTopicButton;//我关心的话题
@property (nonatomic, strong) UIButton *mineViewPointButton;//我发布的观点

@end

@implementation CTFMineHeadView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViewContent];
        [self setupMonitor];
    }
    return self;
}

// 监听退出登录的通知
- (void)setupMonitor {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutedHandle) name:kLogoutedNotification object:nil];
}

// 退出登录后将高斯模糊处理的头像内存缓存清空
- (void)logoutedHandle {
    self.placeholderImage_cacheURL = nil;
    [[SDImageCache sharedImageCache] removeImageForKey:kHeadBgImage_headled_cacheKey withCompletion:nil];
    [[SDImageCache sharedImageCache] removeImageForKey:kHeadImage_headled_cacheKey withCompletion:nil];
    self.placeholderImage_headBgImage = [UIImage imageNamed:@"placeholder_headBg_375x146"];
    self.placeholderImage_headImage = [UIImage imageNamed:@"placeholder_head_78x78"];
    self.headBgImageView.image = self.placeholderImage_headBgImage;
    self.headImageView.image = self.placeholderImage_headImage;
}

- (void)updataViewContent {
    
    if (![UserCache.getUserInfo.avatarUrl isEqualToString:self.placeholderImage_cacheURL]) {
        @weakify(self);
        [self.headBgImageView sd_setImageWithURL:[NSURL URLWithString:UserCache.getUserInfo.avatarUrl] placeholderImage:self.placeholderImage_headBgImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            @strongify(self);
            if (!error) {
                // 在等待子线程高斯模糊处理好image之前，依然使用之前的image占位显示
                self.headBgImageView.image = self.placeholderImage_headBgImage;
                @weakify(self);
                [UIImage ctfBoxblurImage:image withBlurNumber:10 completeBlock:^(UIImage *handledImage) {
                    @strongify(self);
                    if (handledImage) {
                        [[SDImageCache sharedImageCache] storeImage:handledImage forKey:kHeadBgImage_headled_cacheKey completion:nil];
                        self.headBgImageView.image = handledImage;
                        self.placeholderImage_headBgImage = handledImage;
                        self.placeholderImage_cacheURL = UserCache.getUserInfo.avatarUrl;
                    }
                }];
            }
        }];
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:UserCache.getUserInfo.avatarUrl] placeholderImage:self.placeholderImage_headImage completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            @strongify(self);
            if (!error) {
                if (![UserCache.getUserInfo.avatarUrl isEqualToString:self.placeholderImage_cacheURL]) {
                    [[SDImageCache sharedImageCache] storeImage:image forKey:kHeadImage_headled_cacheKey completion:nil];
                    self.placeholderImage_headImage = image;
                    self.placeholderImage_cacheURL = UserCache.getUserInfo.avatarUrl;
                }
            }
        }];
    }
    
    self.nameLabel.text = UserCache.getUserInfo.name;
    
    if (UserCache.getUserInfo.headline.length > 0) {
        self.signLabel.text = UserCache.getUserInfo.headline;
    } else {
        self.signLabel.text = @"添加签名，让大家更好的认识你。";
    }
    
    self.agreeAccountLabel.text = [self numberTransforByIntNumber:UserCache.getUserInfo.likeCount];
    
    self.fansAccountLabel.text = [self numberTransforByIntNumber:UserCache.getUserInfo.followerCount];
    
    self.careAccountLabel.text = [self numberTransforByIntNumber:UserCache.getUserInfo.followingUserCount];
}

- (void)setupViewContent {
    
    self.placeholderImage_headBgImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:kHeadBgImage_headled_cacheKey] ? [[SDImageCache sharedImageCache] imageFromCacheForKey:kHeadBgImage_headled_cacheKey] : [UIImage imageNamed:@"placeholder_headBg_375x146"];
    
    self.headBgImageView = [[UIImageView alloc] init];
    self.headBgImageView.image = self.placeholderImage_headBgImage;
    [self addSubview:self.headBgImageView];
    [self.headBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(-(kScreen_Width - 146)/2.f);
        make.left.mas_equalTo(self.mas_left);
        make.width.mas_equalTo(kScreen_Width);
        make.height.mas_equalTo(kScreen_Width);
    }];
    
    UIView *contentBgView = [[UIView alloc] init];
    self.contentBgView = contentBgView;
    contentBgView.layer.cornerRadius = 18;
    contentBgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:contentBgView];
    [contentBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(131);
        make.left.mas_equalTo(self.headBgImageView.mas_left);
        make.right.mas_equalTo(self.headBgImageView.mas_right);
        make.width.mas_equalTo(kScreen_Width);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
    
    self.headImageView = [[UIImageView alloc] init];
    self.headImageView.userInteractionEnabled = YES;
    
    self.placeholderImage_headImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:kHeadImage_headled_cacheKey] ? [[SDImageCache sharedImageCache] imageFromCacheForKey:kHeadImage_headled_cacheKey] : [UIImage imageNamed:@"placeholder_head_78x78"];
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:UserCache.getUserInfo.avatarUrl] placeholderImage:self.placeholderImage_headImage];
    self.headImageView.layer.cornerRadius = 40;
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.layer.borderWidth = 2;
    self.headImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    [contentBgView addSubview:self.headImageView];
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(contentBgView.mas_top);
        make.size.mas_equalTo(CGSizeMake(80, 80));
    }];
    
    self.headImageControl = [[UIControl alloc] init];
    [self.headImageControl addTarget:self action:@selector(headImageControlAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.headImageControl];
    [self.headImageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(contentBgView.mas_top);
        make.size.mas_equalTo(CGSizeMake(80, 80));
    }];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.text = UserCache.getUserInfo.name;
    self.nameLabel.font = [UIFont systemFontOfSize:22];
    self.nameLabel.textColor = [UIColor blackColor];
    [contentBgView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headImageView.mas_bottom).offset(5);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    self.signLabel = [[UILabel alloc] init];
    if (UserCache.getUserInfo.headline.length > 0) {
        self.signLabel.text = UserCache.getUserInfo.headline;
    } else {
        self.signLabel.text = @"添加签名，让大家更好的认识你。";
    }
    self.signLabel.font = [UIFont systemFontOfSize:14];
    self.signLabel.textColor = UIColorFromHEX(0x999999);
    [contentBgView addSubview:self.signLabel];
    [self.signLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(8);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    self.homePageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.homePageButton setTitle:@"个人主页" forState:UIControlStateNormal];
    [self.homePageButton setTitleColor:UIColorFromHEX(0x999999) forState:UIControlStateNormal];
    self.homePageButton.layer.cornerRadius = 15;
    self.homePageButton.layer.borderColor = UIColorFromHEX(0x999999).CGColor;
    self.homePageButton.layer.borderWidth = 1;
    self.homePageButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.homePageButton addTarget:self action:@selector(homePageButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [contentBgView addSubview:self.homePageButton];
    [self.homePageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(13);
        make.size.mas_equalTo(CGSizeMake(90, 30));
        make.centerY.mas_equalTo(self.nameLabel.mas_centerY);
    }];
    
    CGFloat width_btn = 18 + 5 + 25;
    CGFloat width_gap_btn = (kScreen_Width - width_btn*3) / 4;
    
    UIView *agreeTitleBgView = [[UIView alloc] init];
    [contentBgView addSubview:agreeTitleBgView];
    [agreeTitleBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(width_gap_btn);
        make.size.mas_equalTo(CGSizeMake(width_btn, 17));
        make.top.mas_equalTo(self.signLabel.mas_bottom).offset(47);
    }];
    
    UIImageView *agreeTitleImageView = [[UIImageView alloc] init];
    agreeTitleImageView.image = [UIImage imageNamed:@"tool_like_flag"];
    [agreeTitleBgView addSubview:agreeTitleImageView];
    [agreeTitleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(agreeTitleBgView.mas_left);
        make.centerY.mas_equalTo(agreeTitleBgView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(18, 18));
    }];
    
    self.agreeTitleLabel = [[UILabel alloc] init];
    self.agreeTitleLabel.text = @"靠谱";
    self.agreeTitleLabel.textColor = UIColorFromHEX(0x333333);
    self.agreeTitleLabel.font = [UIFont systemFontOfSize:12];
    [agreeTitleBgView addSubview:self.agreeTitleLabel];
    [self.agreeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(agreeTitleImageView.mas_right).offset(5);
        make.size.mas_equalTo(CGSizeMake(25, 17));
        make.centerY.mas_equalTo(agreeTitleBgView.mas_centerY);
    }];
    
    self.agreeAccountLabel = [[UILabel alloc] init];
    self.agreeAccountLabel.text = [NSString stringWithFormat:@"%@", [self numberTransforByIntNumber:UserCache.getUserInfo.likeCount]];
    self.agreeAccountLabel.textColor = UIColorFromHEX(0x000000);
    self.agreeAccountLabel.font = [UIFont boldSystemFontOfSize:18];
    [contentBgView addSubview:self.agreeAccountLabel];
    [self.agreeAccountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(agreeTitleBgView.mas_centerX);
        make.bottom.mas_equalTo(self.agreeTitleLabel.mas_top).offset(-2);
    }];
    
    self.agreeControl = [[UIControl alloc] init];
    [self.agreeControl addTarget:self action:@selector(agreeControlAction) forControlEvents:UIControlEventTouchUpInside];
    [contentBgView addSubview:self.agreeControl];
    [self.agreeControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.agreeAccountLabel.mas_top);
        make.left.mas_equalTo(agreeTitleBgView.mas_left);
        make.right.mas_equalTo(agreeTitleBgView.mas_right);
        make.bottom.mas_equalTo(agreeTitleBgView.mas_bottom);
    }];
    
    self.fansTitleLabel = [[UILabel alloc] init];
    self.fansTitleLabel.text = @"粉丝";
    self.fansTitleLabel.textColor = UIColorFromHEX(0x333333);
    self.fansTitleLabel.font = [UIFont systemFontOfSize:12];
    self.fansTitleLabel.textAlignment = NSTextAlignmentCenter;
    [contentBgView addSubview:self.fansTitleLabel];
    [self.fansTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.agreeTitleLabel.mas_right).offset(width_gap_btn);
        make.size.mas_equalTo(CGSizeMake(width_btn, 17));
        make.top.mas_equalTo(self.signLabel.mas_bottom).offset(47);
    }];
    
    self.fansAccountLabel = [[UILabel alloc] init];
    self.fansAccountLabel.text = [NSString stringWithFormat:@"%@", [self numberTransforByIntNumber:UserCache.getUserInfo.followerCount]];
    self.fansAccountLabel.textColor = UIColorFromHEX(0x000000);
    self.fansAccountLabel.font = [UIFont boldSystemFontOfSize:18];
    [contentBgView addSubview:self.fansAccountLabel];
    [self.fansAccountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.fansTitleLabel.mas_centerX);
        make.bottom.mas_equalTo(self.fansTitleLabel.mas_top).offset(-2);
    }];
    
    self.fansControl = [[UIControl alloc] init];
    [self.fansControl addTarget:self action:@selector(fansControlAction) forControlEvents:UIControlEventTouchUpInside];
    [contentBgView addSubview:self.fansControl];
    [self.fansControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.fansAccountLabel.mas_top);
        make.left.mas_equalTo(self.fansTitleLabel.mas_left);
        make.right.mas_equalTo(self.fansTitleLabel.mas_right);
        make.bottom.mas_equalTo(self.fansTitleLabel.mas_bottom);
    }];
    
    self.careTitleLabel = [[UILabel alloc] init];
    self.careTitleLabel.text = @"关注";
    self.careTitleLabel.textColor = UIColorFromHEX(0x333333);
    self.careTitleLabel.font = [UIFont systemFontOfSize:12];
    self.careTitleLabel.textAlignment = NSTextAlignmentCenter;
    [contentBgView addSubview:self.careTitleLabel];
    [self.careTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.fansTitleLabel.mas_right).offset(width_gap_btn);
        make.size.mas_equalTo(CGSizeMake(width_btn, 17));
        make.top.mas_equalTo(self.signLabel.mas_bottom).offset(47);
    }];
    
    self.careAccountLabel = [[UILabel alloc] init];
    self.careAccountLabel.text = [NSString stringWithFormat:@"%@", [self numberTransforByIntNumber:UserCache.getUserInfo.followingUserCount]];
    self.careAccountLabel.textColor = UIColorFromHEX(0x000000);
    self.careAccountLabel.font = [UIFont boldSystemFontOfSize:18];
    [contentBgView addSubview:self.careAccountLabel];
    [self.careAccountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.careTitleLabel.mas_centerX);
        make.bottom.mas_equalTo(self.careTitleLabel.mas_top).offset(-2);
    }];
    
    self.careControl = [[UIControl alloc] init];
    [self.careControl addTarget:self action:@selector(careControlAction) forControlEvents:UIControlEventTouchUpInside];
    [contentBgView addSubview:self.careControl];
    [self.careControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.careAccountLabel.mas_top);
        make.left.mas_equalTo(self.careTitleLabel.mas_left);
        make.right.mas_equalTo(self.careTitleLabel.mas_right);
        make.bottom.mas_equalTo(self.careTitleLabel.mas_bottom);
    }];
    
    UIView *displayBtnView = [[UIView alloc] init];
    displayBtnView.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    displayBtnView.layer.cornerRadius = 6;
    displayBtnView.layer.shadowColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.2].CGColor;
    displayBtnView.layer.shadowOffset = CGSizeMake(0,0);
    displayBtnView.layer.shadowOpacity = 1;
    displayBtnView.layer.shadowRadius = 6;
    [contentBgView addSubview:displayBtnView];
    [displayBtnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.agreeTitleLabel.mas_bottom).offset(30);
        make.width.mas_equalTo(kScreen_Width - 40);
        make.left.mas_equalTo(self.mas_left).offset(20);
        make.height.mas_equalTo(80);
    }];
    
    CGFloat width_gap_displayBtn = (kScreen_Width - 40 - 58*3) / 4;
    
    self.mineTopicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.mineTopicButton setTitle:@"我想知道" forState:UIControlStateNormal];
    [self.mineTopicButton setTitleColor:UIColorFromHEX(0x333333) forState:UIControlStateNormal];
    [self.mineTopicButton setImage:[UIImage imageNamed:@"icon_wodehuati"] forState:UIControlStateNormal];
    [self.mineTopicButton ctfLayoutButtonWithEdgeInsetsStyle:CTFButtonEdgeInsetsType_ImageTop imageTitleSpace:5];
    self.mineTopicButton.titleLabel.font = [UIFont regularFontWithSize:14];
    [self.mineTopicButton setAdjustsImageWhenHighlighted:NO];
    [self.mineTopicButton addTarget:self action:@selector(mineTopicButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [displayBtnView addSubview:self.mineTopicButton];
    [self.mineTopicButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(displayBtnView.mas_left).offset(width_gap_displayBtn);
        make.width.mas_equalTo(58);
        make.centerY.mas_equalTo(displayBtnView.mas_centerY);
    }];
    
    self.careTopicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.careTopicButton setTitle:@"我关心的" forState:UIControlStateNormal];
    [self.careTopicButton setTitleColor:UIColorFromHEX(0x333333) forState:UIControlStateNormal];
    [self.careTopicButton setImage:[UIImage imageNamed:@"icon_guanxinhuati"] forState:UIControlStateNormal];
    [self.careTopicButton ctfLayoutButtonWithEdgeInsetsStyle:CTFButtonEdgeInsetsType_ImageTop imageTitleSpace:5];
    self.careTopicButton.titleLabel.font = [UIFont regularFontWithSize:14];
    [self.careTopicButton setAdjustsImageWhenHighlighted:NO];
    [self.careTopicButton addTarget:self action:@selector(careTopicButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [displayBtnView addSubview:self.careTopicButton];
    [self.careTopicButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mineTopicButton.mas_right).offset(width_gap_displayBtn);
        make.width.mas_equalTo(58);
        make.centerY.mas_equalTo(displayBtnView.mas_centerY);
    }];
    
    self.mineViewPointButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.mineViewPointButton setTitle:@"我的回答" forState:UIControlStateNormal];
    [self.mineViewPointButton setTitleColor:UIColorFromHEX(0x333333) forState:UIControlStateNormal];
    [self.mineViewPointButton setImage:[UIImage imageNamed:@"icon_wodegaundian"] forState:UIControlStateNormal];
    [self.mineViewPointButton ctfLayoutButtonWithEdgeInsetsStyle:CTFButtonEdgeInsetsType_ImageTop imageTitleSpace:5];
    self.mineViewPointButton.titleLabel.font = [UIFont regularFontWithSize:14];
    [self.mineViewPointButton setAdjustsImageWhenHighlighted:NO];
    [self.mineViewPointButton addTarget:self action:@selector(mineViewPointButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [displayBtnView addSubview:self.mineViewPointButton];
    [self.mineViewPointButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.careTopicButton.mas_right).offset(width_gap_displayBtn);
        make.width.mas_equalTo(58);
        make.centerY.mas_equalTo(displayBtnView.mas_centerY);
    }];
}

#pragma mark - 辅助方法
- (NSString *)numberTransforByIntNumber:(NSInteger)intNumber {
    
    NSString *transforString = @"";
    if (intNumber < 999) {
        transforString = [NSString stringWithFormat:@"%ld", intNumber];
        return transforString;
    } else {
        CGFloat floatNumber = intNumber / 1000.f;
        if (intNumber % 1000 < 100) {
            transforString = [NSString stringWithFormat:@"%0.0lfK", floatNumber];
        } else {
            transforString = [NSString stringWithFormat:@"%0.1lfK", floatNumber];
        }
        return transforString;
    }
}

- (void)headImageControlAction {
    CTFMineVC *vc = (CTFMineVC *)self.findViewController;
    [vc headImageControlAction];
}

- (void)homePageButtonAction {
    CTFMineVC *vc = (CTFMineVC *)self.findViewController;
    [vc homePageButtonAction];
}

- (void)agreeControlAction {
    CTFMineVC *vc = (CTFMineVC *)self.findViewController;
    [vc agreeControlAction];
}

- (void)fansControlAction {
    CTFMineVC *vc = (CTFMineVC *)self.findViewController;
    [vc fansControlAction];
}

- (void)careControlAction {
    CTFMineVC *vc = (CTFMineVC *)self.findViewController;
    [vc careControlAction];
}

- (void)mineTopicButtonAction {
    CTFMineVC *vc = (CTFMineVC *)self.findViewController;
    [vc mineTopicButtonAction];
}

- (void)careTopicButtonAction {
    CTFMineVC *vc = (CTFMineVC *)self.findViewController;
    [vc careTopicButtonAction];
}

- (void)mineViewPointButtonAction {
    CTFMineVC *vc = (CTFMineVC *)self.findViewController;
    [vc mineViewPointButtonAction];
}

@end
