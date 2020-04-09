//
//  CTFCommentModel.m
//  ChalkTalks
//
//  Created by vision on 2019/12/24.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFCommentModel.h"


@implementation CTFCommentModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"commentId":@"id"
            };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"childComments" : [CTFCommentModel class],
    };
}

@end
