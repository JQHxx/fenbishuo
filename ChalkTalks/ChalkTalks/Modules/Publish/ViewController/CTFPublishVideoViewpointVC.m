//
//  CTFPublishVideoViewpointVC.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/12.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFPublishVideoViewpointVC.h"
#import <UITextView+Placeholder/UITextView+Placeholder.h>
#import "CTFPublishImageItemCCell.h"
#import "CTFPublishImageViewpointViewModel.h"
#import "AliOSSTokenCache.h"
#import "YBImageBrowser.h"
#import <AliyunOSSiOS/AliyunOSSiOS.h>
#import "CTFPublishTopicViewModel.h"
#import "CTFPublishVideoViewpointViewModel.h"
#import "CTFVideoImagesSlice.h"
#import "ZFUtilities.h"
#import "ZFPlayer.h"
#import "ZFAVPlayerManager.h"
#import "ZFPlayerControlView.h"
#import "CTFBrowseVideoControlVIew.h"
#import "CTFPublishTopicViewModel.h"
#import "CTFPickVideoCoverVC.h"
#import "CTFImageUpload.h"
#import "CTFVideoMuteManager.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+Size.h"
#import "NSURL+Ext.h"
#import "UIImage+Ext.h"
#import <IQKeyboardManager.h>

@interface CTFPublishVideoViewpointVC ()<UITextViewDelegate, UINavigationControllerDelegate, CTVideoUploaderDelegate,CTFImageUploadDelegate>{
    UIView       *navLineView;
    UIScrollView *mainScrollView;
    UIView       *mainContentView;
    UILabel      *topicLabel;
    UIView       *lineView;
    UIImageView  *videoBgView;
    UIImageView  *videoCoverView;
    UIButton     *playButton;
    UILabel      *unPlayShowDurationLabel;
    UIImageView  *arrowImgView;
    UIView       *anserDescContainView;
    UITextView   *answerDescTextView;
    UILabel      *countLabel;
    UIButton     *selectCoverBtn;
    
    NSString     *uploadImageId;
    NSString     *uploadVideoId;
}

@property(nonatomic,strong) ZFPlayerController  *player;
@property(nonatomic,strong) CTFBrowseVideoControlVIew *controlView;

@property(nonatomic,strong) CTVideoUploader    *uploader;
@property(nonatomic,strong) CTFImageUpload     *imageUploader;
@property(nonatomic,strong) CTFPublishVideoViewpointViewModel *adapter;
@property(nonatomic,strong) MBProgressHUD      *hub;
@property(nonatomic,strong) CTVideoUploaderProgress *videoUploaderHUB;

@property(nonatomic,assign) BOOL                videoNeedSave;
@property(nonatomic,strong) NSString            *quesionTitle;
@property(nonatomic,strong) NSURL               *videoPath;
@property(nonatomic,strong) NSString            *videoMd5;
@property(nonatomic,strong) CTFVideoImagesSlice *videoSlice;
@property(nonatomic,assign) BOOL                isFullScreen;
@property(nonatomic,assign) BOOL                isLandscapeVideo;
@property(nonatomic,assign) BOOL                cancelUploadVideo;
@property(nonatomic,assign) BOOL                isContentEditing;

@property(nonatomic,assign) CGFloat            originOffsetY;
@property(nonatomic,assign) BOOL               textChanged;
@property(nonatomic,assign) BOOL               updateTextHeight;
@property(nonatomic,assign) BOOL               copyingText;

@property(nonatomic,strong) CTFVideoImageModel *curSliceModel; //封面信息

@end

@implementation CTFPublishVideoViewpointVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle = @"我来回答";
    self.rigthTitleName = @"发布";
    
    self.automaticallyAdjustsScrollViewInsets = NO;

    
    [self setupUI];
    [self setupUILayout];
    [self setupAVVideoPlayer];
    [self parsePublishVideoInfo];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 100;
}

- (BOOL)prefersStatusBarHidden {
    return self.isFullScreen;
}

