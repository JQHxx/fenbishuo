//
//  CTFBadgeModel.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/3/25.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 勋章模型
@interface CTFBadgeModel : BaseModel

@property (nonatomic , assign) NSInteger              code;
@property (nonatomic , assign) NSInteger              badgeId;
@property (nonatomic , copy) NSString              * idString;
@property (nonatomic , copy) NSString              * name;
@property (nonatomic , assign) NSInteger              isNew;
@property (nonatomic , assign) NSInteger              currentWinLevel;

@end

NS_ASSUME_NONNULL_END
