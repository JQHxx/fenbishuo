//
//  AppDelegate+WX.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "AppDelegate.h"
#import "WXApi.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (WX) <WXApiDelegate>

- (void)configWx;

@end

NS_ASSUME_NONNULL_END
