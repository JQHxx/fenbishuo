//
//  CTFSearchHistoryCell.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/28.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTBaseCard.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^DeleteHistory)(void);

@interface CTFSearchHistoryCell : CTBaseCard
@property (nonatomic, copy) DeleteHistory deleteHistory;//删除当条历史数据block
@end

NS_ASSUME_NONNULL_END
