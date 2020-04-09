//
//  CTFSearchUserVC.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/28.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseViewController.h"
#import "CTFSearchVM.h"
#import <JXCategoryView/JXCategoryView.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TableViewScrolledBlock)(void);

@interface CTFSearchUserVC : BaseViewController <JXCategoryListContentViewDelegate>

@property (nonatomic, strong) CTFSearchVM *adpater;
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, copy) TableViewScrolledBlock tableViewScrolledBlock;
- (void)beginTableViewRefresh;

@end

NS_ASSUME_NONNULL_END
