//
//  CTFAnswerDetailCell.m
//  ChalkTalks
//
//  Created by vision on 2020/1/9.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFAnswerDetailCell.h"
#import "CTFAnswerDetailUserInfoView.h"
#import "CTFPhotosColletionView.h"
#import "CTFAVVideoContainerView.h"
#import "CTFAudioFeedView.h"
#import "CTFNetReachabilityManager.h"
#import "CTFAnswerDetailCellLayout.h"
#import "CTFAnswerHandleView.h"

@interface CTFAnswerDetailCell ()

@property (nonatomic,strong) UIView                      *line;            //线条
@property (nonatomic,strong) CTFAnswerDetailUserInfoView *userInfoView;    //用户信息
@property (nonatomic,strong) CTFPhotosColletionView      *photosView;      //图片视图
@property (nonatomic,strong) CTFAVVideoContainerView     *videoView;       //视频视图
@property (nonatomic,strong) CTFAudioFeedView            *audioView;       //语图视图
@property (nonatomic,strong) UILabel                     *descLabel;       //描述
@property (nonatomic,strong) UILabel                     *statusLabel;
@property (nonatomic,strong) CTBlurEffectView            *effectView;      //模糊
@property (nonatomic,strong) UIButton                    *viewCountBtn;   //阅读量
@property (nonatomic,strong) CTFAnswerHandleView         *handleView;

@property (nonatomic, weak ) id<CTFAnswerDetailCellDelegate>myDelegate;
@property (nonatomic,strong) CTFAnswerDetailCellLayout   *cellLayout;

@end

@implementation CTFAnswerDetailCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.line];
        [self.contentView addSubview:self.userInfoView];
        [self.contentView addSubview:self.photosView];
        [self.contentView addSubview:self.videoView];
        [self.contentView addSubview:self.audioView];
        [self.contentView addSubview:self.descLabel];
        [self.contentView addSubview:self.statusLabel];
        [self.contentView addSubview:self.effectView];
        self.effectView.hidden = self.statusLabel.hidden = YES;
        [self.contentView addSubview:self.viewCountBtn];
        [self.contentView addSubview:self.handleView];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.userInfoView.frame = self.cellLayout.userInfoRect;
    self.photosView.frame = self.cellLayout.imgsRect;
    self.videoView.frame = self.cellLayout.videoRect;
    self.audioView.frame = self.cellLayout.audioRect;
    self.descLabel.frame = self.cellLayout.viewpointRect;
    self.effectView.frame = self.cellLayout.viewpointRect;
    self.statusLabel.frame = self.cellLayout.statusRect;
    self.viewCountBtn.frame = self.cellLayout.viewCountRect;
    [self.viewCountBtn setBorderWithCornerRadius:13 type:UIViewCornerTypeAll];
    self.handleView.frame = self.cellLayout.handleRect;
    self.line.frame = self.cellLayout.separationRect;
}

#pragma mark 填充数据
-(void)fillContentWithData:(id)obj{
    self.cellLayout = (CTFAnswerDetailCellLayout *)obj;
    AnswerModel *answerModel = self.cellLayout.model;
    [self.userInfoView fillContentWithData:answerModel indexPath:self.cardIndexPath];
    if ([answerModel.type isEqualToString:@"images"]) {
        [self.photosView fillImagesData:answerModel.images status:answerModel.status];
    }else if ([answerModel.type isEqualToString:@"video"]){
        [self.videoView fillContentWithData:answerModel];
    }else if ([answerModel.type isEqualToString:@"audioImage"]){
        [self.audioView fillAudioImageData:answerModel.audioImage indexPath:self.cardIndexPath currentIndex:answerModel.currentIndex status:answerModel.status];
    }
    if (!kIsEmptyString(answerModel.content)) {
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:answerModel.content];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.lineSpacing = 4;
        [attributeStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, answerModel.content.length)];
        self.descLabel.attributedText = attributeStr;
        
        if (answerModel.images.count  == 0 && [answerModel.type isEqualToString:@"images"]) {
            self.statusLabel.hidden = NO;
        } else {
            self.statusLabel.hidden = YES;
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
    
    [self.viewCountBtn setTitle:[NSString stringWithFormat:@"%@人阅读",[AppUtils countToString:self.cellLayout.model.viewCount]] forState:UIControlStateNormal];
    [self.handleView fillAnswerData:self.cellLayout.model indexPath:self.cardIndexPath];
}


