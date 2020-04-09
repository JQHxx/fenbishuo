//
//  CTFNetReachabilityManager.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/14.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
//#import <AFNetworking/AFNetworking.h>
@import AFNetworking;

NS_ASSUME_NONNULL_BEGIN

@interface CTFNetReachabilityManager : NSObject
+ (instancetype)sharedInstance;
- (void)netMonitoring;
- (AFNetworkReachabilityStatus)currentNetStatus;
@end

NS_ASSUME_NONNULL_END
