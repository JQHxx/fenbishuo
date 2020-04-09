//
//  CTFAudioPlayView.m
//  ChalkTalks
//
//  Created by vision on 2020/1/14.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFAudioPlayView.h"
#import "UIImage+Size.h"

@interface CTFAudioPlayView ()

@property (nonatomic,strong) CTAnimationView  *animationView;
@property (nonatomic,strong) UILabel          *secondsLab;
@property (nonatomic,strong) CTAnimationView  *loadingView;

@end

@implementation CTFAudioPlayView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ctMainColor];
        self.layer.cornerRadius = 19;

        [self addSubview:self.secondsLab];
    }
    return self;
}

#pragma mark -- Private methods
#pragma mark 创建界面
-(void)layoutSubviews{
    [super layoutSubviews];
    
    NSInteger duration = [self.audio safe_integerForKey:@"duration"];
    NSInteger aDuration = duration/1000.0+0.5;
    NSString *name;
    CGFloat animWidth;
    if (aDuration<6) {
        name = @"audio5";
        animWidth = 90;
    }else if (aDuration>10){
        name = @"audio15";
        animWidth = 160;
    }else{
        name = @"audio10";
        animWidth = 114;
    }
    self.animationView.frame = CGRectMake(0, 0, animWidth, 38);
    
    [self.secondsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-10);
        make.top.mas_equalTo(10);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(18);
    }];
}

#pragma mark -- Public methods
#pragma mark 开始加载
-(void)startLoading{
    if (self.loadingView) {
        [self.loadingView removeFromSuperview];
        self.loadingView = nil;
    }
    self.secondsLab.alpha = 0;
    CTAnimationView *loadingView = [[CTAnimationView alloc] initWithName:@"audio_loading"];
    loadingView.animationMode = CTAnimationModeLoop;
    loadingView.frame = CGRectMake(0, 0, 25, 25);
    loadingView.center = self.secondsLab.center;
    [self addSubview:loadingView];
    self.loadingView = loadingView;
    [self.loadingView play];
}

#pragma mark 加载完成
-(void)endLoading{
    [self.loadingView stop];
    if (self.loadingView) {
        [self.loadingView removeFromSuperview];
        self.loadingView = nil;
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.secondsLab.alpha = 1;
    }];
}

#pragma mark 动画播放
-(void)animationPlay{
    [self endLoading];
    [self.animationView play];
}

#pragma mark  动画停止
-(void)animationStop{
    [self endLoading];
    [self.animationView stop];
}

#pragma mark -- Setters
#pragma mark 填充数据
-(void)setAudio:(NSDictionary *)audio{
    _audio = audio;
    
    NSInteger duration = [audio safe_integerForKey:@"duration"];
    NSInteger aDuration = duration/1000.0+0.5;
    self.secondsLab.text =  [NSString stringWithFormat:@"%ld\"",aDuration];
    
    NSString *name;
    CGFloat animWidth;
    if (aDuration<6) {
        name = @"audio5";
        animWidth = 90;
    }else if (aDuration>10){
        name = @"audio15";
        animWidth = 160;
    }else{
        name = @"audio10";
        animWidth = 114;
    }
    for (UIView *aView in self.subviews) {
        if ([aView isKindOfClass:[CTAnimationView class]]) {
            [aView removeFromSuperview];
        }
    }
    
    CTAnimationView *animationView = [[CTAnimationView alloc] initWithName:name];
    animationView.animationMode = CTAnimationModeLoop;
    animationView.frame = CGRectMake(0, 0, animWidth, 38);
    [self addSubview:animationView];
    self.animationView = animationView;
}

#pragma mark 计时
-(void)setTimeCount:(NSInteger)timeCount{
    _timeCount = timeCount;
    self.secondsLab.text = [NSString stringWithFormat:@"%ld\"",timeCount];
}

#pragma mark -- Getters
#pragma mark 秒
-(UILabel *)secondsLab{
    if (!_secondsLab) {
        _secondsLab = [[UILabel alloc] init];
        _secondsLab.textColor = [UIColor whiteColor];
        _secondsLab.font = [UIFont regularFontWithSize:14];
    }
    return _secondsLab;
}


@end
