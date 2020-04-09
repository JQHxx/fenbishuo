//
//  CTFSearchUserModel.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/28.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFSearchUserModel.h"

@implementation CTFSearchUserModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"userId" : @"id"};
}

@end
