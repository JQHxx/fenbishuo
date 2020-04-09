//
//  AnswersModel.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/6.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "AnswersModel.h"

@implementation ImageItemModel
 + (NSDictionary *)modelCustomPropertyMapper {
     return @{@"imgId" : @"id",
              @"imgHash" : @"hash"
     };
 }
@end


@implementation VideoItemModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"videoId" : @"id",
             @"videoHash" : @"hash"
    };
}
@end

@implementation AudioModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"audioId" : @"id"};
}

@end

@implementation AudioImageModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"audioId" : @"id",
             @"audioHash" : @"hash",
    };
}

@end


@implementation AuthorModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"authorId" : @"id"};
}
@end


@implementation QuestionModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"questionId" : @"id"};
}
@end

@implementation AnswerModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"answerId" : @"id"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"images" : [ImageItemModel class],
             @"video" : VideoItemModel.class,
             @"audioImage": [AudioImageModel class],
             @"author" :AuthorModel.class,
             @"question" :QuestionModel.class,
    };
}

@end
