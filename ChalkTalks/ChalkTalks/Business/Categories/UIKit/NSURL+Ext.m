//
//  NSURL+Ext.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/9.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "NSURL+Ext.h"


@implementation NSURL (Ext)
+ (nullable instancetype)safe_URLWithString:(NSString *)URLString{
    if(!URLString) return nil;
    NSString *encodingString = [URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return [NSURL URLWithString:encodingString];
}
@end
