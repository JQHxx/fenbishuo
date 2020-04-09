//
//  CTFFansUserModel.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/18.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFPull : BaseModel

@property (nonatomic , assign) NSInteger              pullId;
@property (nonatomic , assign) NSInteger              isRead;
@property (nonatomic , copy) NSString              * idString;

@end

@interface CTFFansUserModel : BaseModel

@property (nonatomic , copy) NSString              * avatarUrl;
@property (nonatomic , copy) NSString              * name;
@property (nonatomic , assign) NSInteger              fansId;
@property (nonatomic , copy) NSString              * city;
@property (nonatomic , copy) NSString              * headline;
@property (nonatomic , assign) NSInteger              followedAt;
@property (nonatomic , copy) NSString              * gender;
@property (nonatomic , assign) BOOL              isFollowing;//该浏览者有没有关注该用户
@property (nonatomic , assign) BOOL              isMyFollower;//该用户是不是该浏览者的粉丝，在这里永远是true
@property (nonatomic , strong) CTFPull              * pull;

@end

NS_ASSUME_NONNULL_END
