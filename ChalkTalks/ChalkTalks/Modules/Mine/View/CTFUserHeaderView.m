//
//  CTFUserHeaderView.m
//  ChalkTalks
//
//  Created by vision on 2019/12/26.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFUserHeaderView.h"
#import "UIView+Frame.h"
#import "CTFCommonManager.h"
#import "YBImageBrowser.h"
#import "NSURL+Ext.h"
#import "CTFLearningGuideView.h"
#import "CTFSignContentSettingVC.h"

@interface CTFUserHeaderView ()

@property (nonatomic,strong) UIView       *rootView;
@property (nonatomic,strong) UIImageView  *headImgView;
@property (nonatomic,strong) UIImageView  *sexImgView;     //性别
@property (nonatomic,strong) UIButton     *setupBtn;       //个人设置
@property (nonatomic,strong) UIButton     *attentionBtn;   //关注
@property (nonatomic,strong) UILabel      *nameLab;
@property (nonatomic,strong) UILabel      *signatureLab;   //签名
@property (nonatomic, strong) UIView      *badgeWallView;
@property (nonatomic,strong) UILabel      *likeCountLab;   //靠谱数
@property (nonatomic,strong) UIButton     *likeTitleBtn;
@property (nonatomic,strong) UILabel      *fansCountLab;   //粉丝数
@property (nonatomic,strong) UILabel      *fansTitleLab;
@property (nonatomic,strong) UILabel      *attentionCountLab;   //关注数
@property (nonatomic,strong) UILabel      *attentionTitleLab;
@property (nonatomic,strong) UIView       *lineView;

@property (nonatomic, assign) BOOL        isMine;

@property (nonatomic, strong) NSMutableArray<UIImageView *> *badgesImageViewArray;

@property (nonatomic, strong) CTFLearningGuideView *learningGuideView;

@end

@implementation CTFUserHeaderView

-(instancetype)initWithFrame:(CGRect)frame isMine:(BOOL)isMine{
    self = [super initWithFrame:frame];
    if (self) {
        self.isMine = isMine;
        
        [self addSubview:self.rootView];
        [self addSubview:self.headImgView];
        [self addSubview:self.sexImgView];
        if (isMine) {
            [self addSubview:self.setupBtn];
        }else{
            [self addSubview:self.attentionBtn];
        }
        [self addSubview:self.nameLab];
        [self addSubview:self.signatureLab];
        [self addSubview:self.badgeWallView];
        [self addSubview:self.likeCountLab];
        [self addSubview:self.fansCountLab];
        [self addSubview:self.attentionCountLab];
        [self addSubview:self.likeTitleBtn];
        [self addSubview:self.fansTitleLab];
        [self addSubview:self.attentionTitleLab];
        [self addSubview:self.lineView];
        [self setupSkeletonableView];
    }
    return self;
}

- (void)setupSkeletonableView {
    [self.rootView ctf_skeletonable:YES];
    [self.headImgView ctf_skeletonable:YES];
    [self.nameLab ctf_skeletonable:YES];
    [self.signatureLab ctf_skeletonable:YES];
    [self.likeCountLab ctf_skeletonable:YES];
    [self.fansCountLab ctf_skeletonable:YES];
    [self.attentionCountLab ctf_skeletonable:YES];
    
}

#pragma mark -- Event response
#pragma mark 个人设置
-(void)personalInstallAction:(UIButton *)sender{
    if ([self.viewDelegate respondsToSelector:@selector(userHeaderViewDidPushToUserSet:)]) {
        [self.viewDelegate userHeaderViewDidPushToUserSet:self];
    }
}

#pragma mark 关注
-(void)followAction:(UIButton *)sender{
    if ([sender.titleLabel.text isEqualToString:@"互相关注"] || [sender.titleLabel.text isEqualToString:@"已关注"]) {
        // TO DO : 取消关注
        if ([self.viewDelegate respondsToSelector:@selector(userHeaderViewDidFollow:needFollow:)]) {
            [self.viewDelegate userHeaderViewDidFollow:self needFollow:NO];
        }
    } else {
        // TO DO : 关注
        if ([self.viewDelegate respondsToSelector:@selector(userHeaderViewDidFollow:needFollow:)]) {
            [self.viewDelegate userHeaderViewDidFollow:self needFollow:YES];
        }
    }
    [self removeHomePageLearningGuide];
}

