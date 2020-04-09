//
//  CTFAudioCollectionViewCell.m
//  ChalkTalks
//
//  Created by vision on 2020/1/14.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFAudioCollectionViewCell.h"
#import "NSURL+Ext.h"

@interface CTFAudioCollectionViewCell ()

@property (nonatomic,strong) UIImageView      *audioImageView;


@end

@implementation CTFAudioCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.audioImageView];
        [self.contentView addSubview:self.playView];
    }
    return self;
}

#pragma mark 标识
+(NSString*)identifier{
    return NSStringFromClass(self);
}


#pragma mark -- Public methods
#pragma mark 填充数据
-(void)displayCellWithModel:(AudioImageModel *)model{
    [self.audioImageView sd_setImageWithURL:[NSURL safe_URLWithString:[AppUtils imgUrlForGridSingle:model.url]] placeholderImage:[UIImage imageNamed:@"audio_image_placeholder"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (error) {
            LogError(error.localizedDescription);
        };
    }];
    
    NSDictionary *myAudio = model.audio;
    if (myAudio.count>0) {
        self.playView.hidden = NO;
        self.playView.audio = myAudio;
        
        CGFloat playViewWidth;
        NSInteger duration = [myAudio safe_integerForKey:@"duration"]/1000.0+0.5;
        if (duration<6) {
            playViewWidth = 85;
        }else if (duration>10){
            playViewWidth = 150;
        }else{
            playViewWidth = 110;
        }
        self.playView.frame = CGRectMake(16, self.audioImageView.bottom-50, playViewWidth, 38);
    }else{
        self.playView.hidden = YES;
    }   
}

#pragma mark -- Getters
#pragma mark - 图片
- (UIImageView *)audioImageView {
    if (!_audioImageView) {
        _audioImageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _audioImageView.contentMode = UIViewContentModeScaleAspectFill;
        _audioImageView.backgroundColor = [UIColor ctColorEE];
        [_audioImageView setBorderWithCornerRadius:5.0 type:UIViewCornerTypeAll];
    }
    return _audioImageView;
}

#pragma mark 音频播放
-(CTFAudioPlayView *)playView{
    if (!_playView) {
        _playView = [[CTFAudioPlayView alloc] init];
    }
    return _playView;
}


@end
