//
//  CTFMineVC.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/3/10.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFMineVC : BaseViewController

// 头像点击放大
- (void)headImageControlAction;

// 跳转到个人主页
- (void)homePageButtonAction;

// 点击赞同按钮
- (void)agreeControlAction;

// 跳转到我的粉丝列表界面
- (void)fansControlAction;

// 跳转到我的关注列表界面
- (void)careControlAction;

// 跳转到我的话题界面
- (void)mineTopicButtonAction;

// 跳转到我关心话题界面
- (void)careTopicButtonAction;

// 跳转到我的观点界面
- (void)mineViewPointButtonAction;

@end

NS_ASSUME_NONNULL_END