#pragma mark 靠谱、粉丝、关注
-(void)userSetAction:(id)sender{
    NSInteger tag;
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)sender;
        tag = btn.tag;
    }else{
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
        tag = tap.view.tag;
    }
    if ([self.viewDelegate respondsToSelector:@selector(userHeaderView:setActionWithTag:)]) {
        [self.viewDelegate userHeaderView:self setActionWithTag:tag];
    }
}

#pragma mark 头像放大
-(void)showFullHeadPicAction{
    YBIBImageData *data = [YBIBImageData new];
    if (!kIsEmptyString(self.userDetails.avatarUrl)) {
        data.imageURL = [NSURL safe_URLWithString:self.userDetails.avatarUrl];
    }else {
        data.imageName = @"placeholder_headView_375x375";
    }
    data.allowSaveToPhotoAlbum = YES;
    
    YBImageBrowser *browser = [YBImageBrowser new];
    browser.dataSourceArray = @[data];
    browser.currentPage = 0;
    [browser show];
}

#pragma mark -- Setters
#pragma mark    用户信息填充
-(void)setUserDetails:(UserModel *)userDetails{
    _userDetails = userDetails;
    
    [self.headImgView sd_setImageWithURL:[NSURL URLWithString:userDetails.avatarUrl] placeholderImage:ImageNamed(@"placeholder_head_78x78")];
    
    //性别
    if ([userDetails.gender isEqualToString:@"unknown"]) {
        self.sexImgView.hidden = YES;
    }else{
        self.sexImgView.hidden = NO;
        if ([userDetails.gender isEqualToString:@"male"]) {
            self.sexImgView.image = ImageNamed(@"icon_gender_male");
        }else{
            self.sexImgView.image = ImageNamed(@"icon_gender_female");
        }
    }
    
    [self.setupBtn removeFromSuperview];
    [self.attentionBtn removeFromSuperview];
    if ([UserCache getUserInfo].userId != userDetails.userId) {// 其他人的个人主页
        [self addSubview:self.attentionBtn];
        if (userDetails.isFollowing && userDetails.isMyFollower) {
            [self.attentionBtn setTitle:@"互相关注" forState:UIControlStateNormal];
            [self.attentionBtn setTitleColor:UIColorFromHEX(0x999999) forState:UIControlStateNormal];
            [self.attentionBtn setTitleColor:UIColorFromHEX(0x999999) forState:UIControlStateHighlighted];
            [self.attentionBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            [self.attentionBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
            self.attentionBtn.layer.backgroundColor = UIColorFromHEX(0xEEEEEE).CGColor;
            self.attentionBtn.layer.cornerRadius = 16;
            self.attentionBtn.layer.masksToBounds = YES;
        }
        if (userDetails.isFollowing && !userDetails.isMyFollower) {
            [self.attentionBtn setTitle:@"已关注" forState:UIControlStateNormal];
            [self.attentionBtn setTitleColor:UIColorFromHEX(0x999999) forState:UIControlStateNormal];
            [self.attentionBtn setTitleColor:UIColorFromHEX(0x999999) forState:UIControlStateHighlighted];
            [self.attentionBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            [self.attentionBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
            self.attentionBtn.layer.backgroundColor = UIColorFromHEX(0xEEEEEE).CGColor;
            self.attentionBtn.layer.cornerRadius = 16;
            self.attentionBtn.layer.masksToBounds = YES;
        }
        if (!userDetails.isFollowing) {
            [self.attentionBtn setTitle:@"+ 关注" forState:UIControlStateNormal];
            [self.attentionBtn setTitleColor:UIColorFromHEX(0x333333) forState:UIControlStateNormal];
            [self.attentionBtn setTitleColor:UIColorFromHEXWithAlpha(0x666666, 0.5) forState:UIControlStateHighlighted];
            [self.attentionBtn setBackgroundImage:[[UIImage imageNamed:@"bg_btn_normal_83x32"] ctfResizingImageState] forState:UIControlStateNormal];
            [self.attentionBtn setBackgroundImage:[[UIImage imageNamed:@"bg_btn_hightlighted_83x32"] ctfResizingImageState] forState:UIControlStateHighlighted];
            self.attentionBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
            self.attentionBtn.layer.cornerRadius = 0;
            self.attentionBtn.layer.masksToBounds = YES;
        }
    } else {
        [self addSubview:self.setupBtn];
    }
    self.nameLab.text = userDetails.name;
    if (kIsEmptyString(userDetails.headline)) {
        if (self.isMine) {
            self.signatureLab.text =@"添加签名，让大家更好的认识你。";
        }else{
            self.signatureLab.text =@"还没有签名...";
        }
    }else{
       self.signatureLab.text = userDetails.headline;
    }
    
    self.likeCountLab.text = [CTFCommonManager numberTransforByCount:userDetails.likeCount];
    self.fansCountLab.text = [CTFCommonManager numberTransforByCount:userDetails.followerCount];
    self.attentionCountLab.text = [CTFCommonManager numberTransforByCount:userDetails.followingUserCount];
    
    [self addsubviewHomePageLearningGuide];
}

- (NSArray<NSString *> *)queryDefaultBadgeImageNames {
    return @[@"icon_badge_20",
             @"icon_badge_50",
             @"icon_badge_40",
             @"icon_badge_30",
             @"icon_badge_10"];
}

- (NSArray<UIImage *> *)queryCurrentBadgeImageNamesBy:(NSArray<CTFBadgeModel *> *)badgesArray {
    NSArray *localCodeSet = @[@(2), @(5), @(4), @(3), @(1)];
    NSMutableArray<UIImage *> *temp_badgeImages = [NSMutableArray array];
    for (CTFBadgeModel *badgeModel in badgesArray) {
        NSString *imageName = [NSString stringWithFormat:@"icon_badge_%ld%ld",[[localCodeSet safe_objectAtIndex:badgeModel.code-1] integerValue], badgeModel.currentWinLevel];
        UIImage *image = [UIImage imageNamed:imageName];
        if (image == nil) {
            image = [UIImage imageNamed:[NSString stringWithFormat:@"icon_badge_%ld0",[[localCodeSet safe_objectAtIndex:badgeModel.code-1] integerValue]]];
        }
        [temp_badgeImages addObject:image];
    }
    return temp_badgeImages;
}

- (void)updateBadgesWall:(NSArray<CTFBadgeModel *> *)badgesArray {
    NSArray<UIImage *> *badgeImages = [self queryCurrentBadgeImageNamesBy:badgesArray];
    for (int i = 0; i < self.badgesImageViewArray.count; i++) {
        UIImage *image = [badgeImages objectAtIndex:i];
        UIImageView *imageView = [self.badgesImageViewArray safe_objectAtIndex:i];
        [imageView setImage:image];
        [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(image.size.width, image.size.height));
        }];
    }
}

#pragma mark -- Getters
#pragma mark  白色背景
-(UIView *)rootView{
    if (!_rootView) {
        _rootView = [[UIView alloc] initWithFrame:CGRectMake(0, 136, kScreen_Width, 213)];
        _rootView.backgroundColor = [UIColor whiteColor];
        [_rootView setBorderWithCornerRadius:8 type:UIViewCornerTypeTop];
        
    }
    return _rootView;
}

#pragma mark 头像
-(UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(16, self.rootView.top-40, 80, 80)];
        [_headImgView setBorderWithCornerRadius:40 type:UIViewCornerTypeAll];
        _headImgView.layer.cornerRadius = 40;
        _headImgView.layer.masksToBounds = YES;
        _headImgView.layer.borderWidth = 0.5;
        _headImgView.layer.borderColor = UIColorFromHEX(0xEEEEEE).CGColor;
        [_headImgView addTapPressed:@selector(showFullHeadPicAction) target:self];
    }
    return _headImgView;
}

