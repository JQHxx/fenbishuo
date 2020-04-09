//
//  CTFAudioBrowseView.m
//  ChalkTalks
//
//  Created by vision on 2020/1/15.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFAudioBrowseView.h"
#import "CTFAudioPlayerManager.h"

@interface CTFAudioBrowseView (){
    BOOL  isTimering;
}

@property (nonatomic,strong) UIView                  *playView;
@property (nonatomic,strong) CTAnimationView         *animationView;
@property (nonatomic,strong) UILabel                 *secondsLab;
@property (nonatomic,strong) CTAnimationView         *loadingView;
@property (nonatomic,strong) NSDictionary            *currentAudio;
@property (nonatomic,strong) dispatch_source_t       timer;          //计时器



@end

@implementation CTFAudioBrowseView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlayFinished) name:kAudioPlayFinishedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlayStart) name:kAudioPlayStartTimerNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlayFinished) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlayFinished) name:AVAudioSessionInterruptionNotification object:nil];
    }
    return self;
}

#pragma mark 播放音频
-(void)playAudioAction:(UITapGestureRecognizer *)sender{
    BOOL isPlaying;
    if ([CTFAudioPlayerManager sharedCTFAudioPlayerManager].isPlaying) {
        [self stopCurrentAudioPlay];
        isPlaying = NO;
    }else{
        [[CTFAudioPlayerManager sharedCTFAudioPlayerManager] playAudioWithUrl:[self.currentAudio safe_stringForKey:@"url"]];
        [self startLoading];
        isPlaying = YES;
    }
    if ([self.browseDelegate respondsToSelector:@selector(audioBrowseView:didPlayAudio:)]) {
        [self.browseDelegate audioBrowseView:self didPlayAudio:isPlaying];
    }
}

#pragma mark -- Notification
#pragma mark 音频播放停止
-(void)audioPlayFinished{
    [self stopCurrentAudioPlay];
    [self endTimeCount];
}

#pragma mark 开始计时
-(void)audioPlayStart{
    if (self.loadingView) {
        [self.loadingView stop];
        [self.loadingView removeFromSuperview];
        self.loadingView = nil;
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.secondsLab.alpha = 1;
    }];
    [self.animationView play];
    [self startTimeCount];
}

#pragma mark -- Setters
#pragma mark 语图数据
-(void)setAudioImages:(NSArray<AudioImageModel *> *)audioImages{
    _audioImages = audioImages;
}

#pragma mark 设置当前页
-(void)setItemIndex:(NSInteger)itemIndex{
    _itemIndex = itemIndex;
    [self setupPlayView];
}

#pragma mark -- Private methods
#pragma mark 播放音频
-(void)playAudioWithShowAnimation:(BOOL)showAnimation{
    if (showAnimation) {
        [self.animationView play];
        [self startTimeCount];
    }else{
        [self.animationView stop];
        [self endTimeCount];
    }
}

#pragma makr 开始加载
- (void)startLoading{
    if (self.loadingView) {
        [self.loadingView removeFromSuperview];
        self.loadingView = nil;
    }
    self.secondsLab.alpha = 0;
    CTAnimationView *loadingView = [[CTAnimationView alloc] initWithName:@"audio_loading"];
    loadingView.animationMode = CTAnimationModeLoop;
    loadingView.frame = CGRectMake(0, 0, 25, 25);
    loadingView.center = self.secondsLab.center;
    [self.playView addSubview:loadingView];
    self.loadingView = loadingView;
    [self.loadingView play];
}

#pragma mark 停止当前播放
-(void)stopCurrentAudioPlay{
    if (self.playView) {
        [self.animationView stop];
    }
    [[CTFAudioPlayerManager sharedCTFAudioPlayerManager] endPlay];
    [self endTimeCount];
}

#pragma mark 开始计时
-(void)startTimeCount{
    if (self.playView&&!isTimering) {
       if (_timer == nil) {
           AudioImageModel *model = [self.audioImages safe_objectAtIndex:self.itemIndex];
           NSInteger duration = [model.audio safe_integerForKey:@"duration"]/1000.0+0.5;
           NSInteger playTime = [CTFAudioPlayerManager sharedCTFAudioPlayerManager].playTime;
           __block NSInteger timeout = duration-playTime;// 倒计时时间
           if (timeout!=0) {
               kSelfWeak;
               isTimering = YES;
               dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
               _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
               dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC,  0); //每秒执行
               dispatch_source_set_event_handler(_timer, ^{
                   if(timeout < 0){ //  当倒计时结束时做需要的操作:
                        dispatch_source_cancel(weakSelf.timer);
                       weakSelf.timer = nil;
                       self->isTimering = NO;
                   } else {
                       NSInteger seconds = timeout % (duration+1);
                       dispatch_async(dispatch_get_main_queue(), ^{
                           weakSelf.secondsLab.text = [NSString stringWithFormat:@"%ld\"",seconds];
                       });
                       timeout--;
                   }
               });
               dispatch_resume(_timer);
           }
       }
    }
}

#pragma mark 停止计时
-(void)endTimeCount{
    if (self.playView) {
        if(self.timer){
            dispatch_source_cancel(_timer);
            _timer = nil;
        }
        isTimering = NO;
        
        NSInteger timeCount = [self.currentAudio safe_integerForKey:@"duration"]/1000.0+0.5;
        self.secondsLab.text = [NSString stringWithFormat:@"%ld\"",timeCount];
    }
}

#pragma mark 创建音频播放视图
- (void)setupPlayView{
    if (self.playView) {
        [self.playView removeFromSuperview];
        self.playView = nil;
    }
    AudioImageModel *model = [self.audioImages safe_objectAtIndex:self.itemIndex];
    if (kIsEmptyObject(model.audio)) return;
    
    self.currentAudio = model.audio;
    CGFloat playViewWidth;
    NSString *name;
    CGFloat animWidth;
    NSInteger duration = [self.currentAudio safe_integerForKey:@"duration"]/1000.0+0.5;
    if (duration<6) {
        playViewWidth = 85;
        name = @"audio5";
        animWidth = 90;
    }else if (duration>10){
        playViewWidth = 150;
        name = @"audio15";
        animWidth = 160;
    }else{
        playViewWidth = 110;
        name = @"audio10";
        animWidth = 114;
    }
    UIView *playView = [[UIView alloc] initWithFrame:CGRectMake((kScreen_Width-playViewWidth)/2.0, kScreen_Height-(kStatusBar_Height>20?138:108), playViewWidth, 38)];
    playView.backgroundColor = [UIColor ctMainColor];
    playView.layer.cornerRadius = 19;
    [playView addTapPressed:@selector(playAudioAction:) target:self];
    [self addSubview:playView];
    self.playView = playView;
    
    CTAnimationView *animationView = [[CTAnimationView alloc] initWithName:name];
    animationView.animationMode = CTAnimationModeLoop;
    animationView.frame = CGRectMake(0, 0, animWidth, 38);
    [self.playView addSubview:animationView];
    self.animationView = animationView;
    
    UILabel *secondsLab = [[UILabel alloc] initWithFrame:CGRectMake(playViewWidth-30, 10, 20, 18)];
    secondsLab.textColor = [UIColor whiteColor];
    secondsLab.font = [UIFont regularFontWithSize:14];
    secondsLab.text = [NSString stringWithFormat:@"%ld\"",duration];
    [self.playView addSubview:secondsLab];
    self.secondsLab = secondsLab;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAudioPlayFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAudioPlayStartTimerNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
}

@end