#pragma mark -- Delegate
#pragma mark CTFImageUploadDelegate
#pragma mark 视频封面上传进度
-(void)uploadImageProgress:(UploadImageFileModel *)fileModel progress:(CGFloat)progress{
    self.videoUploaderHUB.progress = progress * 0.05f;
}

#pragma mark 封面上传结束回调
-(void)didFinishedUploadImage:(UploadImageFileModel *)fileModel error:(NSError *)error{
    if(error){
        [self.videoUploaderHUB hide];
        NSString *tip = [error.userInfo safe_stringForKey:NSLocalizedDescriptionKey];
        NSString *msg = [NSString stringWithFormat:@"上传图片失败 %@", tip];
        LogError(msg);
        if([tip containsString:@"超时"]){
          [self.view makeToast:@"网络错误，请检查网络后重试"];
        }else{
             [self.view makeToast:tip];
        }
    }else{
        uploadImageId = fileModel.imageId;
        [self uploadVideo];
    }
}

#pragma mark CTVideoUploaderDelegate
#pragma mark 视频上传进度
- (void)uploadProgressWithPercent:(float)percent {
    ZLLog(@"视频上传进度: %f", percent);
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        self.videoUploaderHUB.progress = 0.05f + 0.95f*percent;
    });
}

#pragma mark 视频上传结束回调
- (void)didFinishedUploadWithIsSuccess:(BOOL)isSuccess videoId:(NSString *)videoId error:(NSError *)error {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
       if (isSuccess) {
           ZLLog(@"视频上传成功");
           self->uploadVideoId = videoId;
           if (!self.cancelUploadVideo) {
               [[CTVideoCache share] saveVideoWithPath:self.videoPath.path questionId:self.adapter.quesionId];
               [self publishVideoAnswer];
           }
        } else {
            LogError(@"视频上传失败");
            [self.videoUploaderHUB hide];
        }
    });
}

#pragma mark - UITextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    CGFloat textHeight = [text boundingRectWithSize:CGSizeMake(kScreen_Width - 42, CGFLOAT_MAX) withTextFont:answerDescTextView.font].height;
    if (textHeight > 67) {
        self.copyingText = YES;
        self.textChanged = YES;
        [self observeTextViewHeight];
    }
    
    if([text isEqualToString:@" "] && textView.text.length <= 0){
        return NO;
    }
    return YES;
}

#pragma mark 监听输入动态
-(void)textViewDidChange:(UITextView *)textView{
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) return;
    
    self.isContentEditing = YES;
    self.textChanged = YES;
    
    [self observeTextViewHeight];
}

#pragma mark - private
#pragma mark 解析数据
- (void)parsePublishVideoInfo {
    NSInteger quesionId;
    if (self.draftModel) {
        quesionId = self.draftModel.questionId;
        self.quesionTitle = self.draftModel.questionTitle;
        self.videoPath = [NSURL fileURLWithPath:self.draftModel.videoPath];
        self.videoNeedSave = YES;
        
        answerDescTextView.text = self.draftModel.content;
        self.updateTextHeight = YES;
        
        [self observeTextViewHeight];
    } else {
        quesionId = [self.schemaArgu safe_integerForKey:@"questionId"];
        self.quesionTitle = [self.schemaArgu safe_stringForKey:@"quesionTitle"];
        self.videoPath = [NSURL safe_URLWithString:[self.schemaArgu safe_stringForKey:@"videoUrl"]];
        self.videoMd5 = [self.schemaArgu safe_stringForKey:@"videoMd5"];
        self.videoNeedSave = [self.schemaArgu safe_stringForKey:@"save"] != nil;
    }
    
    self.videoSlice = [[CTFVideoImagesSlice alloc] initWithVideoUrl:self.videoPath];
    @weakify(self);
    [self.videoSlice asyncObtainCoverByTs:0 complete:^(CTFVideoImageModel * _Nonnull vImage) {
        @strongify(self);
        self->uploadImageId = nil;
        if (self.draftModel != nil) {
            vImage.index = self.draftModel.videoCoverIndex;
            vImage.cropImage = [[CTDrafts share] imageWithPath:self.draftModel.videoCoverPath];
        }
        self.curSliceModel = vImage;
    }];
    
    unPlayShowDurationLabel.text = [ZFUtilities convertTimeSecond: [self.videoSlice videoDuration]];
    unPlayShowDurationLabel.hidden = NO;
    
    self.adapter = [[CTFPublishVideoViewpointViewModel alloc] initWithQuesionId:quesionId];
    topicLabel.text = self.quesionTitle;
}

