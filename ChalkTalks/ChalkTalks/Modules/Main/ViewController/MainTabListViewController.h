//
//  MainTabListViewController.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/20.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTModels.h"
#import "CTFFeedCellLayout.h"
#import <JXCategoryView/JXCategoryView.h>

@class MainTabListViewController;

@protocol MainTabListViewControllerDelegate <NSObject>

- (void)loadFirstLaunchingFeedsData:(MainTabListViewController *_Nonnull)vc;
- (void)refreshData:(MainTabListViewController* _Nonnull)vc;
- (NSInteger)numberOfList:(MainTabListViewController* _Nonnull)vc;
- (NSInteger)refreshFeedDataCount:(MainTabListViewController* _Nonnull)vc;
- (CTFFeedCellLayout*_Nullable)modelForView:(MainTabListViewController* _Nonnull)vc index:(NSInteger)index;
- (BOOL)hasMoreData:(MainTabListViewController* _Nonnull)vc;
- (BOOL)isEmpty:(MainTabListViewController* _Nonnull)vc;
- (BOOL)hasError:(MainTabListViewController* _Nonnull)vc;
- (NSString*_Nullable)errorString:(MainTabListViewController* _Nonnull)vc;
- (ERRORTYPE)getRequsetErrorType:(MainTabListViewController* _Nonnull)vc;

- (BOOL)isShowInSegment:(MainTabListViewController * _Nonnull)vc;

- (void)videoEnterFullScreen;
- (void)videoExitFullScreen;

-(void)deleteModel:(MainTabListViewController* _Nonnull)vc
             index:(NSInteger)index;

@end



NS_ASSUME_NONNULL_BEGIN

@interface MainTabListViewController : BaseViewController <JXCategoryListContentViewDelegate>
-(instancetype)initWithCategoryId:(NSInteger)cid;
@property(nonatomic,weak) id<MainTabListViewControllerDelegate> delegate;
@property(nonatomic,assign) NSInteger index;
@property(nonatomic,assign) NSInteger categoryId;
@property(nonatomic,strong) PagingModel *page;
@property (nonatomic,copy ) NSString    *action;

-(void)loadDataComplete:(BOOL)isSuccess;

- (void)removeMainPageLearningView;

@end

NS_ASSUME_NONNULL_END
