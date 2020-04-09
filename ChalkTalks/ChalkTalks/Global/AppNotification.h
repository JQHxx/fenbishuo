//
//  AppNotification.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#ifndef AppNotification_h
#define AppNotification_h

#pragma mark - 软件生命周期的通知
/// 当应用程序已经进入后台时
static NSString * const kApplicationDidEnterBackgroundNotification = @"kApplicationDidEnterBackgroundNotification";

/// 当应用程序将要退出
static NSString * const kApplicationWillTerminateNotification = @"kApplicationWillTerminateNotification";


#pragma mark - 登录相关的通知
/// 微信登录授权成功的通知
static NSString * const kWechatLoginSuccessNotification = @"kWechatLoginSuccessNotification";
/// 微信登录授权失败的通知
static NSString * const kWechatLoginFailedNotification = @"kWechatLoginFailedNotification";

/// 登录成功的广播
static NSString * const kLoginedNotification = @"kLoginedNotification";
/// 退出登录的广播
static NSString * const kLogoutedNotification = @"kLogoutedNotification";



static NSString * const kNetReachabilityNotification = @"kNetReachabilityNotification";
static NSString * const kVideoMuteChangedInFeedNotification = @"kVideoMuteChangedInFeedNotification";

static NSString * const kPublishQuestionSuccessNotification = @"kPublishQuestionSuccessNotification";
static NSString * const kPublishAnswerSuccessNotification = @"kPublishAnswerSuccessNotification";

//发布评论
static NSString * const kPublishCommentsNotification = @"kPublishCommentsNotification";

static NSString * const kAudioPlayFinishedNotification = @"kAudioPlayFinishedNotification";
/// 音频停止播放回调
static NSString * const kAudioStopPlayNotification = @"kAudioStopPlayNotification";
/// 音频播放开始计时
static NSString * const kAudioPlayStartTimerNotification = @"kAudioPlayStartTimerNotification";



#endif /* AppNotification_h */
