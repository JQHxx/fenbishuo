//
//  CTFFollowUserModel.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/19.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFFollowUserModel : BaseModel

@property (nonatomic , copy) NSString              * avatarUrl;
@property (nonatomic , copy) NSString              * name;
@property (nonatomic , assign) NSInteger              followId;
@property (nonatomic , copy) NSString              * city;
@property (nonatomic , copy) NSString              * headline;
@property (nonatomic , assign) NSInteger              followedAt;
@property (nonatomic , copy) NSString              * gender;
@property (nonatomic , assign) BOOL              isMyFollower;//该用户是不是浏览者的粉丝
@property (nonatomic , assign) BOOL              isFollowing;//该浏览者有没有关注该用户，这里永远为true

@end

NS_ASSUME_NONNULL_END