#pragma mark 性别
-(UIImageView *)sexImgView{
    if (!_sexImgView) {
        _sexImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.headImgView.right, self.rootView.top+5, 20, 20)];
    }
    return _sexImgView;
}

#pragma mark 个人设置
-(UIButton *)setupBtn{
    if (!_setupBtn) {
        _setupBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width-106, self.rootView.top+16, 88, 32)];
        [_setupBtn setTitle:@"个人设置" forState:UIControlStateNormal];
        [_setupBtn setTitleColor:[UIColor ctColor33] forState:UIControlStateNormal];
        _setupBtn.titleLabel.font = [UIFont regularFontWithSize:14];
        _setupBtn.layer.cornerRadius = 16;
        _setupBtn.layer.borderColor = [UIColor ctColor33].CGColor;
        _setupBtn.layer.borderWidth = 1.0;
        [_setupBtn addTarget:self action:@selector(personalInstallAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _setupBtn;
}

#pragma mark 关注
-(UIButton *)attentionBtn{
    if (!_attentionBtn) {
        _attentionBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width-98, self.rootView.top+16, 82, 32)];
        _attentionBtn.titleLabel.font = [UIFont regularFontWithSize:15];
        [_attentionBtn addTarget:self action:@selector(followAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _attentionBtn;
}

#pragma mark 用户名
-(UILabel *)nameLab{
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(16, self.headImgView.bottom+10, kScreen_Width-100, 30)];
        _nameLab.textColor = [UIColor blackColor];
        _nameLab.font = [UIFont mediumFontWithSize:22];
    }
    return _nameLab;
}

