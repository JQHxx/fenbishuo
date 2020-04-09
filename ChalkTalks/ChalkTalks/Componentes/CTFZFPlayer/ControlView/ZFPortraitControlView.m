//
//  ZFPortraitControlView.m
//  ZFPlayer
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ZFPortraitControlView.h"
#import "UIView+ZFFrame.h"
#import "ZFUtilities.h"
#if __has_include(<ZFPlayer/ZFPlayer.h>)
#import <ZFPlayer/ZFPlayer.h>
#else
#import "ZFPlayer.h"
#endif

#import <UMAnalytics/MobClick.h>

@interface ZFPortraitControlView () <ZFSliderViewDelegate>
/// 底部工具栏
@property (nonatomic, strong) UIView *bottomToolView;
/// 顶部工具栏
@property (nonatomic, strong) UIView *topToolView;
/// 声音标志
@property (nonatomic, strong) UIButton *muteBtn;
/// 标题
@property (nonatomic, strong) UILabel *titleLabel;
/// 播放或暂停按钮
@property (nonatomic, strong) UIButton *playOrPauseBtn;
/// 播放的当前时间 
@property (nonatomic, strong) UILabel *currentTimeLabel;
/// 滑杆
@property (nonatomic, strong) ZFSliderView *slider;
/// 视频总时间
@property (nonatomic, strong) UILabel *totalTimeLabel;
/// 全屏按钮
@property (nonatomic, strong) UIButton *fullScreenBtn;

/// 重播蒙层
@property (nonatomic, strong) UIView   *replayLayerView;
@property(nonatomic,  strong) UIButton *replayButton;
@property (nonatomic, assign) BOOL     isShow;

@property (nonatomic, strong) ZFSliderView *bottomSlider;

@end

