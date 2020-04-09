//
//  CTFTextField.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/1/2.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFTextField.h"

@implementation CTFTextField

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController) {
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    return NO;
}

@end
