//
//  CTFBrowseVideoControlVIew.m
//  ChalkTalks
//
//  Created by zingwin on 2020/1/9.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFBrowseVideoControlVIew.h"
#import "ZFSliderView.h"
#import "UIView+ZFFrame.h"
#import "ZFUtilities.h"
#import "ZFPlayer.h"

@interface CTFBrowseVideoControlVIew ()<ZFSliderViewDelegate>
@property (nonatomic, assign) NSTimeInterval sumTime;

@property (nonatomic, assign) BOOL controlViewAppeared;
@property (nonatomic, strong) dispatch_block_t afterBlock;
/// prepare时候是否显示loading,默认 NO.
@property (nonatomic, assign) BOOL prepareShowLoading;
/// 顶部工具栏
@property (nonatomic, strong) UIView *topToolView;
/// 返回按钮
@property (nonatomic, strong) UIButton *backBtn;
/// 声音标志
@property (nonatomic, strong) UIButton *muteBtn;
/// 底部工具栏
@property (nonatomic, strong) UIView *bottomToolView;
/// 播放或暂停按钮
@property (nonatomic, strong) UIButton *playOrPauseBtn;
/// 播放的当前时间
@property (nonatomic, strong) UILabel *currentTimeLabel;
/// 滑杆
@property (nonatomic, strong) ZFSliderView *slider;
/// 视频总时间
@property (nonatomic, strong) UILabel *totalTimeLabel;
//离开全屏
@property(nonatomic, strong) UIButton *exitButton;

@property (nonatomic, assign) BOOL isShow;

@property(nonatomic,strong) UIButton *replayButton;
@property(nonatomic,strong) UIView *replayButtonMaskView;

@property (nonatomic, strong,) UIImageView *coverImageView;
/// 高斯模糊的背景图
@property (nonatomic, strong) UIImageView *bgImgView;
@property (nonatomic, strong) UIView *effectView;


/// 加载失败按钮
@property (nonatomic, strong) UIButton *failBtn;

@property (nonatomic, strong) UIActivityIndicatorView *activity;
@end

@implementation CTFBrowseVideoControlVIew

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.topToolView];
        [self.topToolView addSubview:self.backBtn];
        [self.topToolView addSubview:self.titleLabel];
        [self addSubview:self.muteBtn];
        
        [self addSubview:self.playOrPauseBtn];
        [self addSubview:self.replayButton];
        
        [self addSubview:self.bottomToolView];
        [self.bottomToolView addSubview:self.currentTimeLabel];
        [self.bottomToolView addSubview:self.slider];
        [self.bottomToolView addSubview:self.totalTimeLabel];
        [self.bottomToolView addSubview:self.exitButton];
        
        // 设置子控件的响应事件
        [self makeSubViewsAction];
        [self resetControlView];
        
        /// statusBarFrame changed
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layOutControllerViews) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    }
    return self;
}

