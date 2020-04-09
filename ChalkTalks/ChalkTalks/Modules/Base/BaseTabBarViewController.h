//
//  BaseTabBarViewController.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseTabBarViewController : UITabBarController
+ (BaseTabBarViewController *)createRootViewController;
@end

NS_ASSUME_NONNULL_END
