//
//  CTFMineUserMessageModel.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/17.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFMineUserMessageModel.h"

@implementation Location

@end

@implementation CTFMineUserMessageModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"userId" : @"id"};
}

@end
