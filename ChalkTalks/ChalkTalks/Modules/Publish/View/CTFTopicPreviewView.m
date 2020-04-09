//
//  CTFTopicPreviewView.m
//  ChalkTalks
//
//  Created by vision on 2020/2/6.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFTopicPreviewView.h"
#import "CTFPhotosColletionView.h"
#import "CTFNewCareEventView.h"
#import "CTFCommonManager.h"
#import "NSString+Size.h"
#import "CTFBlockButton.h"

@interface CTFTopicPreviewView ()

@property (nonatomic,strong) UIView        *maskView;
@property (nonatomic,strong) UIButton      *titleBtn;
@property (nonatomic,strong) UIButton      *backBtn; //返回
@property (nonatomic,strong) UIScrollView  *rootView;  //背景
@property (nonatomic,strong) UIImageView   *headImgView; //头像
@property (nonatomic,strong) UILabel       *nameLabel; //昵称
@property (nonatomic,strong) UILabel       *signLabel; //签名
@property (nonatomic,strong) UIImageView   *typeImgView;
@property (nonatomic,strong) UILabel       *topicTitleLabel; //标题
@property (nonatomic,strong) UILabel       *topicContentLabel; //话题描述
@property (nonatomic,strong) UIButton      *allBtn; //展开
@property (nonatomic,strong) CTFPhotosColletionView  *photosCollectionView; //图片
@property (nonatomic,strong) CTFNewCareEventView  *careEventView; //关心、踩它
@property (nonatomic,strong) UIButton      *submitBtn;  //确认发布

@property (nonatomic,strong) CTFQuestionsModel  *model;

@end

@implementation CTFTopicPreviewView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (self.model.images.count>0) {
        self.titleBtn.frame = CGRectMake(20, kNavBar_Height+36, 95, 30);
        self.backBtn.frame = CGRectMake(kScreen_Width-105, kNavBar_Height+36, 85, 33);
    }else{
        self.titleBtn.frame = CGRectMake(20, kNavBar_Height+162, 95, 30);
        self.backBtn.frame = CGRectMake(kScreen_Width-105, kNavBar_Height+162, 85, 33);
    }
    
    self.headImgView.frame = CGRectMake(11, 15, 28, 28);
    [self.headImgView setBorderWithCornerRadius:14 type:UIViewCornerTypeAll];
    self.nameLabel.frame = CGRectMake(self.headImgView.right+5, 15, 160, 16);
    self.signLabel.frame = CGRectMake(self.headImgView.right+5, self.nameLabel.bottom, kScreen_Width-self.headImgView.right-35, 14);
    
    NSString *title = [self.model.type isEqualToString:@"demand"]?[NSString stringWithFormat:@"%@%@",self.model.title,self.model.suffix]:[NSString stringWithFormat:@"%@%@",self.model.suffix,self.model.title];
    CGFloat titleH = [title boundingRectWithSize:CGSizeMake(kScreen_Width-66, CGFLOAT_MAX) withTextFont:self.topicTitleLabel.font].height;
    self.topicTitleLabel.frame = CGRectMake(11, self.headImgView.bottom+8, kScreen_Width-66, titleH);
    self.typeImgView.frame = CGRectMake(11, self.topicTitleLabel.bottom+5, 56, 20);
    
    CGFloat topicContentY;
    if (!kIsEmptyString(self.model.content)) {
        CGFloat allContentH = [self.model.content ctTextSizeWithFont:[UIFont regularFontWithSize:16] numberOfLines:0 lineSpacing:4 constrainedWidth:kScreen_Width-66].height;
        CGFloat contentH = [self.model.content ctTextSizeWithFont:[UIFont regularFontWithSize:16] numberOfLines:2 lineSpacing:4 constrainedWidth:kScreen_Width-66].height;
        if (allContentH>contentH) { //超过两行
            self.topicContentLabel.frame = CGRectMake(11, self.typeImgView.bottom+8, kScreen_Width-66, contentH);
            self.allBtn.hidden = NO;
            self.allBtn.frame = CGRectMake((kScreen_Width-45-60)/2.0, self.topicContentLabel.bottom+10, 60, 16);
            topicContentY = self.allBtn.bottom;
        }else{
            self.topicContentLabel.frame = CGRectMake(11, self.typeImgView.bottom+8, kScreen_Width-66, allContentH);
            self.allBtn.hidden = YES;
            topicContentY = self.topicContentLabel.bottom;
        }
    }else{
        self.topicContentLabel.frame = CGRectZero;
        topicContentY = self.typeImgView.bottom;
    }
    
    CGFloat imgY;
    if (self.model.images.count>0) {
        FeedImageSize imgsSize =  [AppMargin feedImageDimensions:self.model.images viewWidith:kScreen_Width-66];
        self.photosCollectionView.frame = CGRectMake(11,topicContentY+8, imgsSize.imgContainerWidth, imgsSize.imgContainerHeight);
        imgY = self.photosCollectionView.bottom+10;
    }else{
        self.photosCollectionView.frame = CGRectZero;
        imgY = topicContentY+10;
    }
    self.careEventView.frame = CGRectMake((kScreen_Width-45-220)/2.0, imgY+6, 220, 54);
    
    CGFloat maxHeight = (kScreen_Width-45)*(4.0/3.0);
    CGFloat rootHeight = self.careEventView.bottom+8;
    if (rootHeight>maxHeight) {
        self.rootView.frame = CGRectMake(20, self.backBtn.bottom+7, kScreen_Width-45, maxHeight);
        self.rootView.contentSize = CGSizeMake(kScreen_Width-45, rootHeight);
    }else{
       self.rootView.frame = CGRectMake(20, self.backBtn.bottom+7, kScreen_Width-45, rootHeight);
    }
}