#pragma mark -- Public msthods
#pragma mark 设置代理
- (void)setDelegate:(id<CTFAnswerDetailCellDelegate>)delegate withIndexPath:(NSIndexPath *)indexPath{
    self.myDelegate = delegate;
    self.cardIndexPath = indexPath;
}

#pragma mark -- Private methods
#pragma mark 播放视频
- (void)playVideo{
    if ([[CTFNetReachabilityManager sharedInstance] currentNetStatus] == AFNetworkReachabilityStatusNotReachable) {
        [self.videoView showInterruptTipsView:VideoInterrupted_NetError];
        [kKeyWindow makeToast:@"暂无网络，无法播放"];
    }else{
        if ([self.myDelegate respondsToSelector:@selector(answerDetailCell:playTheVideoAtIndexPath:)]) {
            [self.myDelegate answerDetailCell:self playTheVideoAtIndexPath:self.cardIndexPath];
        }
    }
}

#pragma mark 停止播放
- (void)stopAuido{
    [self.audioView stopPlayAudio];
}

#pragma mark -- Getters
#pragma mark 用户信息
- (CTFAnswerDetailUserInfoView *)userInfoView{
    if (!_userInfoView) {
        _userInfoView = [[CTFAnswerDetailUserInfoView alloc] init];
    }
    return _userInfoView;
}

#pragma mark 图片
- (CTFPhotosColletionView *)photosView{
    if (!_photosView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        _photosView = [[CTFPhotosColletionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    }
    return _photosView;
}

#pragma mark 视频
- (CTFAVVideoContainerView *)videoView{
    if (!_videoView) {
        _videoView = [[CTFAVVideoContainerView alloc] init];
        @weakify(self);
        _videoView.playVideo = ^{
            @strongify(self);
            [self playVideo];
        };
        [_videoView addTapPressed:@selector(playVideo) target:self];
    }
    return _videoView;
}

#pragma mark 语图视图
- (CTFAudioFeedView *)audioView{
    if (!_audioView) {
        _audioView = [[CTFAudioFeedView alloc] init];
        _audioView.layer.cornerRadius = 5.0;
        _audioView.clipsToBounds = YES;
    }
    return _audioView;
}

#pragma mark 描述
- (UILabel *)descLabel{
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.numberOfLines = 0;
        _descLabel.font = [UIFont regularFontWithSize:16];
        _descLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _descLabel.textColor = [UIColor ctColor33];
    }
    return _descLabel;
}

#pragma mark 毛玻璃
- (CTBlurEffectView *)effectView {
    if (!_effectView) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        _effectView = [[CTBlurEffectView alloc] initWithEffect:blur];
    }
    return _effectView;
}

#pragma mark 审核
- (UILabel *)statusLabel{
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        _statusLabel.font = [UIFont regularFontWithSize:12];
        _statusLabel.textColor = UIColorFromHEX(0xFF5757);
        _statusLabel.text = @"内容审核中";
    }
    return _statusLabel;
}

#pragma mark 阅读量
- (UIButton *)viewCountBtn {
    if (!_viewCountBtn) {
        _viewCountBtn = [[UIButton alloc] init];
        [_viewCountBtn setImage:ImageNamed(@"topic_read_count") forState:UIControlStateNormal];
        [_viewCountBtn setTitleColor:[UIColor ctColor99] forState:UIControlStateNormal];
        _viewCountBtn.titleLabel.font = [UIFont regularFontWithSize:11];
        _viewCountBtn.backgroundColor = [UIColor ctColorF8];
        _viewCountBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    }
    return _viewCountBtn;
}

#pragma mark 更多
- (CTFAnswerHandleView *)handleView {
    if (!_handleView) {
        _handleView = [[CTFAnswerHandleView alloc] init];
        _handleView.type = CTFAnswerHandleViewTypeTopicDetails;
    }
    return _handleView;
}

#pragma mark 线条
- (UIView *)line{
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = UIColorFromHEX(0xF8F8F8);
    }
    return _line;
}

@end
