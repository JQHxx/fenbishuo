//
//  CTFMyAnswerCell.m
//  ChalkTalks
//
//  Created by vision on 2020/1/2.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFMyAnswerCell.h"
#import "CTFPhotosColletionView.h"
#import "CTFAVVideoContainerView.h"
#import "CTFAnswerHandleView.h"
#import "CTFAudioFeedView.h"
#import "CTFMyAnswerCellLayout.h"
#import "CTFTopicAuthorView.h"
#import "CTFAnswerInfoView.h"
#import "CTFCommonManager.h"

@interface CTFMyAnswerCell ()

@property (nonatomic,strong) UILabel                 *myTitleLab;              //动态
@property (nonatomic,strong) UILabel                 *titleLab;                //话题标题
@property (nonatomic,strong) CTFTopicAuthorView      *authorView;              //话题发布者
@property (nonatomic,strong) CTFPhotosColletionView  *imgsCollectionView;      //图片展示
@property (nonatomic,strong) CTFAVVideoContainerView *videoContainerView;      //视频展示
@property (nonatomic,strong) CTFAudioFeedView        *audioView;
@property (nonatomic,strong) UILabel                 *descLab;                 //观点描述
@property (nonatomic,strong) CTBlurEffectView        *effectView;              //模糊
@property (nonatomic,strong) UILabel                 *statusLab;
@property (nonatomic,strong) CTFAnswerInfoView       *answerInfoView;          //回答发布者 阅读量
@property (nonatomic,strong) CTFAnswerHandleView     *handleView;             //更多、靠谱事件
@property (nonatomic,strong) UIView                  *lineView;

@property (nonatomic,  weak ) id<CTFMyAnswerCellDelegate>delegate;
@property (nonatomic,strong) CTFMyAnswerCellLayout   *cellLayout;

@end

@implementation CTFMyAnswerCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self =  [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initMyAnswerView];
    }
    return self;
}

#pragma mark 更新UI
-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.myTitleLab.frame = self.cellLayout.myTitleRect;
    self.titleLab.frame = self.cellLayout.titleRect;
    self.authorView.frame = self.cellLayout.authorRect;
    self.imgsCollectionView.frame = self.cellLayout.imgsRect;
    self.videoContainerView.frame = self.cellLayout.videoRect;
    self.audioView.frame = self.cellLayout.audioRect;
    self.descLab.frame = self.cellLayout.descRect;
    self.effectView.frame = self.cellLayout.descRect;
    self.statusLab.frame = self.cellLayout.statusRect;
    self.answerInfoView.frame = self.cellLayout.answerInfoRect;
    [self.answerInfoView setBorderWithCornerRadius:13 type:UIViewCornerTypeAll];
    self.handleView.frame = self.cellLayout.eventRect;
    self.lineView.frame = self.cellLayout.separationRect;
}

#pragma mark 填充数据
-(void)fillContentWithData:(id)obj{
    self.cellLayout = (CTFMyAnswerCellLayout *)obj;
    AnswerModel *answerModel = self.cellLayout.model;
    
    self.myTitleLab.text = answerModel.myTitle;
    if (answerModel.hideTitle) {
        self.titleLab.text = @"";
        self.authorView.hidden = YES;
        self.handleView.type = CTFAnswerHandleViewTypeHomepage;
    }else{
        self.authorView.hidden = NO;
        if (kIsEmptyString(answerModel.question.shortTitle)&&kIsEmptyString(answerModel.question.suffix)) {
            self.titleLab.text = answerModel.question.title;
        } else {
           self.titleLab.attributedText = [CTFCommonManager setTopicTitleWithType:answerModel.question.type shortTitle:answerModel.question.shortTitle suffix:answerModel.question.suffix];
        }
        AuthorModel *model = [AuthorModel yy_modelWithDictionary:answerModel.question.author];
        [self.authorView fillDataWithType:answerModel.question.type author:model];
        self.handleView.type = CTFAnswerHandleViewTypeMyAnswer;
    }
    //资源（图片或视频）
    if ([answerModel.type isEqualToString:@"images"]) {
        [self.imgsCollectionView fillImagesData:answerModel.images status:answerModel.status];
    }else if([answerModel.type isEqualToString:@"video"]){
        [self.videoContainerView fillContentWithData:answerModel];
    }else if ([answerModel.type isEqualToString:@"audioImage"]){
        [self.audioView fillAudioImageData:answerModel.audioImage indexPath:self.cardIndexPath currentIndex:answerModel.currentIndex status:answerModel.status];
    }
    //描述
    if (!kIsEmptyString(answerModel.content)) {
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:answerModel.content];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.lineSpacing = 4;
        [attributeStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, answerModel.content.length)];
        self.descLab.attributedText = attributeStr;
        
        if (answerModel.images.count  == 0 && [answerModel.type isEqualToString:@"images"]) {
            self.statusLab.hidden = NO;
        } else {
            self.statusLab.hidden = YES;
        }
    }
    
    if ([answerModel.status isEqualToString:@"reviewing"] && !kIsEmptyString(answerModel.content)) {
        self.effectView.hidden = NO;
        if ([UIDevice currentDevice].systemVersion.floatValue > 12.0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.effectView.blurLevel = 0.5;
            });
        }
    } else {
        self.effectView.hidden = YES;
    }
    if (answerModel.hideTitle) { //个人主页
        self.answerInfoView.clickDisable = answerModel.isAuthor; //自己点击不跳转
    }
    [self.answerInfoView fillDataWithAuthor:answerModel.author viewCount:answerModel.viewCount];
    [self.handleView fillAnswerData:answerModel indexPath:self.cardIndexPath];
}