#pragma mark -- Event response
#pragma mark 返回修改
- (void)backForChangeAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(topicPreviewViewDidBackAction)]) {
        [self.delegate topicPreviewViewDidBackAction];
    }
}

#pragma mark 确认发布
- (void)confirmSubmitAction:(UIButton *)sender{
    self.submitBtn.enabled = NO;
    if ([self.delegate respondsToSelector:@selector(topicPreviewViewSubmitTopic)]) {
        [self.delegate topicPreviewViewSubmitTopic];
    }
}

#pragma mark -- Public msthods
#pragma mark 填充数据
- (void)fillTopicData:(CTFQuestionsModel *)question{
    self.model = question;
    
    self.typeImgView.image = [self.model.type isEqualToString:@"demand"]?ImageNamed(@"home_topic_demand"):ImageNamed(@"home_topic_recommend");
    self.topicTitleLabel.attributedText = [CTFCommonManager setTopicTitleWithType:self.model.type shortTitle:self.model.title suffix:self.model.suffix];
    
    if ([self.model.type isEqualToString:@"recommend"]) {
        [self.submitBtn setBackgroundImage:[UIImage ctRoundRectImageWithFillColor:UIColorFromHEX(0xFFC028) cornerRadius:4] forState:UIControlStateNormal];
        [self.submitBtn setBackgroundImage:[UIImage ctRoundRectImageWithFillColor:UIColorFromHEX(0xFFD268) cornerRadius:4] forState:UIControlStateDisabled];
        [self.submitBtn setBackgroundImage:[UIImage ctRoundRectImageWithFillColor:UIColorFromHEX(0xFFD268) cornerRadius:4] forState:UIControlStateHighlighted];
    } else {
        [self.submitBtn setBackgroundImage:[UIImage ctRoundRectImageWithFillColor:UIColorFromHEX(0xFF6885) cornerRadius:4] forState:UIControlStateNormal];
        [self.submitBtn setBackgroundImage:[UIImage ctRoundRectImageWithFillColor:UIColorFromHEX(0xFF95A9) cornerRadius:4] forState:UIControlStateDisabled];
        [self.submitBtn setBackgroundImage:[UIImage ctRoundRectImageWithFillColor:UIColorFromHEX(0xFF95A9) cornerRadius:4] forState:UIControlStateHighlighted];
    }
    
    if (!kIsEmptyString(question.content)) {
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:question.content];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.lineSpacing = 4;
        [attributeStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, question.content.length)];
        self.topicContentLabel.attributedText = attributeStr;
    }
    [self.photosCollectionView fillImagesData:question.images status:@"normal"];
    [self.careEventView fillCareEventWithModel:question indexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

#pragma mark -- Private methods
- (void)setupUI{
    [self addSubview:self.maskView];
    [self addSubview:self.titleBtn];
    [self addSubview:self.backBtn];
    [self addSubview:self.rootView];
    [self.rootView addSubview:self.headImgView];
    [self.rootView addSubview:self.nameLabel];
    [self.rootView addSubview:self.signLabel];
    [self.rootView addSubview:self.topicTitleLabel];
    [self.rootView addSubview:self.typeImgView];
    [self.rootView addSubview:self.topicContentLabel];
    [self.rootView addSubview:self.allBtn];
    self.allBtn.hidden = YES;
    [self.rootView addSubview:self.photosCollectionView];
    [self.rootView addSubview:self.careEventView];
    [self addSubview:self.submitBtn];
}

#pragma mark -- Getters
#pragma mark 蒙层
- (UIView *)maskView{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
        _maskView.backgroundColor = UIColorFromHEXWithAlpha(0x000000, 0.7);
    }
    return _maskView;
}

