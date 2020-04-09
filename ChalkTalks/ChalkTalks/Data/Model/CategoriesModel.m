//
//  CategoriesModel.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/4.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "CategoriesModel.h"

@implementation CategoriesModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"categoryId" : @"id"};
}
@end
