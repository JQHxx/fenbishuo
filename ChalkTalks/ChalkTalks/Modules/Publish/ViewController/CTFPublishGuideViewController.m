//
//  CTFPublishGuideViewController.m
//  ChalkTalks
//
//  Created by vision on 2020/3/21.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFPublishGuideViewController.h"
#import "CTFBasePublishView.h"
#import "CTFVideoGuideView.h"
#import "NSUserDefaultsInfos.h"
#import <HWPanModal.h>
#import "UIImage+Size.h"

#define kVideoHeight (kScreen_Width-60)*(9.0/16.0)
#define kViewWidth   (kScreen_Width-63)/2.0
#define kViewHeight  kViewWidth*(130.0/156.0)

#define kCloseVideoKey  @"com.fenbishuo.ios.guide.video.close"

@interface CTFPublishGuideViewController ()<HWPanModalPresentable>

@property (nonatomic, strong) CTFVideoGuideView  *videoView;
@property (nonatomic, strong) UIButton           *handleVideoBtn;
@property (nonatomic, strong) CTFBasePublishView *requestView;//提要求
@property (nonatomic, strong) CTFBasePublishView *recommendView;//求推荐
@property (nonatomic, strong) UIView             *bottomView;//求推荐

@end

@implementation CTFPublishGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.requestView];
    [self.view addSubview:self.recommendView];
    [self.view addSubview:self.bottomView];
    [self updateUI];
}

#pragma mark -- HWPanModalPresentable
#pragma 是否显示drag指示view
- (BOOL)showDragIndicator {
    return NO;
}

#pragma mark
- (PanModalHeight)longFormHeight{
    return PanModalHeightMake(PanModalHeightTypeContent,kVideoHeight + 164 + kTabBar_Height + kViewHeight);
}

#pragma mark
- (PanModalHeight)shortFormHeight {
    return PanModalHeightMake(PanModalHeightTypeContent, kTabBar_Height + 75 + kViewHeight);
}

- (PresentationState)originPresentationState {
    BOOL hasClosedVideo = [[NSUserDefaultsInfos getValueforKey:kCloseVideoKey] boolValue];
    return hasClosedVideo ? PresentationStateShort : PresentationStateLong;
}

#pragma mark 是否需要使拖拽手势生效
- (BOOL)shouldRespondToPanModalGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer {
    return NO;
}

- (BOOL)allowsDragToDismiss {
    return NO;
}

#pragma mark -- Event response
#pragma mark 显示引导视频
- (void)showGuideVideoAction:(UIButton *)sender {
    [NSUserDefaultsInfos putKey:kCloseVideoKey andValue:[NSNumber numberWithBool:NO]];
    [self hw_panModalTransitionTo:PresentationStateLong animated:NO];
    [self updateUI];
}

#pragma mark 发布话题
- (void)seekRecommendationAction:(UITapGestureRecognizer *)gesture {
    [self dismissViewControllerAnimated:YES completion:^{
        self.dismissBlock(gesture.view.tag);
    }];
}

#pragma mark 关闭
- (void)dismissPublishGuideAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- Private methods
#pragma mark 跟新界面
- (void)updateUI{
    BOOL hasClosedVideo = [[NSUserDefaultsInfos getValueforKey:kCloseVideoKey] boolValue];
    if (hasClosedVideo) {
        if (self.videoView) {
            [self.videoView removeFromSuperview];
            self.videoView = nil;
        }
        [self.view addSubview:self.handleVideoBtn];
        self.requestView.y = self.handleVideoBtn.bottom + 50;
    } else {
        if (self.handleVideoBtn) {
            [self.handleVideoBtn removeFromSuperview];
            self.handleVideoBtn = nil;
        }
        [self.view addSubview:self.videoView];
        self.videoView.videoModel = self.guideVideo;
        self.requestView.y = self.videoView.bottom + 50;
    }
    self.recommendView.y = self.requestView.y;
    self.bottomView.y = self.requestView.bottom;
}

#pragma mark -- Setters
#pragma mark
- (void)setGuideVideo:(CTFGuideVideoModel *)guideVideo{
    _guideVideo = guideVideo;
    BOOL hasClosedVideo = [[NSUserDefaultsInfos getValueforKey:kCloseVideoKey] boolValue];
    if (!hasClosedVideo) {
        if (self.videoView) {
            self.videoView.videoModel = self.guideVideo;
        }
    }
}

#pragma mark -- Getters
- (CTFVideoGuideView *)videoView {
    if (!_videoView) {
        _videoView = [[CTFVideoGuideView alloc] initWithFrame:CGRectMake(16, 0, kScreen_Width - 32, kVideoHeight + 114)];
        kSelfWeak;
        _videoView.closeBlock = ^{
            [NSUserDefaultsInfos putKey:kCloseVideoKey andValue:[NSNumber numberWithBool:YES]];
            [weakSelf hw_panModalTransitionTo:PresentationStateShort animated:NO];
            [weakSelf updateUI];
        };
    }
    return _videoView;
}

#pragma mark 操作视频
- (UIButton *)handleVideoBtn {
    if (!_handleVideoBtn) {
        _handleVideoBtn = [[UIButton alloc] initWithFrame:CGRectMake(23, 0, 85, 25)];
        [_handleVideoBtn setImage:[UIImage drawImageWithName:@"publish_guide_handle_video" size:CGSizeMake(23, 20)] forState:UIControlStateNormal];
        [_handleVideoBtn setTitle:@"操作视频" forState:UIControlStateNormal];
        [_handleVideoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _handleVideoBtn.titleLabel.font = [UIFont regularFontWithSize:13];
        _handleVideoBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 7.5, 0, 0);
        [_handleVideoBtn addTarget:self action:@selector(showGuideVideoAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _handleVideoBtn;
}


#pragma mark 提要求
- (CTFBasePublishView *)requestView{
    if (!_requestView) {
        _requestView = [[CTFBasePublishView alloc] initWithFrame:CGRectMake(23,0 , kViewWidth, kViewHeight) desc:@"让大家来帮忙\n评测一样东西" image:@"btn_add_request"];
        _requestView.tag = 100;
        [_requestView addTapPressed:@selector(seekRecommendationAction:) target:self];
    }
    return _requestView;
}

#pragma mark 求推荐
- (CTFBasePublishView *)recommendView {
    if (!_recommendView) {
        _recommendView = [[CTFBasePublishView alloc] initWithFrame:CGRectMake(self.requestView.right+16,0, kViewWidth, kViewHeight) desc:@"想要买买买\n但不知道哪个品牌好" image:@"btn_add_recommend"];
        _recommendView.tag = 101;
        [_recommendView addTapPressed:@selector(seekRecommendationAction:) target:self];
    }
    return _recommendView;
}

-(UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.requestView.bottom, kScreen_Width, kTabBar_Height)];
        [_bottomView addTapPressed:@selector(dismissPublishGuideAction) target:self];
    }
    return _bottomView;
}

@end
