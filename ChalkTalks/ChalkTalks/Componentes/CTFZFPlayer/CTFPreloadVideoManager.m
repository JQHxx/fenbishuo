//
//  CTFPreloadVideoManager.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/27.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFPreloadVideoManager.h"
#import "NSURL+Ext.h"
#import "CTFNetReachabilityManager.h"
#import "NSArray+Safety.h"
#import "AppUtils.h"

@implementation CTFPreloadVideoManager
+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static CTFPreloadVideoManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

-(void)preloadVideoUrls:(NSArray*)urlArr{
    if ([CTFNetReachabilityManager sharedInstance].currentNetStatus != AFNetworkReachabilityStatusReachableViaWiFi) return;
    for (NSString *url in urlArr) {
        NSURL *URL = [NSURL safe_URLWithString:url];
        NSURLSession *session = [NSURLSession sharedSession];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        //设置请求头range
        [request setValue:@"bytes" forHTTPHeaderField:@"Accept-Ranges"];
        [request setValue:@"bytes=0-3145728" forHTTPHeaderField:@"Range"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                //ZLLog(@"%@", error);
            }];
            [task resume];
        });
    }
}
@end
