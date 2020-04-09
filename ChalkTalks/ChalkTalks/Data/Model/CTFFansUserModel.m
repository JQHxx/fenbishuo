//
//  CTFFansUserModel.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/18.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFFansUserModel.h"

@implementation CTFPull

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"pullId" : @"id"};
}

@end

@implementation CTFFansUserModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"fansId" : @"id"};
}

@end
