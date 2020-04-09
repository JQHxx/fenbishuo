//
//  NSURL+Safety.m
//  StarryNight
//
//  Created by zingwin on 2018/4/24.
//  Copyright © 2018年 zwin. All rights reserved.
//

#import "NSURL+Safety.h"

@implementation NSURL (Safety)
+(NSURL*)safe_fileURLWithPath:(NSString*)path{
    if(path == nil || path.length <= 0)   return nil;
    return [NSURL fileURLWithPath:path];
}
@end