#pragma mark 设置代理
-(void)setDelegate:(id<CTFMyAnswerCellDelegate>)delegate withIndexPath:(NSIndexPath *)indexPath{
    self.delegate = delegate;
    self.cardIndexPath = indexPath;
}

#pragma mark -- Event response
#pragma mark 点击标题
-(void)feedTitleTap{
    [self routerEventWithName:kTopicTitleEvent userInfo:@{kViewpointDataModelKey: self.cellLayout.model,kCellIndexPathKey: self.cardIndexPath}];
}

#pragma mark 点击描述
-(void)feedIntroTap{
    [self routerEventWithName:kViewpointIntroEvent userInfo:@{kViewpointDataModelKey: self.cellLayout.model, kCellIndexPathKey: self.cardIndexPath}];
}

#pragma mark 停止播放
-(void)stopAuido{
    [self.audioView stopPlayAudio];
}

#pragma mark -- Private methods
#pragma mark 界面初始化
-(void)initMyAnswerView{
    [self.contentView addSubview:self.myTitleLab];
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.authorView];
    [self.contentView addSubview:self.imgsCollectionView];
    [self.contentView addSubview:self.videoContainerView];
    [self.contentView addSubview:self.audioView];
    [self.contentView addSubview:self.descLab];
    [self.contentView addSubview:self.effectView];
    [self.contentView addSubview:self.statusLab];
    self.effectView.hidden = self.statusLab.hidden = YES;
    [self.contentView addSubview:self.answerInfoView];
    [self.contentView addSubview:self.handleView];
    [self.contentView addSubview:self.lineView];
}

#pragma mark 加载失败
-(void)showLoadingFailView{
    [self.videoContainerView showInterruptTipsView:VideoInterrupted_NetError];
}

#pragma mark 播放视频
- (void)playVideo{
    if ([self.delegate respondsToSelector:@selector(myAnswerCell:avcellPlayVideoAtIndexPath:)]) {
        [self.delegate myAnswerCell:self avcellPlayVideoAtIndexPath:self.cardIndexPath];
    }
}

#pragma mark -- Getters
#pragma mark 动态标题
-(UILabel *)myTitleLab{
    if (!_myTitleLab) {
        _myTitleLab = [[UILabel alloc] init];
        _myTitleLab.font = [UIFont regularFontWithSize:14];
        _myTitleLab.lineBreakMode = NSLineBreakByCharWrapping;
        _myTitleLab.textColor = [UIColor ctColor66];
        _myTitleLab.preferredMaxLayoutWidth = kScreen_Width-2*kMarginLeft;
        [_myTitleLab addTapPressed:@selector(feedTitleTap) target:self];
    }
    return _myTitleLab;
}

#pragma mark 话题标题
- (UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont mediumFontWithSize:16];
        _titleLab.numberOfLines = 0;
        _titleLab.lineBreakMode = NSLineBreakByCharWrapping;
        _titleLab.textColor = [UIColor ctColor33];
        [_titleLab addTapPressed:@selector(feedTitleTap) target:self];
    }
    return _titleLab;
}

#pragma mark 话题发布者
- (CTFTopicAuthorView *)authorView {
    if (!_authorView) {
        _authorView = [[CTFTopicAuthorView alloc] init];
    }
    return _authorView;
}

#pragma mark 多张图片
-(CTFPhotosColletionView *)imgsCollectionView{
    if (!_imgsCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        _imgsCollectionView = [[CTFPhotosColletionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    }
    return _imgsCollectionView;
}

#pragma mark 视频
-(CTFAVVideoContainerView *)videoContainerView{
    if (!_videoContainerView) {
        _videoContainerView = [[CTFAVVideoContainerView alloc] init];
        @weakify(self);
        _videoContainerView.playVideo = ^{
            @strongify(self);
            [self playVideo];
        };
        [_videoContainerView addTapPressed:@selector(playVideo) target:self];
    }
    return _videoContainerView;
}

#pragma mark 图语视图
-(CTFAudioFeedView *)audioView{
    if (!_audioView) {
        _audioView = [[CTFAudioFeedView alloc] init];
        _audioView.layer.cornerRadius = 5.0;
        _audioView.clipsToBounds = YES;
    }
    return _audioView;
}

#pragma mark 观点描述
-(UILabel *)descLab{
    if (!_descLab) {
        _descLab = [[UILabel alloc] init];
        _descLab.font = [UIFont regularFontWithSize:13];
        _descLab.numberOfLines = 2;
        _descLab.textColor = [UIColor ctColor66];
        [_descLab addTapPressed:@selector(feedIntroTap) target:self];
    }
    return _descLab;
}

- (CTBlurEffectView *)effectView {
    if (!_effectView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _effectView = [[CTBlurEffectView alloc] initWithEffect:effect];
    }
    return _effectView;
}

#pragma mark 审核
-(UILabel *)statusLab{
    if (!_statusLab) {
        _statusLab = [[UILabel alloc] init];
        _statusLab.font = [UIFont regularFontWithSize:12.f];
        _statusLab.textColor = UIColorFromHEX(0xFF5757);
        _statusLab.text = @"内容审核中";
    }
    return _statusLab;
}

#pragma mark 阅读量
- (CTFAnswerInfoView *)answerInfoView {
    if (!_answerInfoView) {
        _answerInfoView = [[CTFAnswerInfoView alloc] init];
    }
    return _answerInfoView;
}

#pragma mark 事件
-(CTFAnswerHandleView *)handleView {
    if (!_handleView) {
        _handleView = [[CTFAnswerHandleView alloc] init];
    }
    return _handleView;
}

#pragma mark 线
-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = UIColorFromHEX(0xF8F8F8);
    }
    return _lineView;
}

@end
