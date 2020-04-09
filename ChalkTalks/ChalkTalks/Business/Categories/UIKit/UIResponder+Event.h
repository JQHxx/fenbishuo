//
//  UIResponder+Event.h
//  StarryNight
//
//  Created by zingwin on 2017/3/7.
//  Copyright © 2017年 zwin. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kViewpointDataModelKey = @"kuserinfo_model";
static NSString * const kCellIndexPathKey = @"keventIndexPath_model";

static NSString * const kReloadAnswerCommentEvent = @"kReloadAnswerCommentEvent"; //更新评论数据
static NSString * const kViewpointUserInfoEvent = @"kViewpointUserInfoEvent";
//回答相关
static NSString * const kAnswerMoreEvent = @"kAnswerMoreEvent";  //回答更多
static NSString * const kAnswerCommentEvent = @"kAnswerCommentEvent";  //回答评论
static NSString * const kAnswerDeleteEvent = @"kAnswerDeleteEvent";  //回答删除
static NSString * const kAnswerNotInterestedEvent = @"kAnswerNotInterestedEvent";  //不感兴趣
static NSString * const kAnswerReportEvent = @"kAnswerReportEvent";  //举报回答
static NSString * const kAnswerReportDismissEvent = @"kAnswerReportDismissEvent";  

//评论相关
static NSString * const kCommentReplyEvent = @"kViewpointReplyEvent";  //回复评论
static NSString * const kCommentReliableEvent = @"kViewpointReliableEvent";  //设置靠谱
static NSString * const kCommentMoreHandleEvent = @"kCommentMoreHandleEvent";  //更多操作
static NSString * const kCommentDataModelKey = @"kCommentDataModelKey";     //评论对象

static NSString * const kTopicTitleEvent = @"kTopicTitleEvent";
static NSString * const kViewpointIntroEvent = @"kViewpointIntroEvent";
static NSString * const kFollowUserEvent = @"kFollowUserEvent";

//话题相关
static NSString * const kTopicDataModelKey = @"kTopicDataModelKey";
static NSString * const kTopicLikeEvent = @"kTopicLikeEvent";
static NSString * const kTopicUnlikeEvent = @"kTopicLikeEvent";

static NSString * const kEnterBrowseImageEvent = @"kEnterBrowseImageEvent";
static NSString * const kExitBrowseImageEvent = @"kExitBrowseImageEvent";

//音频播放
static NSString * const kAudioFeedPlayEvent = @"kAudioFeedPlayEvent";
static NSString * const kAudioImageScrollEvent = @"kAudioImageScrollEvent";

@interface UIResponder (Event)
/**
 *  发送一个路由器消息, 对eventName感兴趣的 UIResponsder 可以对消息进行处理
 *
 *  @param eventName 发生的事件名称
 *  @param userInfo  传递消息时, 携带的数据, 数据传递过程中, 会有新的数据添加
 *
 */
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo;

@end
