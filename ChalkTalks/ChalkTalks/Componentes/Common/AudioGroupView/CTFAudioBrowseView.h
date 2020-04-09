//
//  CTFAudioBrowseView.h
//  ChalkTalks
//
//  Created by vision on 2020/1/15.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTFAudioBrowseView;
@protocol CTFAudioBrowseViewDelegate <NSObject>

//是否播放音频
-(void)audioBrowseView:(CTFAudioBrowseView *)browseView didPlayAudio:(BOOL)isPlaying;

@end

@interface CTFAudioBrowseView : UIView

@property (nonatomic, weak )id<CTFAudioBrowseViewDelegate>browseDelegate;
@property (nonatomic, copy )NSArray<AudioImageModel *>*audioImages;
@property (nonatomic,assign)NSInteger  itemIndex;


//播放音频
- (void)playAudioWithShowAnimation:(BOOL)showAnimation;

- (void)startLoading;

//停止当前播放
- (void)stopCurrentAudioPlay;


@end

