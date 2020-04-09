//
//  CTFSearchQuestionModel.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/28.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MyAnswer :NSObject

@end


@interface AuthorInfoModel : NSObject

@end


@interface ImagesItem :NSObject
@property (nonatomic , copy) NSString              * status;
@property (nonatomic , assign) NSInteger              imageId;
@property (nonatomic , copy) NSString              * idString;
@property (nonatomic , copy) NSString              * hash;
@property (nonatomic , copy) NSString              * url;
@end


@interface CTFSearchQuestionModel : BaseModel
@property (nonatomic , assign) NSInteger              questionId;
@property (nonatomic , strong) MyAnswer              * myAnswer;
@property (nonatomic , strong) AuthorInfoModel              * author;
@property (nonatomic , assign) NSInteger              isAuthor;
@property (nonatomic , assign) NSInteger              votedAt;
@property (nonatomic , copy) NSString              * title;
@property (nonatomic , assign) NSInteger              answerCount;
@property (nonatomic , copy) NSString              * summary;
@property (nonatomic , assign) NSInteger              votedownCount;
@property (nonatomic , copy) NSString              * attitude;
@property (nonatomic , assign) NSInteger              voteupCount;
@property (nonatomic , strong) NSArray <ImagesItem *>              * images;
@property (nonatomic , copy) NSString              * idString;
@property (nonatomic , assign) NSInteger              createdAt;
//@property (nonatomic , copy) NSString              * content;服务器返回的是null，暂时不接收了
@end

NS_ASSUME_NONNULL_END
