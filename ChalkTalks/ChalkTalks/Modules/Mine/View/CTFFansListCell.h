//
//  CTFFansListCell.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/18.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTBaseCard.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^DeleteFollowBlock)(NSInteger userId, NSInteger indexRow);
typedef void(^AddFollowBlock)(NSInteger userId, NSInteger indexRow);

@interface CTFFansListCell : CTBaseCard

@property (nonatomic, copy) DeleteFollowBlock deleteFollowBlock;
@property (nonatomic, copy) AddFollowBlock addFollowBlock;
@property (nonatomic, assign) NSInteger indexRow;

@end

NS_ASSUME_NONNULL_END
