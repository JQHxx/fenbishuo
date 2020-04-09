//
//  CTFPreloadVideoManager.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/27.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTFPreloadVideoManager : NSObject
+ (instancetype)sharedInstance;
-(void)preloadVideoUrls:(NSArray*)urlArr;
@end

NS_ASSUME_NONNULL_END
