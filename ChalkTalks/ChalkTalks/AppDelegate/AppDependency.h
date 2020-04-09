//
//  AppDependency.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppDependency : NSObject

+ (void)installAppDependencies:(AppDelegate *)app;

@end

NS_ASSUME_NONNULL_END
