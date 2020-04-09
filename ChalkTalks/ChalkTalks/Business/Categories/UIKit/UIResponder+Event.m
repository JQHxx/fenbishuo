//
//  UIResponder+Event.m
//  StarryNight
//
//  Created by zingwin on 2017/3/7.
//  Copyright © 2017年 zwin. All rights reserved.
//

#import "UIResponder+Event.h"

@implementation UIResponder (Event)
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    [[self nextResponder] routerEventWithName:eventName userInfo:userInfo];
}
@end
