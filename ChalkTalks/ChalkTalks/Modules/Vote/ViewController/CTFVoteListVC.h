//
//  CTFVoteListVC.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/5.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CTFVoteViewModel.h"
#import <JXCategoryView/JXCategoryView.h>

NS_ASSUME_NONNULL_BEGIN

@class CTFVoteListVC;

@interface CTFVoteListVC : BaseViewController <JXCategoryListContentViewDelegate>

@property (nonatomic, assign) NSInteger categoryId;
@property (nonatomic, copy) NSString *sortType;

@property (nonatomic, strong) CTFVoteViewModel *adpater;

@property (nonatomic, assign) NSInteger index;

- (void)beginTableViewRefreshWithMJHeadLoading:(BOOL)MJHeadLoading complete:(void(^ _Nullable)(BOOL isSuccess))completeBlock;
- (void)loadDataComplete:(BOOL)isSuccess;

// 隐藏投票的学习引导
- (void)removeVoteLearningView;

@end

NS_ASSUME_NONNULL_END
