//
//  UserModel.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"userId":@"id"
            };
}
@end