#pragma mark 签名
-(UILabel *)signatureLab{
    if (!_signatureLab) {
        _signatureLab = [[UILabel alloc] initWithFrame:CGRectMake(16, self.nameLab.bottom, kScreen_Width-32, 20)];
        _signatureLab.textColor = [UIColor ctColor99];
        _signatureLab.font = [UIFont regularFontWithSize:14];
        _signatureLab.numberOfLines = 0;
        [_signatureLab addTapPressed:@selector(showSignEdtingVC) target:self];
    }
    return _signatureLab;
}

#pragma mark 勋章墙
- (UIView *)badgeWallView {
    if (!_badgeWallView) {
        _badgeWallView = [[UIImageView alloc] initWithFrame:CGRectMake(16, self.signatureLab.bottom+8, 150, 25)];
        [_badgeWallView addTapPressed:@selector(jumpToBadgewallVC) target:self];
        for (int i = 0; i < 5; i++) {
            UIView *control = [[UIView alloc] init];
            [_badgeWallView addSubview:control];
            [control mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(30, 25));
                make.left.mas_equalTo(_badgeWallView.mas_left).offset(i*30);
                make.top.mas_equalTo(_badgeWallView.mas_top);
            }];
            
            UIImage *image = [UIImage imageNamed:[[self queryDefaultBadgeImageNames] objectAtIndex:i]];
            CGSize imageSize = image.size;
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.userInteractionEnabled = YES;
            [self.badgesImageViewArray addObject:imageView];
            [control addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.mas_equalTo(control);
                make.size.mas_equalTo(CGSizeMake(imageSize.width, imageSize.height));
            }];
        }
    }
    return _badgeWallView;
}

#pragma mark  靠谱数
-(UILabel *)likeCountLab{
    if (!_likeCountLab) {
        _likeCountLab = [[UILabel alloc] initWithFrame:CGRectMake(20, self.badgeWallView.bottom+16, 60, 26)];
        _likeCountLab.textColor = [UIColor blackColor];
        _likeCountLab.font = [UIFont mediumFontWithSize:18];
        _likeCountLab.tag = 100;
        [_likeCountLab addTapPressed:@selector(userSetAction:) target:self];
    }
    return _likeCountLab;
}

#pragma mark  粉丝数
-(UILabel *)fansCountLab{
    if (!_fansCountLab) {
        _fansCountLab = [[UILabel alloc] initWithFrame:CGRectMake(self.likeCountLab.right+10, self.badgeWallView.bottom+16, 60, 26)];
        _fansCountLab.textColor = [UIColor blackColor];
        _fansCountLab.font = [UIFont mediumFontWithSize:18];
        _fansCountLab.tag = 101;
        _fansCountLab.textAlignment = NSTextAlignmentCenter;
        [_fansCountLab addTapPressed:@selector(userSetAction:) target:self];
    }
    return _fansCountLab;
}

#pragma mark  关注数
-(UILabel *)attentionCountLab{
    if (!_attentionCountLab) {
        _attentionCountLab = [[UILabel alloc] initWithFrame:CGRectMake(self.fansCountLab.right+10, self.badgeWallView.bottom+16, 60, 26)];
        _attentionCountLab.textColor = [UIColor blackColor];
        _attentionCountLab.font = [UIFont mediumFontWithSize:18];
        _attentionCountLab.tag = 102;
        _attentionCountLab.textAlignment = NSTextAlignmentCenter;
        [_attentionCountLab addTapPressed:@selector(userSetAction:) target:self];
    }
    return _attentionCountLab;
}

#pragma mark 靠谱标题
-(UIButton *)likeTitleBtn{
    if (!_likeTitleBtn) {
        _likeTitleBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.likeCountLab.left-4, self.likeCountLab.bottom, 60, 20)];
        [_likeTitleBtn setImage:ImageNamed(@"tool_like_flag") forState:UIControlStateNormal];
        [_likeTitleBtn setTitle:@"靠谱" forState:UIControlStateNormal];
        [_likeTitleBtn setTitleColor:[UIColor ctColor99] forState:UIControlStateNormal];
        _likeTitleBtn.titleLabel.font = [UIFont regularFontWithSize:12];
        _likeTitleBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
        _likeTitleBtn.tag = 100;
        [_likeTitleBtn addTarget:self action:@selector(userSetAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeTitleBtn;
}

#pragma mark  粉丝数标题
-(UILabel *)fansTitleLab{
    if (!_fansTitleLab) {
        _fansTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(self.fansCountLab.left, self.fansCountLab.bottom, 60, 20)];
        _fansTitleLab.textColor = [UIColor ctColor99];
        _fansTitleLab.font = [UIFont regularFontWithSize:12];
        _fansTitleLab.text = @"粉丝";
        _fansTitleLab.tag = 101;
        _fansTitleLab.textAlignment = NSTextAlignmentCenter;
        [_fansTitleLab addTapPressed:@selector(userSetAction:) target:self];
    }
    return _fansTitleLab;
}

