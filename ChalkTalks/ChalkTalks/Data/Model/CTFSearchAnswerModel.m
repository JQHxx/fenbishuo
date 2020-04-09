//
//  CTFSearchAnswerModel.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/28.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFSearchAnswerModel.h"

@implementation Video
@end


@implementation AuthorMessageModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"authorId" : @"id"};
}
@end


@implementation QuestionInfoModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"questionInfoModelId" : @"id"};
}
@end


@implementation CTFSearchAnswerModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"searchAnswerId" : @"id"};
}

@end
