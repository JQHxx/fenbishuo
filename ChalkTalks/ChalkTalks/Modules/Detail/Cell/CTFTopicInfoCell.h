//
//  CTFTopicInfoCell.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/12.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTBaseCard.h"
#import "CTFTopicInfoCellLayout.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFTopicInfoCell : CTBaseCard
@property(nonatomic, copy) void (^ _Nonnull switchShowAllTopicContent)(void);

@end

NS_ASSUME_NONNULL_END
