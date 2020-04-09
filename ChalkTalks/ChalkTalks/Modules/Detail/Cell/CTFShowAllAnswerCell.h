//
//  CTFShowAllAnswerCell.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/27.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTBaseCard.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFShowAllAnswerCell : CTBaseCard
@property(nonatomic, copy) void (^ _Nonnull didClickShowAllAnswer)(void);
@end

NS_ASSUME_NONNULL_END