#pragma mark 标题
- (UIButton *)titleBtn{
    if (!_titleBtn) {
        _titleBtn = [[UIButton alloc] init];
        [_titleBtn setImage:ImageNamed(@"publish_preview_title") forState:UIControlStateNormal];
        [_titleBtn setTitle:@"预览效果" forState:UIControlStateNormal];
        _titleBtn.titleLabel.font = [UIFont regularFontWithSize:16.0f];
        _titleBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        [_titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _titleBtn;
}

#pragma mark 返回
- (UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] init];
        [_backBtn setImage:ImageNamed(@"publish_preview_back") forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backForChangeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

#pragma mark 背景
- (UIScrollView *)rootView{
    if (!_rootView) {
        _rootView = [[UIScrollView alloc] init];
        _rootView.backgroundColor = [UIColor whiteColor];
        _rootView.layer.cornerRadius = 10;
        _rootView.showsVerticalScrollIndicator = NO;
    }
    return _rootView;
}

#pragma mark 头像
- (UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] init];
        [_headImgView sd_setImageWithURL:[NSURL URLWithString:UserCache.getUserInfo.avatarUrl] placeholderImage:[UIImage ctUserPlaceholderImage]];
    }
    return _headImgView;
}

#pragma mark 昵称
- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont mediumFontWithSize:12];
        _nameLabel.textColor = [UIColor ctColor33];
        _nameLabel.text = UserCache.getUserInfo.name;
    }
    return _nameLabel;
}

#pragma mark 签名
- (UILabel *)signLabel{
    if (!_signLabel) {
        _signLabel = [[UILabel alloc] init];
        _signLabel.font = [UIFont regularFontWithSize:10];
        _signLabel.textColor = [UIColor ctColorC2];
        _signLabel.text = kIsEmptyString(UserCache.getUserInfo.headline)?@"还没有签名":UserCache.getUserInfo.headline;
    }
    return _signLabel;
}

#pragma mark 话题标题
- (UILabel *)topicTitleLabel{
    if (!_topicTitleLabel) {
        _topicTitleLabel = [[UILabel alloc] init];
        _topicTitleLabel.font = [UIFont mediumFontWithSize:18];
        _topicTitleLabel.textColor = [UIColor ctColor33];
        _topicTitleLabel.numberOfLines = 0;
    }
    return _topicTitleLabel;
}

#pragma mark 类型
- (UIImageView *)typeImgView{
    if (!_typeImgView) {
        _typeImgView = [[UIImageView alloc] init];
    }
    return _typeImgView;
}

#pragma mark 话题描述
- (UILabel *)topicContentLabel{
    if (!_topicContentLabel) {
        _topicContentLabel = [[UILabel alloc] init];
        _topicContentLabel.font = [UIFont regularFontWithSize:16];
        _topicContentLabel.textColor = [UIColor ctColor33];
        _topicContentLabel.numberOfLines = 0;
    }
    return _topicContentLabel;
}

#pragma mark 全文
- (UIButton *)allBtn{
    if (!_allBtn) {
        _allBtn = [[UIButton alloc] init];
        _allBtn.titleLabel.font = [UIFont ctfFeedNickFont];
        [_allBtn setTitleColor:[UIColor ctColor80] forState:UIControlStateNormal];
        [_allBtn setTitle:@"展开" forState:UIControlStateNormal];
        [_allBtn setImage:ImageNamed(@"topic_details_expand") forState:UIControlStateNormal];
        [_allBtn ctfLayoutButtonWithEdgeInsetsStyle:CTFButtonEdgeInsetsType_ImageRight imageTitleSpace:4];
        [_allBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    }
    return _allBtn;
}

#pragma mark 图片
- (CTFPhotosColletionView *)photosCollectionView{
    if (!_photosCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        _photosCollectionView = [[CTFPhotosColletionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _photosCollectionView.isLocal = YES;
    }
    return _photosCollectionView;
}

#pragma mark 关心、踩
- (CTFNewCareEventView *)careEventView{
    if (!_careEventView) {
        _careEventView = [[CTFNewCareEventView alloc] initWithFrame:CGRectZero];
        _careEventView.btnDisabled = YES;
    }
    return _careEventView;
}

#pragma mark 发布
- (UIButton *)submitBtn{
    if (!_submitBtn) {
        _submitBtn = [[UIButton alloc] initWithFrame:CGRectMake(17, kScreen_Height-kTabBar_Height-12, kScreen_Width-34, 48)];
        [_submitBtn setTitle:@"确认发布" forState:UIControlStateNormal];
        [_submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _submitBtn.titleLabel.font = [UIFont mediumFontWithSize:16.0f];
        [_submitBtn addTarget:self action:@selector(confirmSubmitAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitBtn;
}

@end
