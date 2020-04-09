//
//  CTFTextView.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/3/7.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFTextView.h"

@implementation CTFTextView

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController) {
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    return !self.forbidMenuView;
}

@end