@implementation ZFPortraitControlView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 添加子控件
        [self addSubview:self.replayLayerView];
        self.replayLayerView.hidden = YES;
        [self addSubview:self.topToolView];
        [self addSubview:self.bottomToolView];
        [self addSubview:self.playOrPauseBtn];
        [self addSubview:self.muteBtn];
        [self addSubview:self.replayButton];
        self.replayButton.hidden = YES;
        [self.topToolView addSubview:self.titleLabel];
        [self.bottomToolView addSubview:self.currentTimeLabel];
        [self.bottomToolView addSubview:self.slider];
        [self.bottomToolView addSubview:self.totalTimeLabel];
        [self.bottomToolView addSubview:self.fullScreenBtn];
        [self addSubview:self.bottomSlider];
        
        // 设置子控件的响应事件
        [self makeSubViewsAction];
        
        [self resetControlView];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)makeSubViewsAction {
    [self.playOrPauseBtn addTarget:self action:@selector(playPauseButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.fullScreenBtn addTarget:self action:@selector(fullScreenButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.muteBtn addTarget:self action:@selector(muteButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
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
    
    if([self.player.umengEventPath isEqualToString:@"homefeed"]){
        [MobClick event:@"home_feeds_itemdrag"];
    }else if([self.player.umengEventPath isEqualToString:@"answerlist"]){
        [MobClick event:@"answerlist_listitemdrag"];
    }
}

- (void)sliderValueChanged:(float)value {
    if (self.player.totalTime == 0) {
        self.slider.value = 0;
        self.bottomSlider.value = 0;
        return;
    }
    self.replayLayerView.hidden = self.replayButton.hidden = YES;
    self.slider.isdragging = YES;
    NSString *currentTimeString = [ZFUtilities convertTimeSecond:self.player.totalTime*value];
    self.currentTimeLabel.text = currentTimeString;
    if (self.sliderValueChanging) self.sliderValueChanging(value,self.slider.isForward);
}

- (void)sliderTapped:(float)value {
    if (self.player.totalTime > 0) {
        self.replayLayerView.hidden = self.replayButton.hidden = YES;
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
        self.bottomSlider.value = 0;
    }
}

-(void)showReplayButton{
    self.replayLayerView.hidden = self.replayButton.hidden = NO;
}
-(void)hideReplayButton{
    self.replayLayerView.hidden = self.replayButton.hidden = YES;
}
-(void)resetMuteButton{
    [self.muteBtn setSelected:self.player.currentPlayerManager.isMuted];
}
#pragma mark - action
-(void)muteButtonClickAction:(UIButton*)sender{
    self.player.currentPlayerManager.muted = !self.player.currentPlayerManager.isMuted;
    [self resetMuteButton];
    [[NSNotificationCenter defaultCenter] postNotificationName:kVideoMuteChangedInFeedNotification object:nil userInfo:@{@"ismute":@( self.player.currentPlayerManager.muted)}];
    
    if([self.player.umengEventPath isEqualToString:@"answerlist"]){
        [MobClick event:@"answerlist_listitemsilence"];
    }
}

-(void)rePlayVideo:(id)sender{
    [self.player.currentPlayerManager replay];
    self.replayLayerView.hidden = self.replayButton.hidden = YES;
    
    if([self.player.umengEventPath isEqualToString:@"homefeed"]){
        [MobClick event:@"home_feeds_itemreplay"];
    }else if([self.player.umengEventPath isEqualToString:@"answerlist"]){
        [MobClick event:@"answerlist_listitemreplay"];
    }
}

- (void)playPauseButtonClickAction:(UIButton *)sender {
    [self playOrPause];
}

- (void)fullScreenButtonClickAction:(UIButton *)sender {
    [self.player enterFullScreen:YES animated:YES];
}

/// 根据当前播放状态取反
- (void)playOrPause {
    self.playOrPauseBtn.selected = !self.playOrPauseBtn.isSelected;
    self.playOrPauseBtn.isSelected? [self.player.currentPlayerManager play]: [self.player.currentPlayerManager pause];
}

- (void)playBtnSelectedState:(BOOL)selected {
    self.playOrPauseBtn.selected = selected;
    if (!selected) {
        self.playOrPauseBtn.hidden = NO;
    }
}

#pragma mark - 添加子控件约束
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.replayLayerView.frame = self.bounds;
    
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
    min_h = 40;
    self.topToolView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 15;
    min_y = 5;
    min_w = min_view_w - min_x - 15;
    min_h = 30;
    self.titleLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_w = 40;
    min_h = 40;
    self.muteBtn.frame = CGRectMake(min_view_w-min_w-5, min_y, min_w, min_h);
    
    min_h = 40;
    min_x = 0;
    min_y = min_view_h - min_h;
    min_w = min_view_w;
    self.bottomToolView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 0;
    min_y = 0;
    min_w = 44;
    min_h = min_w;
    self.playOrPauseBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.playOrPauseBtn.center = self.center;

    self.replayButton.frame = CGRectMake(0, 0, 70, 28);
    self.replayButton.zf_centerX = self.zf_centerX;
    self.replayButton.zf_centerY = self.zf_centerY;
    
    min_x = min_margin;
    min_w = 62;
    min_h = 28;
    min_y = (self.bottomToolView.zf_height - min_h)/2;
    self.currentTimeLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_w = 28;
    min_h = min_w;
    min_x = self.bottomToolView.zf_width - min_w - min_margin;
    min_y = 0;
    self.fullScreenBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.fullScreenBtn.zf_centerY = self.currentTimeLabel.zf_centerY;
    
    min_w = 62;
    min_h = 28;
    min_x = self.fullScreenBtn.zf_left - min_w - 4;
    min_y = 0;
    self.totalTimeLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.totalTimeLabel.zf_centerY = self.currentTimeLabel.zf_centerY;
    
    min_x = self.currentTimeLabel.zf_right + 4;
    min_y = 0;
    min_w = self.totalTimeLabel.zf_left - min_x - 4;
    min_h = 30;
    self.slider.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.slider.zf_centerY = self.currentTimeLabel.zf_centerY;
    
    self.bottomSlider.frame = CGRectMake(0, self.bounds.size.height-2, self.bounds.size.width, 2);
    
    self.replayLayerView.hidden = self.replayButton.hidden = YES;
    if (!self.isShow) {
        self.topToolView.zf_y = -self.topToolView.zf_height;
        self.bottomToolView.zf_y = self.zf_height;
        self.playOrPauseBtn.hidden = YES;
    } else {
        self.topToolView.zf_y = 0;
        self.bottomToolView.zf_y = self.zf_height - self.bottomToolView.zf_height;
        self.playOrPauseBtn.hidden = NO;
    }
}

#pragma mark - 

/** 重置ControlView */
- (void)resetControlView {
    self.bottomToolView.alpha        = 1;
    self.slider.value                = 0;
    self.slider.bufferValue          = 0;
    self.bottomSlider.value          = 0;
    self.currentTimeLabel.text       = @"00:00";
    self.totalTimeLabel.text         = @"00:00";
    self.backgroundColor             = [UIColor clearColor];
    self.playOrPauseBtn.selected     = YES;
    self.titleLabel.text             = @"";
}

- (void)showControlView {
    self.topToolView.alpha           = 1;
    self.bottomToolView.alpha        = 1;
    self.isShow                      = YES;
    self.topToolView.zf_y            = 0;
    self.bottomToolView.zf_y         = self.zf_height - self.bottomToolView.zf_height;
    self.playOrPauseBtn.hidden        = !self.replayButton.hidden;
    self.player.statusBarHidden      = NO;
    self.bottomSlider.hidden         = YES;
}

- (void)hideControlView {
    self.isShow                      = NO;
    self.topToolView.zf_y            = -self.topToolView.zf_height;
    self.bottomToolView.zf_y         = self.zf_height;
    self.player.statusBarHidden      = NO;
    if([self.player.currentPlayerManager isPlaying]){
        self.playOrPauseBtn.hidden   = YES;
    }else{
        self.playOrPauseBtn.hidden   = NO;
    }
    self.topToolView.alpha           = 0;
    self.bottomToolView.alpha        = 0;
    self.bottomSlider.hidden         = NO;
}

- (BOOL)shouldResponseGestureWithPoint:(CGPoint)point withGestureType:(ZFPlayerGestureType)type touch:(nonnull UITouch *)touch {
    CGRect sliderRect = [self.bottomToolView convertRect:self.slider.frame toView:self];
    if (CGRectContainsPoint(sliderRect, point)) {
        return NO;
    }
    return YES;
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    if (!self.slider.isdragging) {
        NSString *currentTimeString = [ZFUtilities convertTimeSecond:currentTime];
        self.currentTimeLabel.text = currentTimeString;
        NSString *totalTimeString = [ZFUtilities convertTimeSecond:totalTime];
        self.totalTimeLabel.text = totalTimeString;
        self.slider.value = videoPlayer.progress;
        self.bottomSlider.value = videoPlayer.progress;
    }
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer bufferTime:(NSTimeInterval)bufferTime {
    self.slider.bufferValue = videoPlayer.bufferProgress;
}

- (void)showTitle:(NSString *)title fullScreenMode:(ZFFullScreenMode)fullScreenMode {
    self.titleLabel.text = title;
    self.player.orientationObserver.fullScreenMode = fullScreenMode;
    self.muteBtn.selected = self.player.currentPlayerManager.isMuted;
}

/// 调节播放进度slider和当前时间更新
- (void)sliderValueChanged:(CGFloat)value currentTimeString:(NSString *)timeString {
    self.slider.value = value;
    self.bottomSlider.value = value;
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

#pragma mark - getter
- (UIView *)replayLayerView{
    if (!_replayLayerView) {
        _replayLayerView = [[UIView alloc] init];
        _replayLayerView.backgroundColor = UIColorFromHEXWithAlpha(0x000000, 0.7);
        _replayLayerView.hidden = YES;
    }
    return _replayLayerView;
}

- (UIView *)topToolView {
    if (!_topToolView) {
        _topToolView = [[UIView alloc] init];
        _topToolView.backgroundColor = [UIColor clearColor];
    }
    return _topToolView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
    }
    return _titleLabel;
}

- (UIView *)bottomToolView {
    if (!_bottomToolView) {
        _bottomToolView = [[UIView alloc] init];
        _bottomToolView.backgroundColor = [UIColor clearColor];
    }
    return _bottomToolView;
}

- (UIButton *)muteBtn {
    if (!_muteBtn) {
        _muteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_muteBtn setImage:ImageNamed(@"video_audio_open") forState:UIControlStateNormal];
        [_muteBtn setImage:ImageNamed(@"video_audio_close") forState:UIControlStateSelected];
    }
    return _muteBtn;
}

- (UIButton *)playOrPauseBtn {
    if (!_playOrPauseBtn) {
        _playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playOrPauseBtn setImage:ImageNamed(@"video_player_play") forState:UIControlStateNormal];
        [_playOrPauseBtn setImage:ImageNamed(@"video_player_stop") forState:UIControlStateSelected];
    }
    return _playOrPauseBtn;
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

- (UIButton *)fullScreenBtn {
    if (!_fullScreenBtn) {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenBtn setImage:ImageNamed(@"video_enter_full_btn") forState:UIControlStateNormal];
    }
    return _fullScreenBtn;
}

-(UIButton*)replayButton{
    if(!_replayButton){
        _replayButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
        [_replayButton setBackgroundImage:[UIImage ctRoundRectImageWithFillColor:[UIColor clearColor] borderColor:[UIColor whiteColor] borderWidth:1 cornerRadius:14] forState:UIControlStateNormal];
        [_replayButton setImage:[[UIImage imageNamed:@"video_replay_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [_replayButton setTitle:@" 重播" forState:UIControlStateNormal];
        _replayButton.titleLabel.font = kSystemFont(14);
        [_replayButton addTarget:self action:@selector(rePlayVideo:) forControlEvents:UIControlEventTouchUpInside];
        [_replayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _replayButton;
}

- (ZFSliderView *)bottomSlider {
    if (!_bottomSlider) {
        _bottomSlider = [[ZFSliderView alloc] init];
        _bottomSlider.maximumTrackTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _bottomSlider.bufferTrackTintColor  = UIColorFromHEXWithAlpha(0xFF6885, 0.5f);
        _bottomSlider.minimumTrackTintColor = [UIColor ctMainColor];
        _bottomSlider.isHideSliderBlock = YES;
        _bottomSlider.sliderHeight = 2.0;
    }
    return _bottomSlider;
}

@end
