//
//  CTFReportTypeOptionVC.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/3/13.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "BaseViewController.h"
#import "CTFFeedBackVC.h"

NS_ASSUME_NONNULL_BEGIN



/// 举报类型选取
@interface CTFReportTypeOptionVC : BaseViewController

@property(nonatomic, copy) void (^ _Nonnull dismissBlock)(void );

- (instancetype)initWithFeedBackType:(FeedBackType)feedBackType
                      resourceTypeId:(NSInteger)resourceTypeId;

@end

NS_ASSUME_NONNULL_END
