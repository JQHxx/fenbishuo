//
//  OpenRoutesManager.h
//  StarryNight
//
//  Created by zingwin on 2017/1/22.
//  Copyright © 2017年 zwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString* const kMainPageViewController;
extern NSString* const kVoteViewController;
extern NSString* const kMessageViewController;
extern NSString* const kMineViewController;
extern NSString* const kLoginViewController;
extern NSString* const kPublishTopicViewController;
extern NSString* const kPhoneLoginViewController;
extern NSString* const kbindPhoneViewController;
extern NSString* const kCTFTopicDetailsVC;
extern NSString* const kCTFPublishImageViewpointVC;
extern NSString* const kCTFPublishVideoViewpointVC;
extern NSString* const kCTFHomePageVC;
extern NSString* const kCTFPickVideoCoverVC;
extern NSString* const kCTFDraftBoxVC;


#define APPROUTE(kcls) [[OpenRoutesManager shareInstance] routeByCls:kcls];
#define VIEWCONTROLLER(kcls) [[OpenRoutesManager shareInstance] viewControllerForCls:kcls];
#define ROUTER ([OpenRoutesManager shareInstance])

/// 全局路由类
@interface OpenRoutesManager : NSObject
+(id)shareInstance;

/// 通过vc字符串导航
/// @param kcls  如需传入参数，使用 kcls?userid=11233&cid=12
-(void)routeByCls:(NSString*)kcls;


/// 通过vc字符串导航
/// @param kcls  导航类，这个不接受?参数
/// @param param 参数字典 @{@"user_id":@"2",@"sex":@(1)};
-(void)routeByCls:(NSString*)kcls
        withParam:(NSDictionary*)param;


/// 路由导航
/// @param kcls  类字符串
/// @param param 参数字典 @{@"user_id":@"2",@"sex":@(1)};
/// @param animation 是否需要动画
/// @param presentWithNavBar  只针对present有效，是否需要自动设置为UINavigationController的rootvc, 默认不设置
-(void)routeByCls:(NSString*)kcls
            param:(NSDictionary*)param
        animation:(BOOL)animation
presentWithNavBar:(BOOL)presentWithNavBar;


/// 通过类别初始化vc
/// @param kcls  kcls
-(UIViewController*)viewControllerForCls:(NSString*)kcls;


/// 获取最顶层的vc
-(UIViewController*)topViewController;
@end
