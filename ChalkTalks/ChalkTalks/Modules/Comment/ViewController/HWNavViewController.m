//
//  HWNavViewController.m
//  ChalkTalks
//
//  Created by vision on 2020/3/21.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "HWNavViewController.h"
#import <HWPanModal.h>

@interface HWNavViewController ()<HWPanModalPresentable>

@property (nonatomic,assign) NSInteger needRefresh;
@property (nonatomic,assign) NSInteger commentCount;

@end

@implementation HWNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.hidden = YES;
    self.needRefresh = NO;
    self.commentCount = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publishCommentSuccessNotification:) name:kPublishCommentsNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPublishCommentsNotification object:nil];
}

#pragma mark -- HWPanModalPresentable
- (UIScrollView *)panScrollable {
    UIViewController *VC = self.topViewController;
    if ([VC conformsToProtocol:@protocol(HWPanModalPresentable)]) {
        id<HWPanModalPresentable> obj = VC;
        return [obj panScrollable];
    }
    return nil;
}

- (PanModalHeight)longFormHeight {
    UIViewController *VC = self.topViewController;
    if ([VC conformsToProtocol:@protocol(HWPanModalPresentable)]) {
        id<HWPanModalPresentable> obj = VC;
        return [obj longFormHeight];
    }
    return PanModalHeightMake(PanModalHeightTypeMaxTopInset, kStatusBar_Height);
}

- (BOOL)allowScreenEdgeInteractive {
    return NO;
}

- (CGFloat)topOffset {
    return 0;
}

- (BOOL)showDragIndicator {
    return NO;
}

- (void)panModalWillDismiss {
    self.dismiss(self.needRefresh, self.commentCount);
}

- (BOOL)isAutoHandleKeyboardEnabled {
    return NO;
}

- (BOOL)allowsExtendedPanScrolling {
    return YES;
}

#pragma mark -- Notifaciton
#pragma mark 发布评论通知
- (void)publishCommentSuccessNotification:(NSNotification *)notification {
    NSDictionary *dict = notification.object;
    self.needRefresh = YES;
    self.commentCount = [dict safe_integerForKey:@"commentCount"];
}

@end
