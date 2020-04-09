//
//  CTFSearchQuestionModel.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/28.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFSearchQuestionModel.h"

@implementation MyAnswer

@end

@implementation AuthorInfoModel

@end

@implementation ImagesItem
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"imageId" : @"id"};
}
@end

@implementation CTFSearchQuestionModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"questionId" : @"id"};
}
@end
