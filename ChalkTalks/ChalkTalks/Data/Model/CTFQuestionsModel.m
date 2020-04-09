//
//  CTFQuestionsModel.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/11.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFQuestionsModel.h"

@implementation Author
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"authorId" : @"id"};
}
@end

@implementation CTFQuestionsModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"questionId" : @"id"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"images" : [ImageItemModel class],
    };
}

@end
