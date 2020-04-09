//
//  CTFAudioPlayerManager.h
//  ChalkTalks
//
//  Created by vision on 2020/1/14.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import <AVFoundation/AVFoundation.h>
#import "CTFAudioPlayView.h"



@interface CTFAudioPlayerManager : NSObject

singleton_interface(CTFAudioPlayerManager)

/*
 * 播放状态
 */
@property (nonatomic, assign) BOOL isPlaying;


@property (nonatomic,assign) NSInteger  playTime;

/*
 * 开始播放
 */
- (void)playAudioWithUrl:(NSString *)url;

/*
* 停止播放
*/
- (void)endPlay;

@end

