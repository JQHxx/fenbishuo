//
//  CTFVideoMuteManager.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/16.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFVideoMuteManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation CTFVideoMuteManager
{
    BOOL isFeedVideoMute; //是否静音
}

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static CTFVideoMuteManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

-(instancetype)init{
    self = [super init];
    if(self){
        isFeedVideoMute = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoMuteChangedInFeedNotification:) name:kVideoMuteChangedInFeedNotification object:nil];
    }
    return self;
}

-(void)dealloc{
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)videoMuteChangedInFeedNotification:(NSNotification*)sender{
    BOOL ismute = [[sender.userInfo safe_objectForKey:@"ismute"] boolValue];
    isFeedVideoMute = ismute;
}

/// 判断是否插了耳机
- (BOOL)isHeadsetPluggedIn {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones]){
            return YES;
        }else if([desc.portType isEqualToString:AVAudioSessionPortBluetoothA2DP]){
            return YES;
        }else if([desc.portType isEqualToString:AVAudioSessionPortBluetoothHFP]){
            return YES;
        }
        
    }
    return NO;
}

-(BOOL)getAudoMuteInFeed{
    return isFeedVideoMute;
}

-(void)setAudoMuteInFeed:(BOOL)isMute{
    isFeedVideoMute = isMute;
}
@end
