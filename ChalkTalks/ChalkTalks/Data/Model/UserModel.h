//
//  UserModel.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserModel : BaseModel

@property (nonatomic, assign) NSInteger     isFollowing;
@property (nonatomic, assign) NSInteger     isMyFollower;
@property (nonatomic, assign) NSInteger     answerCount;
@property (nonatomic, strong) NSString      *avatarUrl;
@property (nonatomic, copy) NSString        *bigAvatarUrl;
@property (nonatomic, assign) NSInteger     followerCount;
@property (nonatomic, assign) NSInteger     followingQuestionCount;
@property (nonatomic, assign) NSInteger     followingUserCount;
@property (nonatomic, strong) NSString      *gender;
@property (nonatomic, strong) NSString      *headline;
@property (nonatomic, assign) NSInteger     userId;
@property (nonatomic, copy) NSString        *idString;
@property (nonatomic, assign) NSInteger     isBindMobile;
@property (nonatomic, assign) NSInteger     isBlocked;
@property (nonatomic, assign) NSInteger     likeCount;
@property (nonatomic, strong) NSString      *name;
@property (nonatomic, copy) NSString        *role;
@property (nonatomic, assign) NSInteger     questionCount;
@property (nonatomic, assign) NSInteger     unreadNotificationCount;
@property (nonatomic, strong) NSString      *city;
@property (nonatomic, assign) NSInteger     createdDays;
@property (nonatomic, assign) NSInteger     questionAnswerCount;

@end

NS_ASSUME_NONNULL_END
