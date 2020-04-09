//
//  CTFCarouselsModel.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/1/13.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFCarouselsModel : BaseModel

@property (nonatomic , strong) UserModel *actors;
@property (nonatomic , copy) NSString *text;

@end

NS_ASSUME_NONNULL_END
