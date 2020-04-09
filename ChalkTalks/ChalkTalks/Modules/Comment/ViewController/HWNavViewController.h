//
//  HWNavViewController.h
//  ChalkTalks
//
//  Created by vision on 2020/3/21.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DismissCallBack)(BOOL needReload, NSInteger commentCount);

NS_ASSUME_NONNULL_BEGIN

@interface HWNavViewController : UINavigationController

@property (nonatomic, copy ) DismissCallBack dismiss;

@end

NS_ASSUME_NONNULL_END