-(void)showReplayButton{
    [self.replayButton setHidden:NO];
}
-(void)hideReplayButton{
    [self.replayButton setHidden:YES];
}
-(void)resetMuteButton{
    [self.muteBtn setSelected:self.player.currentPlayerManager.isMuted];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 0;
    CGFloat min_h = 0;
    CGFloat min_view_w = self.bounds.size.width;
    CGFloat min_view_h = self.bounds.size.height;
    
    CGFloat min_margin = 9;
    
    min_x = 0;
    min_y = 0;
    min_w = min_view_w;
    min_h = iPhoneX ? 110 : 80;
    self.topToolView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = (iPhoneX && self.player.orientationObserver.fullScreenMode == ZFFullScreenModeLandscape) ? 44: 15;
    min_y = (iPhoneX && self.player.orientationObserver.fullScreenMode == ZFFullScreenModeLandscape) ? 15: (iPhoneX ? 40 : 20);
    min_w = 40;
    min_h = 40;
    self.backBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.muteBtn.frame = CGRectMake(min_view_w-min_w-9, min_y, min_w, min_h);
    
    min_x = self.backBtn.zf_right + 5;
    min_y = 0;
    min_w = min_view_w - min_x - 15 ;
    min_h = 30;
    self.titleLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.titleLabel.zf_centerY = self.backBtn.zf_centerY;
    
    min_h = (self.player.orientationObserver.fullScreenMode == ZFFullScreenModeLandscape) ? 50: 70;
    min_x = 0;
    min_y = min_view_h - min_h;
    min_w = min_view_w;
    self.bottomToolView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = (iPhoneX && self.player.orientationObserver.fullScreenMode == ZFFullScreenModeLandscape) ? 44: 15;
    min_y = 0;
    min_w = 62;
    min_h = 40;
    self.currentTimeLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_w = 0;///40;
    min_h = 40;
    min_x = self.bottomToolView.zf_width - min_w;//self.bottomToolView.zf_width - min_w - 15;
    min_y = 0;
    self.exitButton.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_w = 62;
    min_h = 40;
    min_y = 0;
    min_x = self.exitButton.zf_x - min_w - min_margin;
    self.totalTimeLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = self.currentTimeLabel.zf_right + 4;
    min_y = 0;
    min_w = self.totalTimeLabel.zf_left - min_x - 4;
    min_h = 40;
    self.slider.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.slider.zf_centerY = self.exitButton.zf_centerY;
    
    min_w = 64;
    min_h = 64;
    self.playOrPauseBtn.frame = CGRectMake(0, 0, min_w, min_h);
    self.playOrPauseBtn.zf_centerX = self.zf_centerX;
    self.playOrPauseBtn.zf_centerY = self.zf_centerY;
    
    self.replayButton.frame = CGRectMake(0, 0, 70, 28);
    self.replayButton.zf_centerX = self.zf_centerX;
    self.replayButton.zf_centerY = self.zf_centerY;
    
    if (!self.isShow) {
        self.topToolView.zf_y = -self.topToolView.zf_height;
        self.bottomToolView.zf_y = self.zf_height;
        self.playOrPauseBtn.alpha = 0;
        [self.replayButton setHidden:YES];
    } else {
        [self.replayButton setHidden:YES];
        self.playOrPauseBtn.alpha = 1;
        if (self.player.isLockedScreen) {
            self.topToolView.zf_y = -self.topToolView.zf_height;
            self.bottomToolView.zf_y = self.zf_height;
        } else {
            self.topToolView.zf_y = 0;
            self.bottomToolView.zf_y = self.zf_height - self.bottomToolView.zf_height;
        }
    }
}