#pragma mark - Action
#pragma mark 发布
-(void)rightNavigationItemAction{
    [self.view endEditing:YES];
    self.cancelUploadVideo = NO;
    //1.上传图片
    [self uploadVideoCover];
}

#pragma mark 播放视频
-(void)playBtnClick:(id)sender{
    [self.view endEditing:YES];
    if(self.videoPath){
        self.player.assetURL = self.videoPath;
        self.player.currentPlayerManager.seekTime = 0;
        [self.player.currentPlayerManager play];
        self.player.orientationObserver.fullScreenMode = self.isLandscapeVideo ? ZFFullScreenModeLandscape : ZFFullScreenModePortrait;
        [self.player enterFullScreen:YES animated:YES];
    }
}

#pragma mark 选择视频封面
-(void)selectCoverClick:(id)sender{
    if(!self.videoPath) return;
    if(!self.curSliceModel) return;
    CTFPickVideoCoverVC *vc = (CTFPickVideoCoverVC*)VIEWCONTROLLER(kCTFPickVideoCoverVC);
    vc.schemaArgu = @{@"videoPath": self.videoPath.absoluteString, @"index":@(self.curSliceModel.index)};
    @weakify(self);
    vc.pickedVideoCover = ^(CTFVideoImageModel * _Nonnull selModel) {
        @strongify(self);
        self.isContentEditing = YES;
        self->uploadImageId = nil;
        selModel.width = self.curSliceModel.width;
        selModel.height = self.curSliceModel.height;
        selModel.rotation = self.curSliceModel.rotation;
        self.curSliceModel = selModel;
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 返回
-(void)leftNavigationItemAction{
    if (self.draftModel != nil && !self.isContentEditing) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return ;
    }
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:@"是否退出编辑？" preferredStyle:UIAlertControllerStyleAlert];
    @weakify(self);
    UIAlertAction* exitAction = [UIAlertAction actionWithTitle:@"保存并退出" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        @strongify(self);
        [MobClick event:@"answer_exitedit"];
        [self storeToDraft];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [exitAction setValue:[UIColor ctColor99] forKey:@"titleTextColor"];
    UIAlertAction* goonAction = [UIAlertAction actionWithTitle:@"继续编辑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
           [MobClick event:@"answer_canclexit"];
    }];
    [goonAction setValue:UIColorFromHEX(0xFF6885) forKey:@"titleTextColor"];

    [alert addAction:exitAction];
    [alert addAction:goonAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- Private methods
#pragma mark 上传封面
-(void)uploadVideoCover{
    self.videoUploaderHUB = [CTVideoUploaderProgress showInView:self.view];
    @weakify(self)
    self.videoUploaderHUB.cancelBlock = ^{
        @strongify(self)
        ZLLog(@"取消视频上传。");
        self.cancelUploadVideo = YES;
        [self.uploader cancelUpload];
        [self.videoUploaderHUB hide];
    };
    [[CTVideoCache share] saveVideoCoverWithImage:self.curSliceModel.cropImage questionId:self.adapter.quesionId];
    self.imageUploader = [[CTFImageUpload alloc] initWithImage:self.curSliceModel.cropImage delegate:self];
    [self.imageUploader uploadImage];
}

#pragma mark 上传视频
- (void)uploadVideo {
    _uploader = [[CTVideoUploader alloc] initWithFilePath:_videoPath delegate:self];
    [_uploader startUploadVideoWithMd5:_videoMd5 width:self.curSliceModel.width height:self.curSliceModel.height rotate:self.curSliceModel.rotation];
}

#pragma mark 发布视频回答
-(void)publishVideoAnswer{
    NSString *desc = answerDescTextView.text;
    NSCharacterSet  *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    desc = [desc stringByTrimmingCharactersInSet:set];
    @weakify(self);
    [self.adapter createVideoAnswert:desc videoId:uploadVideoId videoCoverImageId:uploadImageId
         complete:^(BOOL isSuccess) {
        @strongify(self);
        [self.videoUploaderHUB hide];
        if (isSuccess) {
            //保存视频
            if(self.videoPath && self.videoNeedSave){
            BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([self.videoPath path]);
            if (compatible){
                UISaveVideoAtPathToSavedPhotosAlbum([self.videoPath path], self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
                }
            }
            //移除草稿
            if (self.draftModel != nil) {
                [[CTDrafts share] removeDraftWithId:self.draftModel.draftId];
            }
            
            NSInteger answerId = [self.adapter currentAnswerId];
            NSDictionary *userinfo = @{@"answerId": @(answerId)};
            [[NSNotificationCenter defaultCenter] postNotificationName:kPublishAnswerSuccessNotification object:nil userInfo:userinfo];
            [self dismissViewControllerAnimated:YES completion:^{
                [kKeyWindow makeToast:@"发布成功"];
            }];
        } else {
            NSString *error = [NSString stringWithFormat:@"发布视频回答失败 %ld", (long)self.adapter.serverErrorCode];
            LogError(error);
            if (self.adapter.serverErrorCode == 4020) {
                [self cannotPublishTwoAnswer];
            } else {
                [self.view makeToast:self.adapter.errorString];
            }
        }
    }];
}

#pragma mark 保存到草稿箱
- (void)storeToDraft {
    if (_asset != nil) {
        [[CTDrafts share] addVideoDraftWithAsset:_asset
                                         content:answerDescTextView.text
                                      questionId:self.adapter.quesionId
                                   questionTitle:self.quesionTitle
                                 coverImageIndex:self.curSliceModel.index
                                      coverImage:self.curSliceModel.cropImage];
    } else {
        [[CTDrafts share] addVideoDraftWithPath:_videoPath
                                        content:answerDescTextView.text
                                     questionId:self.adapter.quesionId
                                  questionTitle:self.quesionTitle
                                coverImageIndex:self.curSliceModel.index
                                     coverImage:self.curSliceModel.cropImage];
    }
}

#pragma mark 重复发布提示
-(void)cannotPublishTwoAnswer{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:@"当前话题下，你已发布过回答" preferredStyle:UIAlertControllerStyleAlert];
    @weakify(self);
    UIAlertAction* exitAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:exitAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark 保存视频完成之后的回调
- (void)savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    if (error) {
        ZLLog(@"保存视频失败%@", error.localizedDescription);
    }else {
        ZLLog(@"保存视频成功");
    }
}

#pragma mark 设置封面信息
-(void)setCurSliceModel:(CTFVideoImageModel *)model{
    _curSliceModel = model;
    
    self.isLandscapeVideo = _curSliceModel.width >= _curSliceModel.height && (_curSliceModel.rotation == 0 ||_curSliceModel.rotation == 180);
    CGFloat videoH = [AppMargin getAspectVideoHeightWithWidth:_curSliceModel.width height:_curSliceModel.height rotation:_curSliceModel.rotation];
    [videoCoverView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(videoH);
    }];
    [videoBgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(videoH);
    }];
    self->videoCoverView.image = _curSliceModel.cropImage;
}

