//
//  AppDelegate+HTTPCache.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/27.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "AppDelegate+HTTPCache.h"
#import <KTVHTTPCache/KTVHTTPCache.h>

@implementation AppDelegate (HTTPCache)

- (void)configHTTPCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
           [self setupHTTPCache];
    });
}

- (void)setupHTTPCache {
    [KTVHTTPCache logSetConsoleLogEnable:NO];
    NSError *error = nil;
    [KTVHTTPCache proxyStart:&error];
    if (error) {
        ZLLog(@"Proxy Start Failure, %@", error);
    } else {
//        ZLLog(@"Proxy Start Success");
    }
    [KTVHTTPCache encodeSetURLConverter:^NSURL *(NSURL *URL) {
//        ZLLog(@"URL Filter reviced URL : %@", URL);
        return URL;
    }];
    [KTVHTTPCache downloadSetUnacceptableContentTypeDisposer:^BOOL(NSURL *URL, NSString *contentType) {
//        ZLLog(@"Unsupport Content-Type Filter reviced URL : %@, %@", URL, contentType);
        return NO;
    }];
}
@end
