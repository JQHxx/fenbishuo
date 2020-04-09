//
//  CTFMyQuestionTableViewCell.h
//  ChalkTalks
//
//  Created by vision on 2019/12/27.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTBaseCard.h"
#import "CTFActivityModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFMyQuestionTableViewCell : CTBaseCard

@property (nonatomic,strong) CTFActivityModel *activityModel;

+(CGFloat)getMyQuestionCellHeightWithMode:(CTFActivityModel *)model;

@end

NS_ASSUME_NONNULL_END