#pragma mark 动态高度监听
- (void)observeTextViewHeight {
    if (answerDescTextView.text.length > 40) {
        self.rightBtn.enabled = NO;
        countLabel.textColor = UIColorFromHEX(0xFF5757);
        countLabel.text = [NSString stringWithFormat:@"已超出%ld个字",answerDescTextView.text.length - 40];
    } else {
        self.rightBtn.enabled = YES;
        countLabel.textColor = [UIColor ctColor99];
        countLabel.text = [NSString stringWithFormat:@"%ld/40",answerDescTextView.text.length];
    }
    
    //一行高度
    CGFloat oneLineHeight = [@"111111" boundingRectWithSize:CGSizeMake(kScreen_Width - 42, CGFLOAT_MAX) withTextFont:answerDescTextView.font].height;
    //10行高度
    CGFloat maxHeight = oneLineHeight * 10;
    CGFloat textHeight = [answerDescTextView.text boundingRectWithSize:CGSizeMake(kScreen_Width - 42, CGFLOAT_MAX) withTextFont:answerDescTextView.font].height;
    if (textHeight > 0) {
        CGFloat contentH = 0;
        if (textHeight < 67) {
            contentH = 67 ;
            self.originOffsetY = mainScrollView.contentOffset.y;
        } else if (textHeight > maxHeight) {
            contentH = maxHeight;
            if (self.textChanged && (self.updateTextHeight || self.copyingText) && self.originOffsetY == 0) {
                if (self.updateTextHeight) {
                    self.originOffsetY = mainScrollView.contentOffset.y - maxHeight + 67;
                    self.updateTextHeight = NO;
                }
                if (self.copyingText) {
                    self.originOffsetY = mainScrollView.contentOffset.y;
                    self.copyingText = NO;
                }
            }
            [mainScrollView setContentOffset:CGPointMake(0, self.originOffsetY + maxHeight - 67) animated:NO];
        } else {
            contentH = textHeight;
            if (self.textChanged && (self.updateTextHeight || self.copyingText) && self.originOffsetY == 0) {
                if (self.updateTextHeight) {
                    self.originOffsetY = mainScrollView.contentOffset.y - contentH + 67;
                    self.updateTextHeight = NO;
                }
                if (self.copyingText) {
                    self.originOffsetY = mainScrollView.contentOffset.y;
                    self.copyingText = NO;
                }
            }
            [mainScrollView setContentOffset:CGPointMake(0, self.originOffsetY + contentH - 67) animated:NO];
        }
        [answerDescTextView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(contentH);
        }];
    } else {
        [answerDescTextView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(67);
        }];
    }
}

