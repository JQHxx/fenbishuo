//
//  NSURL+Safety.h
//  StarryNight
//
//  Created by zingwin on 2018/4/24.
//  Copyright © 2018年 zwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Safety)
+(NSURL*)safe_fileURLWithPath:(NSString*)path;
@end
