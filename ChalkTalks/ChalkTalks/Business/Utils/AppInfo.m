//
//  AppInfo.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/4.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "AppInfo.h"

@implementation AppInfo

+ (NSString *)appVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    if (infoDictionary) {
        NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        return app_Version;
    }
    return @"";
}

+ (int)appBuildCode {
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    build = [build stringByReplacingOccurrencesOfString:@"." withString:@""];
    return [build intValue];
}

@end
