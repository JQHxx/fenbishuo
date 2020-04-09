//
//  CTFMineTopicModel.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/19.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFMineTopicModel : BaseModel

@property (nonatomic , copy) NSString              * title;
@property (nonatomic , assign) NSInteger              createdAt;
@property (nonatomic , assign) NSInteger              answerCount;
@property (nonatomic , assign) NSInteger              voteupCount;
@property (nonatomic , assign) NSInteger              votedownCount;
@property (nonatomic , copy) NSString              * attitude;
@property (nonatomic , assign) NSInteger              topicId;
@property (nonatomic , copy) NSString              * votedAt;
@property (nonatomic , copy) NSString              * content;

@end

NS_ASSUME_NONNULL_END
