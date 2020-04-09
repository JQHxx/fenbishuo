//
//  CTFSearchUserModel.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/28.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFSearchUserModel : BaseModel

@property (nonatomic , assign) NSInteger              userId;
@property (nonatomic , assign) NSInteger              questionCount;
@property (nonatomic , assign) NSInteger              isBindMobile;
@property (nonatomic , assign) NSInteger              isMyFollower;
@property (nonatomic , copy) NSString              * headline;
@property (nonatomic , assign) NSInteger              isFollowing;
@property (nonatomic , assign) NSInteger              followingUserCount;
@property (nonatomic , assign) NSInteger              isBlocked;
@property (nonatomic , copy) NSString              * avatarUrl;
@property (nonatomic , assign) NSInteger              followingQuestionCount;
@property (nonatomic , assign) NSInteger              followerCount;
@property (nonatomic , assign) NSInteger              likeCount;
@property (nonatomic , assign) NSInteger              answerCount;
@property (nonatomic , strong) Location              * location;
@property (nonatomic , assign) NSInteger              isMe;
@property (nonatomic , copy) NSString              * idString;
@property (nonatomic , assign) NSInteger              unreadNotificationCount;
@property (nonatomic , copy) NSString              * name;
@property (nonatomic , copy) NSString              * gender;

@end

NS_ASSUME_NONNULL_END