#pragma mark  关注数标题
-(UILabel *)attentionTitleLab{
    if (!_attentionTitleLab) {
        _attentionTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(self.attentionCountLab.left, self.attentionCountLab.bottom, 60, 20)];
        _attentionTitleLab.textColor = [UIColor ctColor99];
        _attentionTitleLab.font = [UIFont regularFontWithSize:12];
        _attentionTitleLab.text = @"关注";
        _attentionTitleLab.tag = 102;
        _attentionTitleLab.textAlignment = NSTextAlignmentCenter;
        [_attentionTitleLab addTapPressed:@selector(userSetAction:) target:self];
    }
    return _attentionTitleLab;
}

#pragma mark  线
-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0,self.likeTitleBtn.bottom+17, kScreen_Width, 1)];
        _lineView.backgroundColor = [UIColor ctColorEE];
    }
    return _lineView;
}

#pragma mark 徽章图片数组
- (NSMutableArray<UIImageView *> *)badgesImageViewArray {
    if (!_badgesImageViewArray) {
        _badgesImageViewArray = [NSMutableArray array];
    }
    return _badgesImageViewArray;
}

#pragma mark 跳转到徽章墙H5
- (void)jumpToBadgewallVC {
    NSString *userId = [NSString stringWithFormat:@"%ld", self.userDetails.userId];
    UIViewController *bvc = [[CTBadgeWebViewController alloc] initWithUserId: userId];
    [self.findViewController.navigationController pushViewController:bvc animated:YES];
}

#pragma mark 跳转到签名编辑界面
- (void)showSignEdtingVC {
    if ([UserCache getUserInfo].userId != self.userDetails.userId) return;
    CTFSignContentSettingVC *signContentSettingVC = [[CTFSignContentSettingVC alloc] init];
    signContentSettingVC.orignSignContentString = UserCache.getUserInfo.headline;
    [self.findViewController.navigationController pushViewController:signContentSettingVC animated:YES];
}

#pragma mark - 点亮更多徽章学习引导
- (void)addsubviewHomePageLearningGuide {
    if (![CTFSystemCache query_showedLearningGuideForFunctionView:CTFLearningGuideViewType_HomePage] && self.learningGuideView == nil && [UserCache getUserInfo].userId != self.userDetails.userId) {
        
        [self handleApplicationDidEnterBackground];
        
        [self layoutIfNeeded];
        CGRect hollowRect = [self convertRect:self.attentionBtn.frame toView:kAPPDELEGATE.window];

        CGRect imageRect = CGRectMake(hollowRect.origin.x+hollowRect.size.width-180, hollowRect.origin.y-49-4, 180, 49);
        
        CGRect frame = CGRectZero;
        if ([[UIApplication sharedApplication] statusBarFrame].size.height > 20) {
            frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height-20);
        } else {
            frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
        }
        
        @weakify(self);
        CTFLearningGuideView *learningGuideView = [[CTFLearningGuideView alloc] initWithFrame:frame alpha:0.f hollowFrame:hollowRect hollowCornerRadius:0 imageName:@"icon_care_learningGuide_180x49" imageFrame:imageRect clickSelfBlcok:^{
            @strongify(self);
            [self removeHomePageLearningGuide];
        }];
        learningGuideView.backgroundColor = UIColorFromHEXWithAlpha(0xb8467, 0.6);
        self.learningGuideView = learningGuideView;
        [kAPPDELEGATE.window addSubview:learningGuideView];
    }
}

- (void)removeHomePageLearningGuide {
    [self.learningGuideView removeFromSuperview];
    self.learningGuideView = nil;
    [CTFSystemCache revise_showedLearningGuide:YES ForFunctionView:CTFLearningGuideViewType_HomePage];
}

//
- (void)handleApplicationDidEnterBackground {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeHomePageLearningGuide) name:kApplicationWillTerminateNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