#pragma mark 计算动态高度
- (CGFloat)getViewDynamicHeight {
    //一行高度
    CGFloat oneLineHeight = [@"111111" boundingRectWithSize:CGSizeMake(kScreen_Width - 42, CGFLOAT_MAX) withTextFont:answerDescTextView.font].height;
    //10行高度
    CGFloat maxHeight = oneLineHeight * 10;
    CGFloat textHeight = [answerDescTextView.text boundingRectWithSize:CGSizeMake(kScreen_Width - 42, CGFLOAT_MAX) withTextFont:answerDescTextView.font].height;
    if (textHeight > 0) {
        CGFloat contentH = 0;
        if (textHeight < 67) {
            contentH = 67 ;
        } else if (textHeight > maxHeight) {
            contentH = maxHeight;
        } else {
            contentH = textHeight;
        }
        return contentH;
    } else {
        return 67;
    }
}

#pragma mark 初始化界面
-(void)setupUI{
    navLineView = [[UIView alloc] init];
    navLineView.backgroundColor = [UIColor ctColorF8];
    [self.view addSubview:navLineView];
    
    mainScrollView = [[UIScrollView alloc] init];
    mainScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [mainScrollView setShowsVerticalScrollIndicator:NO];
    mainScrollView.alwaysBounceVertical = YES;
    [self.view addSubview:mainScrollView];
    
    mainContentView = [[UIView alloc] init];
    [mainScrollView addSubview:mainContentView];
    
    topicLabel = [[UILabel alloc] init];
    topicLabel.font = [UIFont regularFontWithSize:18];
    topicLabel.textColor = [UIColor ctColor33];
    [mainContentView addSubview:topicLabel];
     
    lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor ctColorF8];
    [mainContentView addSubview:lineView];
    
    videoBgView = [[UIImageView alloc] init];
    videoBgView.backgroundColor = [UIColor blackColor];
    videoBgView.clipsToBounds = YES;
    videoBgView.layer.cornerRadius = kCornerRadius;
    [mainContentView addSubview:videoBgView];
        
    videoCoverView = [[UIImageView alloc] init];
    videoCoverView.contentMode = UIViewContentModeScaleAspectFit;
    videoCoverView.userInteractionEnabled = YES;
    videoCoverView.clipsToBounds = YES;
    videoCoverView.layer.cornerRadius = kCornerRadius;
    [mainContentView addSubview:videoCoverView];
        
    playButton = [[UIButton alloc] init];
    [playButton setImage:[UIImage imageNamed:@"video_player_play"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [videoCoverView addSubview:playButton];
        
    unPlayShowDurationLabel = [[UILabel alloc] init];
    unPlayShowDurationLabel.font= [UIFont monospacedDigitSystemFontOfSize:12 weight:(UIFontWeightRegular)];
    unPlayShowDurationLabel.textColor = [UIColor whiteColor];
    unPlayShowDurationLabel.backgroundColor = UIColorFromHEXWithAlpha(0x000000, 0.4);
    unPlayShowDurationLabel.layer.cornerRadius = 10;
    unPlayShowDurationLabel.clipsToBounds = YES;
    unPlayShowDurationLabel.textAlignment = NSTextAlignmentCenter;
    [unPlayShowDurationLabel setHidden:YES];
    [videoCoverView addSubview:unPlayShowDurationLabel];
    
    arrowImgView = [[UIImageView alloc] init];
    arrowImgView.image = ImageNamed(@"video_top_arrow");
    [mainScrollView addSubview:arrowImgView];
    
    anserDescContainView = [[UIView alloc] init];
    anserDescContainView.backgroundColor = [UIColor ctColorF8];
    anserDescContainView.clipsToBounds = YES;
    anserDescContainView.layer.cornerRadius = kCornerRadius;
    [mainContentView addSubview:anserDescContainView];
    
    answerDescTextView = [[UITextView alloc] init];
    answerDescTextView.font = [UIFont regularFontWithSize:16];
    answerDescTextView.textColor = [UIColor ctColor66];
    answerDescTextView.placeholder = @"给视频加个标题能获得更多关注哦～";
    answerDescTextView.placeholderColor = [UIColor ctColorBB];
    answerDescTextView.delegate = self;
    answerDescTextView.textContainerInset = UIEdgeInsetsZero;
    answerDescTextView.textContainer.lineFragmentPadding = 0;
    answerDescTextView.backgroundColor = [UIColor ctColorF8];
    [anserDescContainView addSubview:answerDescTextView];
    
    countLabel = [[UILabel alloc] init];
    countLabel.font = [UIFont regularFontWithSize:12];
    countLabel.textColor = [UIColor ctColor99];
    countLabel.text = @"0/40";
    [anserDescContainView addSubview:countLabel];
    
    selectCoverBtn = [[UIButton alloc] init];
    [selectCoverBtn setBackgroundImage:[UIImage ctRoundRectImageWithFillColor:[UIColor whiteColor] borderColor:[UIColor ctMainColor] borderWidth:1 cornerRadius:15] forState:UIControlStateNormal];
    selectCoverBtn.titleLabel.font = kSystemFont(12);
    [selectCoverBtn setTitleColor:[UIColor ctMainColor] forState:UIControlStateNormal];
    [selectCoverBtn addTarget:self action:@selector(selectCoverClick:) forControlEvents:UIControlEventTouchUpInside];
    [selectCoverBtn setTitle:@"选择视频封面" forState:UIControlStateNormal];
    [mainContentView addSubview:selectCoverBtn];
}

#pragma mark UI
-(void)setupUILayout{
    [navLineView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.mas_equalTo(kNavBar_Height);
         make.left.right.equalTo(self.view);
        make.height.mas_equalTo(0.5f);
    }];
    
    [mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(navLineView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(kScreen_Height-kNavBar_Height);
    }];
    
    [mainContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(mainScrollView);
        make.width.equalTo(mainScrollView);
        make.bottom.mas_equalTo(mainScrollView).offset(-20);
    }];
    
    [topicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMarginLeft);
        make.top.mas_equalTo(kMarginTop);
        make.right.mas_equalTo(-kMarginRight);
    }];
        
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(mainContentView);
        make.top.equalTo(topicLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(14);
    }];
    
    [videoBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineView.mas_bottom).offset(20);
        make.left.mas_equalTo(kMarginLeft);
        make.size.mas_equalTo(CGSizeMake(kScreen_Width-2*kMarginLeft, FeedVideoHeight));
    }];
    
    [videoCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineView.mas_bottom).offset(20);
        make.left.mas_equalTo(kMarginLeft);
        make.size.mas_equalTo(CGSizeMake(kScreen_Width-2*kMarginLeft, FeedVideoHeight));
    }];
    
    [playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(64, 64));
        make.centerX.equalTo(videoCoverView.mas_centerX);
        make.centerY.equalTo(videoCoverView.mas_centerY);
    }];
    
    [unPlayShowDurationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 20));
        make.right.equalTo(videoCoverView.mas_right).offset(-10);
        make.bottom.equalTo(videoCoverView.mas_bottom).offset(-10);
    }];
    
    [arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(videoCoverView.mas_bottom).offset(5);
        make.centerX.mas_equalTo(videoCoverView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(14, 15));
    }];
    
    [anserDescContainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(arrowImgView.mas_bottom);
        make.left.mas_equalTo(kMarginLeft);
        make.width.mas_equalTo(kScreen_Width - 2 *kMarginLeft);
    }];
    
    [answerDescTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(5);
        make.right.mas_equalTo(-5);
        make.height.mas_equalTo(67);
    }];
    
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(answerDescTextView.mas_bottom).offset(10);
        make.right.equalTo(anserDescContainView.mas_right).offset(-10);
        make.bottom.equalTo(anserDescContainView.mas_bottom).offset(-5);
    }];
    
    [selectCoverBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(mainContentView.mas_centerX);
        make.top.equalTo(anserDescContainView.mas_bottom).offset(14);
        make.size.mas_equalTo(CGSizeMake(108, 30));
        make.bottom.mas_equalTo(mainContentView.mas_bottom).offset(-10);
    }];
}

