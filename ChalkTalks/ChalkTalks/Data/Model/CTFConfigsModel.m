//
//  CTFConfigsModel.m
//  ChalkTalks
//
//  Created by vision on 2020/2/10.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFConfigsModel.h"

@implementation CTFGuideVideoModel


@end

@implementation CTFSuffixModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"suffixId" : @"id"};
}

@end

@implementation CTFConfigsModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"questionTitleSuffix" : [CTFSuffixModel class],
             @"questionGuideVideo":[CTFGuideVideoModel class],
    };
}

@end
