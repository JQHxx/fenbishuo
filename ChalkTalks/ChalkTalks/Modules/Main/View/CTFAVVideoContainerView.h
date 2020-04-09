//
//  CTFAVVideoContainerView.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/30.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFUtilities.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "CTFNetReachabilityManager.h"
#import "CTFAVVideoInterruptView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFAVVideoContainerView : UIView
@property(nonatomic, copy) void (^ _Nonnull playVideo)(void);

- (void)fillContentWithData:(AnswerModel*)model;
- (void)hideInterruptTipsView;
- (void)showInterruptTipsView:(VideoInterrupted)type;


@end

NS_ASSUME_NONNULL_END