#pragma mark  Setters
#pragma mark 播放器
-(void)setupAVVideoPlayer{
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
    self.player = [ZFPlayerController playerWithPlayerManager:playerManager containerView:[self mainWindow]];
    self.player.controlView = self.controlView;
    self.player.currentPlayerManager.muted = [[CTFVideoMuteManager sharedInstance] getAudoMuteInFeed];
    self.player.WWANAutoPlay = YES;
    self.player.shouldAutoPlay = YES;
    self.player.exitFullScreenWhenStop = YES;
    self.player.allowOrentitaionRotation = NO;
    self.player.customAudioSession = YES;
    
    @weakify(self)
    self.controlView.backBtnClickCallback = ^{
        @strongify(self);
        [self.player stop];
        self.player.currentPlayerManager.view.hidden = YES;
    };
    self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        @strongify(self)
        self.isFullScreen = isFullScreen;
        [self setNeedsStatusBarAppearanceUpdate];
    };
}

#pragma mark -- Getters
#pragma mark - UI
-(UIWindow*)mainWindow{
    id appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate && [appDelegate respondsToSelector:@selector(window)]) {
        return [appDelegate window];
    }
    NSArray *windows = [UIApplication sharedApplication].windows;
    if ([windows count] == 1) {
        return [windows firstObject];
    } else {
        for (UIWindow *window in windows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                return window;
            }
        }
    }
    return self.view.window;
}

- (CTFBrowseVideoControlVIew *)controlView {
    if (!_controlView) {
        _controlView = [CTFBrowseVideoControlVIew new];
    }
    return _controlView;
}

-(void)dealloc{
    self.player = nil;
}

@end
