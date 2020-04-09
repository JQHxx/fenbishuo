//
//  CTFAudioPlayerManager.m
//  ChalkTalks
//
//  Created by vision on 2020/1/14.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFAudioPlayerManager.h"
#import "NSURL+Ext.h"


@interface CTFAudioPlayerManager (){
    id _timeObserve; //监控进度
    BOOL  canPlay;
}

// 播放器
@property (nonatomic, strong) AVPlayer * player;
// 总时长(秒)
@property (nonatomic,assign) double playDuration;

@end

@implementation CTFAudioPlayerManager

singleton_implementation(CTFAudioPlayerManager)

- (instancetype)init {
   self = [super init];
    if (self) {
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    }
    return self;
}


- (BOOL)isPlaying {
    return self.player.rate == 1;
}

#pragma mark 开始播放
- (void)playAudioWithUrl:(NSString *)url {
    if (kIsEmptyString(url)) {
        [kKeyWindow makeToast:@"无效音频"];
        return;
    }
    if (![url containsString:@"http"]) {
        [kKeyWindow makeToast:@"无效音频"];
        return;
    }
    canPlay = NO;
    ZLLog(@"playAudioWithUrl:%@",url);
    NSURL *myUrl = [NSURL safe_URLWithString:url];
    //重置播放器
    AVPlayerItem * audioItem = [[AVPlayerItem alloc]initWithURL:myUrl];
    if (self.player == nil) {
        self.player = [[AVPlayer alloc]initWithPlayerItem:audioItem];
    }else {
        [self.player replaceCurrentItemWithPlayerItem:audioItem];
    }
    //给当前音频添加监控
    [self addObserver];
}

#pragma mark 停止播放
- (void)endPlay {
    if (self.player == nil) return;
    [self.player pause];
    self.playTime = 0;
    //移除监控
    [self removeObserver];
}

#pragma mark -- NSNotification
#pragma mark 播放结束回调
- (void)playbackFinished:(NSNotification *)notification {
    ZLLog(@"playbackFinished");
    [self endPlay];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAudioPlayFinishedNotification object:nil];

}

#pragma mark - KVO
#pragma mark 添加监听
- (void)addObserver {
    AVPlayerItem * audioItem = self.player.currentItem;
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:audioItem];
    
    kSelfWeak;
    _timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        weakSelf.playTime = CMTimeGetSeconds(time);
        weakSelf.playDuration = CMTimeGetSeconds(audioItem.duration);
    }];
    
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [audioItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [audioItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //观察缓冲数据的状态
    [audioItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    //观察是否达到了可以播放的状态
    [audioItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark 移除监听
- (void)removeObserver {
    AVPlayerItem * songItem = self.player.currentItem;
    [self.player replaceCurrentItemWithPlayerItem:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_timeObserve) {
        [self.player removeTimeObserver:_timeObserve];
        _timeObserve = nil;
    }
    [songItem removeObserver:self forKeyPath:@"status"];
    [songItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [songItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [songItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}

#pragma mark 通过KVO监控播放器状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            canPlay = YES;
        } else if ([playerItem status] == AVPlayerStatusFailed || [playerItem status] == AVPlayerStatusUnknown) {
            canPlay = NO;
            [self.player pause];
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        AVPlayerItem * audioItem = object;
        NSArray * array = audioItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue]; //本次缓冲的时间范围
        NSTimeInterval totalBuffer = CMTimeGetSeconds(timeRange.duration); //缓冲总长度
        ZLLog(@"共缓冲%f,duration:%f",totalBuffer,CMTimeGetSeconds(timeRange.duration));
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){
        //监听播放器在缓冲数据的状态
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
        //由于AVPlayer 缓冲不足就会自动暂停，所以缓存充足了需要手动播放，才能继续播放
        if (canPlay) {
            [self.player play];
            [[NSNotificationCenter defaultCenter] postNotificationName:kAudioPlayStartTimerNotification object:nil];
        }
    }
}

@end
