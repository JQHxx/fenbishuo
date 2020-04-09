//
//  CTFSearchAnswerModel.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/28.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseModel.h"
#import "CTFSearchQuestionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Video :NSObject

@end


@interface AuthorMessageModel :NSObject
@property (nonatomic , copy) NSString              * gender;
@property (nonatomic , copy) NSString              * city;
@property (nonatomic , assign) NSInteger              authorId;
@property (nonatomic , copy) NSString              * idString;
@property (nonatomic , copy) NSString              * avatarUrl;
@property (nonatomic , copy) NSString              * name;
@property (nonatomic , copy) NSString              * headline;

@end


@interface QuestionInfoModel :NSObject
@property (nonatomic , assign) NSInteger              questionInfoModelId;
@property (nonatomic , copy) NSString              * idString;
@property (nonatomic , copy) NSString              * title;
@property (nonatomic , assign) NSInteger              createdAt;

@end


@interface CTFSearchAnswerModel : BaseModel
@property (nonatomic , assign) NSInteger              searchAnswerId;
@property (nonatomic , strong) Video              * video;
@property (nonatomic , strong) AuthorMessageModel              * author;
@property (nonatomic , assign) NSInteger              isAuthor;
@property (nonatomic , copy) NSString              * type;
@property (nonatomic , assign) NSInteger              votedownCount;
@property (nonatomic , copy) NSString              * attitude;
@property (nonatomic , copy) NSString              * summary;
@property (nonatomic , assign) NSInteger              commentCount;
@property (nonatomic , assign) NSInteger              voteupCount;
@property (nonatomic , strong) NSArray <ImagesItem *>              * images;
@property (nonatomic , copy) NSString              * idString;
@property (nonatomic , assign) NSInteger              createdAt;
@property (nonatomic , strong) QuestionInfoModel              * question;
@property (nonatomic , copy) NSString              * content;
@end

NS_ASSUME_NONNULL_END