- (void)makeSubViewsAction {
    [self.backBtn addTarget:self action:@selector(backBtnClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.exitButton addTarget:self action:@selector(backBtnClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.playOrPauseBtn addTarget:self action:@selector(playPauseButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.muteBtn addTarget:self action:@selector(muteButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layOutControllerViews {
    [self layoutIfNeeded];
    [self setNeedsLayout];
}

#pragma mark - ZFSliderViewDelegate

- (void)sliderTouchBegan:(float)value {
    self.slider.isdragging = YES;
}

- (void)sliderTouchEnded:(float)value {
    if (self.player.totalTime > 0) {
        @weakify(self)
        [self.player seekToTime:self.player.totalTime*value completionHandler:^(BOOL finished) {
            @strongify(self)
            if (finished) {
                self.slider.isdragging = NO;
            }
        }];
        if (self.seekToPlay) {
            [self.player.currentPlayerManager play];
        }
    } else {
        self.slider.isdragging = NO;
    }
    if (self.sliderValueChanged) self.sliderValueChanged(value);
}

- (void)sliderValueChanged:(float)value {
    if (self.player.totalTime == 0) {
        self.slider.value = 0;
        return;
    }
    self.slider.isdragging = YES;
    NSString *currentTimeString = [ZFUtilities convertTimeSecond:self.player.totalTime*value];
    self.currentTimeLabel.text = currentTimeString;
    if (self.sliderValueChanging) self.sliderValueChanging(value,self.slider.isForward);
}

- (void)sliderTapped:(float)value {
    if (self.player.totalTime > 0) {
        self.slider.isdragging = YES;
        @weakify(self)
        [self.player seekToTime:self.player.totalTime*value completionHandler:^(BOOL finished) {
            @strongify(self)
            if (finished) {
                self.slider.isdragging = NO;
                [self.player.currentPlayerManager play];
            }
        }];
    } else {
        self.slider.isdragging = NO;
        self.slider.value = 0;
    }
}

#pragma mark -

/// 重置ControlView
- (void)resetControlView {
    self.slider.value                = 0;
    self.slider.bufferValue          = 0;
    self.currentTimeLabel.text       = @"00:00";
    self.totalTimeLabel.text         = @"00:00";
    self.backgroundColor             = [UIColor clearColor];
    self.playOrPauseBtn.selected     = YES;
    self.titleLabel.text             = @"";
    self.topToolView.alpha           = 1;
    self.bottomToolView.alpha        = 1;
    self.isShow                      = NO;
}

- (void)showControlView {
    if(self.replayButton.hidden == NO) {
        //播放完成，显示重新播放，只显示返回按钮
        self.topToolView.alpha       = 1;
        self.topToolView.zf_y        = 0;
        self.isShow                      = YES;
        return;
    }
    
    self.isShow                      = YES;
    self.playOrPauseBtn.alpha        = 1;
    if (self.player.isLockedScreen) {
        self.topToolView.zf_y        = -self.topToolView.zf_height;
        self.bottomToolView.zf_y     = self.zf_height;
    } else {
        self.topToolView.zf_y        = 0;
        self.bottomToolView.zf_y     = self.zf_height - self.bottomToolView.zf_height;
    }
    self.player.statusBarHidden      = NO;
    if (self.player.isLockedScreen) {
        self.topToolView.alpha       = 0;
        self.bottomToolView.alpha    = 0;
    } else {
        self.topToolView.alpha       = 1;
        self.bottomToolView.alpha    = 1;
    }
}

- (void)hideControlView {
    self.isShow                      = NO;
    self.topToolView.zf_y            = -self.topToolView.zf_height;
    self.bottomToolView.zf_y         = self.zf_height;
    self.player.statusBarHidden      = YES;
    self.topToolView.alpha           = 0;
    self.bottomToolView.alpha        = 0;
    self.playOrPauseBtn.alpha        = 0;
    
}

- (BOOL)shouldResponseGestureWithPoint:(CGPoint)point withGestureType:(ZFPlayerGestureType)type touch:(nonnull UITouch *)touch {
    CGRect sliderRect = [self.bottomToolView convertRect:self.slider.frame toView:self];
    if (CGRectContainsPoint(sliderRect, point)) {
        return NO;
    }
    if (self.player.isLockedScreen && type != ZFPlayerGestureTypeSingleTap) { // 锁定屏幕方向后只相应tap手势
        return NO;
    }
    return YES;
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer presentationSizeChanged:(CGSize)size {
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    if (!self.slider.isdragging) {
        NSString *currentTimeString = [ZFUtilities convertTimeSecond:currentTime];
        self.currentTimeLabel.text = currentTimeString;
        NSString *totalTimeString = [ZFUtilities convertTimeSecond:totalTime];
        self.totalTimeLabel.text = totalTimeString;
        self.slider.value = videoPlayer.progress;
    }
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer bufferTime:(NSTimeInterval)bufferTime {
    self.slider.bufferValue = videoPlayer.bufferProgress;
}

- (void)showTitle:(NSString *)title fullScreenMode:(ZFFullScreenMode)fullScreenMode {
    self.titleLabel.text = title;
    self.player.orientationObserver.fullScreenMode = fullScreenMode;
}

/// 调节播放进度slider和当前时间更新
- (void)sliderValueChanged:(CGFloat)value currentTimeString:(NSString *)timeString {
    self.slider.value = value;
    self.currentTimeLabel.text = timeString;
    self.slider.isdragging = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.slider.sliderBtn.transform = CGAffineTransformMakeScale(1.2, 1.2);
    }];
}

/// 滑杆结束滑动
- (void)sliderChangeEnded {
    self.slider.isdragging = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.slider.sliderBtn.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - action
-(void)rePlayVideo:(id)sender{
    [self.player.currentPlayerManager replay];
    [self.replayButton setHidden:YES];
    
    if([self.player.umengEventPath isEqualToString:@"homefeed"]){
        [MobClick event:@"home_feeds_itemreplay"];
    }else if([self.player.umengEventPath isEqualToString:@"answerlist"]){
        [MobClick event:@"answerlist_listitemreplay"];
    }
}

-(void)muteButtonClickAction:(UIButton*)sender{
    self.player.currentPlayerManager.muted = !self.player.currentPlayerManager.isMuted;
    [self resetMuteButton];
    if([self.player.umengEventPath isEqualToString:@"answerlist"]){
           [MobClick event:@"answerlist_listitemsilence"];
       }
}

- (void)backBtnClickAction:(UIButton *)sender {
    self.player.lockedScreen = NO;
    self.muteBtn.selected = NO;
    if (self.player.orientationObserver.supportInterfaceOrientation & ZFInterfaceOrientationMaskPortrait) {
        [self.player enterFullScreen:NO animated:NO];
    }
    if (self.backBtnClickCallback) {
        self.backBtnClickCallback();
    }
}

- (void)playPauseButtonClickAction:(UIButton *)sender {
    [self playOrPause];
}

/// 根据当前播放状态取反
- (void)playOrPause {
    self.playOrPauseBtn.selected = !self.playOrPauseBtn.isSelected;
    self.playOrPauseBtn.isSelected? [self.player.currentPlayerManager play]: [self.player.currentPlayerManager pause];
}

- (void)playBtnSelectedState:(BOOL)selected {
    self.playOrPauseBtn.selected = selected;
}

- (void)lockButtonClickAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.player.lockedScreen = sender.selected;
}

#pragma mark - ZFPlayerControlViewDelegate
/// 手势筛选，返回NO不响应该手势
- (BOOL)gestureTriggerCondition:(ZFPlayerGestureControl *)gestureControl gestureType:(ZFPlayerGestureType)gestureType gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer touch:(nonnull UITouch *)touch {
    CGPoint point = [touch locationInView:self];
    if (self.player.isSmallFloatViewShow && !self.player.isFullScreen && gestureType != ZFPlayerGestureTypeSingleTap) {
        return NO;
    }
    if (self.player.isFullScreen) {
        self.player.disablePanMovingDirection = ZFPlayerDisablePanMovingDirectionAll;
        return [self shouldResponseGestureWithPoint:point withGestureType:gestureType touch:touch];
    } else {
        return NO;
    }
}

/// 单击手势事件
- (void)gestureSingleTapped:(ZFPlayerGestureControl *)gestureControl {
    if (!self.player) return;
    if (self.player.isSmallFloatViewShow && !self.player.isFullScreen) {
        [self.player enterFullScreen:YES animated:YES];
    } else {
        if (self.controlViewAppeared) {
            [self hideControlViewWithAnimated:YES];
        } else {
            /// 显示之前先把控制层复位，先隐藏后显示
            [self hideControlViewWithAnimated:NO];
            [self showControlViewWithAnimated:YES];
        }
    }
}

/// 双击手势事件
- (void)gestureDoubleTapped:(ZFPlayerGestureControl *)gestureControl {
    if (self.player.isFullScreen) {
        [self playOrPause];
    } else {
      
    }
}

/// 开始滑动手势事件
- (void)gestureBeganPan:(ZFPlayerGestureControl *)gestureControl panDirection:(ZFPanDirection)direction panLocation:(ZFPanLocation)location {
    if (direction == ZFPanDirectionH) {
        self.sumTime = self.player.currentTime;
    }
}

/// 滑动中手势事件
- (void)gestureChangedPan:(ZFPlayerGestureControl *)gestureControl panDirection:(ZFPanDirection)direction panLocation:(ZFPanLocation)location withVelocity:(CGPoint)velocity {
    if (direction == ZFPanDirectionH) {
        // 每次滑动需要叠加时间
        self.sumTime += velocity.x / 200;
        // 需要限定sumTime的范围
        NSTimeInterval totalMovieDuration = self.player.totalTime;
        if (totalMovieDuration == 0) return;
        if (self.sumTime > totalMovieDuration) self.sumTime = totalMovieDuration;
        if (self.sumTime < 0) self.sumTime = 0;
        BOOL style = NO;
        if (velocity.x > 0) style = YES;
        if (velocity.x < 0) style = NO;
        if (velocity.x == 0) return;
        [self sliderValueChangingValue:self.sumTime/totalMovieDuration isForward:style];
    } else if (direction == ZFPanDirectionV) {
    }
}

/// 取消延时隐藏controlView的方法
- (void)cancelAutoFadeOutControlView {
    if (self.afterBlock) {
        dispatch_block_cancel(self.afterBlock);
        self.afterBlock = nil;
    }
}

- (void)autoFadeOutControlView {
    self.controlViewAppeared = YES;
    [self cancelAutoFadeOutControlView];
    @weakify(self)
    self.afterBlock = dispatch_block_create(0, ^{
        @strongify(self)
        [self hideControlViewWithAnimated:YES];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5f * NSEC_PER_SEC)), dispatch_get_main_queue(),self.afterBlock);
}

/// 滑动结束手势事件
- (void)gestureEndedPan:(ZFPlayerGestureControl *)gestureControl panDirection:(ZFPanDirection)direction panLocation:(ZFPanLocation)location {
    @weakify(self)
    if (direction == ZFPanDirectionH && self.sumTime >= 0 && self.player.totalTime > 0) {
        [self.player seekToTime:self.sumTime completionHandler:^(BOOL finished) {
            @strongify(self)
            /// 左右滑动调节播放进度
            [self sliderChangeEnded];
            if (self.controlViewAppeared) {
                [self autoFadeOutControlView];
            }
        }];
        if (self.seekToPlay) {
            [self.player.currentPlayerManager play];
        }
        self.sumTime = 0;
    }
}

/// 捏合手势事件，这里改变了视频的填充模式
- (void)gesturePinched:(ZFPlayerGestureControl *)gestureControl scale:(float)scale {
//    if (scale > 1) {
//        self.player.currentPlayerManager.scalingMode = ZFPlayerScalingModeAspectFill;
//    } else {
//        self.player.currentPlayerManager.scalingMode = ZFPlayerScalingModeAspectFit;
//    }
}

/// 准备播放
- (void)videoPlayer:(ZFPlayerController *)videoPlayer prepareToPlay:(NSURL *)assetURL {
    [self hideControlViewWithAnimated:NO];
}

//播放失败 am
-(void)videoPlayerPlayFailed:(ZFPlayerController *)videoPlayer error:(id)error{
    ZLLog(@"-----videoPlayerPlayFailed-----error:%@",error);
    self.failBtn.hidden = NO;
    [self.activity stopAnimating];
}

/// 播放状态改变
- (void)videoPlayer:(ZFPlayerController *)videoPlayer playStateChanged:(ZFPlayerPlaybackState)state {
    if (state == ZFPlayerPlayStatePlaying) {
        [self playBtnSelectedState:YES];
        [self resetMuteButton];
        self.failBtn.hidden = YES;
        /// 开始播放时候判断是否显示loading
        if (videoPlayer.currentPlayerManager.loadState == ZFPlayerLoadStateStalled && !self.prepareShowLoading) {
            [self.activity startAnimating];
        } else if ((videoPlayer.currentPlayerManager.loadState == ZFPlayerLoadStateStalled || videoPlayer.currentPlayerManager.loadState == ZFPlayerLoadStatePrepare) && self.prepareShowLoading) {
            [self.activity startAnimating];
        }else if(videoPlayer.currentPlayerManager.loadState == ZFPlayerLoadStateUnknown && !self.prepareShowLoading){
            [self.activity startAnimating];
        }
    } else if (state == ZFPlayerPlayStatePaused) {
        
        [self playBtnSelectedState:NO];
        /// 暂停的时候隐藏loading
        [self.activity stopAnimating];
        self.failBtn.hidden = YES;
    } else if (state == ZFPlayerPlayStatePlayFailed) {
        self.failBtn.hidden = NO;
        [self.activity stopAnimating];
    }else if(state == ZFPlayerPlayStatePlayComplete){
        [self showReplayButton];
    }else{
        
    }
}

/// 加载状态改变
- (void)videoPlayer:(ZFPlayerController *)videoPlayer loadStateChanged:(ZFPlayerLoadState)state {
    if (state == ZFPlayerLoadStatePrepare) {
        self.coverImageView.hidden = NO;
        
        [self playBtnSelectedState:videoPlayer.currentPlayerManager.shouldAutoPlay];
    } else if (state == ZFPlayerLoadStatePlaythroughOK || state == ZFPlayerLoadStatePlayable) {
        self.coverImageView.hidden = YES;
//        if (self.effectViewShow) {
//            self.effectView.hidden = NO;
//            } else {
//            self.effectView.hidden = YES;
//            self.player.currentPlayerManager.view.backgroundColor = [UIColor blackColor];
//        }
    }
    if (state == ZFPlayerLoadStateStalled && videoPlayer.currentPlayerManager.isPlaying && !self.prepareShowLoading) {
        [self.activity startAnimating];
    } else if ((state == ZFPlayerLoadStateStalled || state == ZFPlayerLoadStatePrepare) && videoPlayer.currentPlayerManager.isPlaying && self.prepareShowLoading) {
        [self.activity startAnimating];
    }else{
        [self.activity stopAnimating];
    }
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer orientationWillChange:(ZFOrientationObserver *)observer {
    self.hidden = !observer.isFullScreen;
    if (videoPlayer.isSmallFloatViewShow) {
        if (observer.isFullScreen) {
            self.controlViewAppeared = NO;
            [self cancelAutoFadeOutControlView];
        }
    }
    if (self.controlViewAppeared) {
        [self showControlViewWithAnimated:NO];
    } else {
        [self hideControlViewWithAnimated:NO];
    }
}

/// 视频view已经旋转
- (void)videoPlayer:(ZFPlayerController *)videoPlayer orientationDidChanged:(ZFOrientationObserver *)observer {
    if (self.controlViewAppeared) {
        [self showControlViewWithAnimated:NO];
    } else {
        [self hideControlViewWithAnimated:NO];
    }
}

/// 锁定旋转方向
- (void)lockedVideoPlayer:(ZFPlayerController *)videoPlayer lockedScreen:(BOOL)locked {
    [self showControlViewWithAnimated:YES];
}

/// 隐藏控制层
- (void)hideControlViewWithAnimated:(BOOL)animated {
    self.controlViewAppeared = NO;
    [UIView animateWithDuration:animated ? 0.25f : 0 animations:^{
        if (self.player.isFullScreen) {
            [self hideControlView];
        }
    } completion:^(BOOL finished) {
    }];
}

/// 显示控制层
- (void)showControlViewWithAnimated:(BOOL)animated {
    self.controlViewAppeared = YES;
    [self autoFadeOutControlView];
    [UIView animateWithDuration:animated ? 0.25f : 0 animations:^{
        if (self.player.isFullScreen) {
            [self showControlView];
        }
    } completion:^(BOOL finished) {
    }];
}


#pragma mark - Private Method

- (void)sliderValueChangingValue:(CGFloat)value isForward:(BOOL)forward {
    NSString *draggedTime = [ZFUtilities convertTimeSecond:self.player.totalTime*value];
    //NSString *totalTime = [ZFUtilities convertTimeSecond:self.player.totalTime];
    [self sliderValueChanged:value currentTimeString:draggedTime];
}

/// 加载失败
- (void)failBtnClick:(UIButton *)sender {
    self.failBtn.hidden = YES;
    [self.player.currentPlayerManager reloadPlayer];
    [self.activity startAnimating];
    
    if([self.player.umengEventPath isEqualToString:@"homefeed"]){
        [MobClick event:@"home_feeds_itemgoon"];
    }else if([self.player.umengEventPath isEqualToString:@"answerlist"]){
        [MobClick event:@"answerlist_listitemgoon"];
    }
}

#pragma mark - setter

- (void)setPlayer:(ZFPlayerController *)player {
    _player = player;;
    /// 解决播放时候黑屏闪一下问题
    [player.currentPlayerManager.view insertSubview:self.bgImgView atIndex:0];
    [self.bgImgView addSubview:self.effectView];
    [player.currentPlayerManager.view insertSubview:self.coverImageView atIndex:1];
    self.coverImageView.frame = player.currentPlayerManager.view.bounds;
    self.coverImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.bgImgView.frame = player.currentPlayerManager.view.bounds;
    self.bgImgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.effectView.frame = self.bgImgView.bounds;
    self.coverImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)setSeekToPlay:(BOOL)seekToPlay {
    _seekToPlay = seekToPlay;
}

#pragma mark - UI
- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.userInteractionEnabled = YES;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _coverImageView;
}
- (UIImageView *)bgImgView {
    if (!_bgImgView) {
        _bgImgView = [[UIImageView alloc] init];
        _bgImgView.userInteractionEnabled = YES;
    }
    return _bgImgView;
}
-(UIActivityIndicatorView*)activity{
    if(!_activity){
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activity.hidesWhenStopped = YES;
    }
    return _activity;
}


- (UIView *)topToolView {
    if (!_topToolView) {
        _topToolView = [[UIView alloc] init];
        _topToolView.backgroundColor = [UIColor clearColor];
    }
    return _topToolView;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:ImageNamed(@"video_exit_nav_btn") forState:UIControlStateNormal];
    }
    return _backBtn;
}

- (UIButton *)muteBtn {
    if (!_muteBtn) {
        _muteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_muteBtn setImage:ImageNamed(@"video_audio_open") forState:UIControlStateNormal];
        [_muteBtn setImage:ImageNamed(@"video_audio_close") forState:UIControlStateSelected];
    }
    return _muteBtn;
}

- (UIView *)bottomToolView {
    if (!_bottomToolView) {
        _bottomToolView = [[UIView alloc] init];
        _bottomToolView.backgroundColor = [UIColor clearColor];
    }
    return _bottomToolView;
}

- (UIButton *)playOrPauseBtn {
    if (!_playOrPauseBtn) {
        _playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playOrPauseBtn setImage:ImageNamed(@"video_player_play") forState:UIControlStateNormal];
        [_playOrPauseBtn setImage:ImageNamed(@"video_player_stop") forState:UIControlStateSelected];
    }
    return _playOrPauseBtn;
}

-(UIView*)replayButtonMaskView{
    if(!_replayButtonMaskView){
        _replayButtonMaskView = [[UIView alloc] init];
        _replayButtonMaskView.backgroundColor = UIColorFromHEXWithAlpha(0x000000, 0.5f);
        _replayButtonMaskView.hidden = YES;
    }
    return _replayButtonMaskView;
}

-(UIButton*)replayButton{
    if(!_replayButton){
        _replayButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
        [_replayButton setBackgroundImage:[UIImage ctRoundRectImageWithFillColor:[UIColor clearColor] borderColor:[UIColor whiteColor] borderWidth:1 cornerRadius:14] forState:UIControlStateNormal];
        [_replayButton setImage:[[UIImage imageNamed:@"video_replay_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [_replayButton setTitle:@" 重播" forState:UIControlStateNormal];
        _replayButton.titleLabel.font = kSystemFont(14);
        [_replayButton setHidden:YES];
        [_replayButton addTarget:self action:@selector(rePlayVideo:) forControlEvents:UIControlEventTouchUpInside];
        [_replayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _replayButton;
}

- (UIButton *)exitButton {
    if (!_exitButton) {
        _exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_exitButton setImage:ImageNamed(@"video_exit_full_btn") forState:UIControlStateNormal];
        [_exitButton setImage:ImageNamed(@"video_exit_full_btn") forState:UIControlStateSelected];
    }
    return _exitButton;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.font = [UIFont systemFontOfSize:14.0f];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentTimeLabel;
}

- (ZFSliderView *)slider {
    if (!_slider) {
        _slider = [[ZFSliderView alloc] init];
        _slider.delegate = self;
        _slider.maximumTrackTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _slider.bufferTrackTintColor  = UIColorFromHEXWithAlpha(0xFF6885, 0.5f);
        _slider.minimumTrackTintColor = [UIColor ctMainColor];
        [_slider setThumbImage:ImageNamed(@"video_slider_thumb") forState:UIControlStateNormal];
        _slider.sliderHeight = 2;
    }
    return _slider;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.font = [UIFont systemFontOfSize:14.0f];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _totalTimeLabel;
}

- (UIButton *)failBtn {
    if (!_failBtn) {
        _failBtn = [UIButton buttonWithType:(UIButtonTypeSystem)];
        [_failBtn setBackgroundImage:[UIImage ctRoundRectImageWithFillColor:[UIColor clearColor] borderColor:[UIColor whiteColor] borderWidth:1 cornerRadius:20] forState:UIControlStateNormal];
        [_failBtn setImage:[[UIImage imageNamed:@"video_replay_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [_failBtn setTitle:@" 重新加载" forState:UIControlStateNormal];
        _failBtn.titleLabel.font = kSystemFont(14);
        [_failBtn addTarget:self action:@selector(failBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_failBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _failBtn.hidden = YES;
    }
    return _failBtn;
}

@end
