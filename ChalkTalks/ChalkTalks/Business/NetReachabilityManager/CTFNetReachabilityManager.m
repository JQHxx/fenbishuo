//
//  CTFNetReachabilityManager.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/14.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFNetReachabilityManager.h"

static CTFNetReachabilityManager *manager = nil;

@implementation CTFNetReachabilityManager
{
    AFNetworkReachabilityStatus curNet;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        curNet = -1;
    }
    return self;
}

//AFNetworkReachabilityStatusUnknown          = -1,
//AFNetworkReachabilityStatusNotReachable     = 0,
//AFNetworkReachabilityStatusReachableViaWWAN = 1,
//AFNetworkReachabilityStatusReachableViaWiFi = 2,

- (void)netMonitoring {
    @weakify(self);
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        @strongify(self);
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                self->curNet = AFNetworkReachabilityStatusReachableViaWWAN;
                [[NSNotificationCenter defaultCenter] postNotificationName:kNetReachabilityNotification object:nil userInfo:nil];
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi: {
                self->curNet = AFNetworkReachabilityStatusReachableViaWiFi;
                [[NSNotificationCenter defaultCenter] postNotificationName:kNetReachabilityNotification object:nil userInfo:nil];
            }
                break;
            default: {
                self->curNet = AFNetworkReachabilityStatusNotReachable;
                [[NSNotificationCenter defaultCenter] postNotificationName:kNetReachabilityNotification object:nil userInfo:nil];
            }
                break;
        }
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (AFNetworkReachabilityStatus)currentNetStatus {
    return curNet;
}
@end
