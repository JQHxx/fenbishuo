//
//  MainPageViewController.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "MainPageViewController.h"
#import "MainPageViewModel.h"
#import "LoginViewController.h"
#import "CTFNetReachabilityManager.h"
#import "MainTabListViewController.h"
#import <JXCategoryView/JXCategoryView.h>
#import "NSUserDefaultsInfos.h"

@interface MainPageViewController ()<MainTabListViewControllerDelegate, JXCategoryViewDelegate,JXCategoryListContainerViewDelegate>{
    NSInteger curPageIndex;/* 当前频道Index */
}
@property(nonatomic,strong) MainPageViewModel *adpater;
@property(nonatomic,assign) BOOL isFullScreen;

@property(nonatomic,strong) JXCategoryTitleView *categoryView;
@property(nonatomic,strong) JXCategoryListContainerView *listContainerView;
@property(nonatomic,strong) NSMutableArray *childVCs;

@end

@implementation MainPageViewController

 -  (void)viewDidLoad {
    [super viewDidLoad];
     
    self.isHiddenBackBtn = YES;
    
     _adpater = [[MainPageViewModel alloc] init];
     curPageIndex = 0;
     
    [self setupUI];
    [self requestTabs];
     
    if (![UIApplication sharedApplication].isIdleTimerDisabled) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    [self.view addSubview:self.listContainerView];
    [self.view addSubview:self.categoryView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (BOOL)prefersStatusBarHidden {
    return self.isFullScreen;
}

#pragma mark - MainTabListViewControllerDelegate
#pragma mark 首次加载feeds数据
- (void)loadFirstLaunchingFeedsData:(MainTabListViewController *)vc {
    [MobClick event:@"home_feeds_refresh"];
    @weakify(vc);
    [self.adpater fetchFirstLaunchingFeedsDataByCategoryID:vc.categoryId complete:^(BOOL isSuccess) {
        @strongify(vc);
        [vc loadDataComplete:isSuccess];
    }];
}

#pragma mark 加载数据
- (void)refreshData:(MainTabListViewController *)vc{
    if (curPageIndex==0) {
        if (vc.page.page==1) {
            [MobClick event:@"home_feeds_refresh"];
        }else{
            [MobClick event:@"home_feeds_loadmore"];
        }
    }else{
        if (vc.page.page==1) {
            [MobClick event:@"home_ask_refresh"];
        }else{
            [MobClick event:@"home_ask_loadmore"];
        }
    }
    NSInteger feedId = [self.adpater lastAnswerFeedId];
    
    @weakify(vc);
    [self.adpater fetchFeedListByCategoryID:vc.categoryId action:vc.action feedId:feedId page:vc.page complete:^(BOOL isSuccess) {
        @strongify(vc);
        [vc loadDataComplete:isSuccess];
    }];
}

#pragma mark 数量
- (NSInteger)numberOfList:(MainTabListViewController *)vc{
    return [self.adpater numberOfList:vc.categoryId];
}

- (CTFFeedCellLayout *)modelForView:(MainTabListViewController *)vc index:(NSInteger)index{
    return [self.adpater modelForFeed:vc.categoryId Index:index];
}

#pragma mark 是否更多
- (BOOL)hasMoreData:(MainTabListViewController *)vc{
    if (vc.index == 0) {
        return [self.adpater latestUpLoadFeedsDataCount] == 8;
    } else {
        return [self.adpater hasMoreData:vc.categoryId];
    }
}

#pragma mark 刷新feeds数量
- (NSInteger)refreshFeedDataCount:(MainTabListViewController *)vc {
    return [self.adpater refreshDataCount];
}

#pragma mark 是否为空
-(BOOL)isEmpty:(MainTabListViewController* _Nonnull)vc{
    return [self.adpater isEmpty:vc.categoryId];
}

#pragma mark 错误
-(BOOL)hasError:(MainTabListViewController* _Nonnull)vc{
    return [self.adpater hasError];
}

#pragma mark 错误信息
-(NSString*_Nullable)errorString:(MainTabListViewController* _Nonnull)vc{
    return [self.adpater errorString];
}

- (ERRORTYPE)getRequsetErrorType:(MainTabListViewController *)vc {
    return [self.adpater errorType];
}

#pragma mark 进入全屏
-(void)videoEnterFullScreen{
    self.isFullScreen = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark 退出全屏
-(void)videoExitFullScreen{
    self.isFullScreen = NO;
    [self setNeedsStatusBarAppearanceUpdate];
}

-(BOOL)isShowInSegment:(MainTabListViewController *)vc{
    return vc.index == curPageIndex;
}

#pragma mark 删除
-(void)deleteModel:(MainTabListViewController *)vc index:(NSInteger)index{
    [self.adpater deleteModelForFeed:vc.categoryId Index:index];
}

#pragma mark - JXCategoryViewDelegate
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    //侧滑手势处理
    if(index == curPageIndex) return;
    curPageIndex = index;
    if (index==0) {
        [MobClick event:@"home_feeds_tab"];
    }else{
        [MobClick event:@"home_other_tab"];
    }
}

#pragma mark - JXCategoryListContainerViewDelegate
- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    return self.childVCs[index];
}

- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.childVCs.count;
}

#pragma mark -- Event response
#pragma mark 搜索
-(void)rightNavigationItemAction{
    [MobClick event:@"home_search"];
    [ROUTER routeByCls:@"CTFSearchVC"];
}

#pragma mark 后门
- (void)backdoorAction:(UITapGestureRecognizer *)sender {
    [CTBackdoorViewController showBackdoor];
}

#pragma mark 父类方法
-(void)baseRefreshData{
    [self hideNetErrorView];
    [self requestTabs];
}

#pragma mark 刷新当前频道tableView
- (void)refreshTableView {
    MainTabListViewController *vc = (MainTabListViewController *)self.childVCs[curPageIndex];
    [vc baseRefreshData];
}

#pragma mark -- Private methods
#pragma mark - Api
-(void)requestTabs{
    MBProgressHUD *hub = [MBProgressHUD ctfShowLoading:self.view title:nil];
     @weakify(self);
    @weakify(hub);
    [_adpater fetchFeedTopTabList:^(BOOL isSuccess) {
        @strongify(self);
        @strongify(hub);
        [hub hideAnimated:NO];
        if (isSuccess) {
            [self setupMainPageView];
        } else {
            [self.view makeToast:self.adpater.errorString];
            [self showNetErrorViewWithType:self.adpater.errorType whetherLittleIconModel:NO frame:self.view.frame];
        }
    }];
}

#pragma mark UI
-(void)setupUI{
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kMarginLeft, kStatusBar_Height+6, 89, 31)];
    logoImageView.image = ImageNamed(@"nav_top_logo");
    [self.view addSubview:logoImageView];

    // 非app store版本，启动便捷后门
    if (![[CTENVConfig share] isAppStore]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backdoorAction:)];
        [logoImageView setUserInteractionEnabled:YES];
        [logoImageView addGestureRecognizer:tap];
    }
    
    UIButton *searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width-84, kStatusBar_Height+7, 68, 28)];
    searchBtn.backgroundColor = [UIColor ctColorF2];
    [searchBtn setImage:ImageNamed(@"main_top_search") forState:UIControlStateNormal];
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [searchBtn setTitleColor:[UIColor ctColor66] forState:UIControlStateNormal];
    searchBtn.titleLabel.font = [UIFont regularFontWithSize:14];
    searchBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
    searchBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    [searchBtn setBorderWithCornerRadius:14 type:UIViewCornerTypeAll];
    [searchBtn addTarget:self action:@selector(rightNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchBtn];
}

- (void)setupMainPageView{
    NSMutableArray *oldChilds = _childVCs;
    self.childVCs = [[NSMutableArray alloc] init];
    NSMutableArray *tabTitles = [[NSMutableArray alloc] init];
    NSInteger count = 0;
    for(CategoriesModel *item in self.adpater.categoriesList){
        [tabTitles addObject:item.name];
        
        MainTabListViewController *_old;
        for (MainTabListViewController *old in oldChilds) {
            if (old.categoryId == item.categoryId) {
                _old = old;
                break;
            }
        }
        if (_old != nil) {
            _old.index = count;
            _old.delegate = self;
            [_childVCs addObject:_old];
        } else {
            MainTabListViewController *vc = [[MainTabListViewController alloc] initWithCategoryId:item.categoryId];
            vc.index = count;
            vc.delegate = self;
            [_childVCs addObject:vc];
        }
        count++;
    }
    self.categoryView.titles = tabTitles;
    [self.categoryView reloadData];
}

#pragma mark -- Getters
-(JXCategoryTitleView*)categoryView{
    if(!_categoryView){
        _categoryView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(-14,kNavBar_Height, kScreen_Width+14, 44)];
        _categoryView.defaultSelectedIndex = curPageIndex;
        _categoryView.titleColorGradientEnabled = YES;
        _categoryView.titleFont = [UIFont mediumFontWithSize:16];
        _categoryView.titleColor =  [UIColor ctColor99];
        _categoryView.titleSelectedFont = [UIFont mediumFontWithSize:16];
        _categoryView.titleSelectedColor = [UIColor ctColor33];
        _categoryView.cellSpacing = 30;
        _categoryView.delegate = self;
        _categoryView.listContainer = self.listContainerView;
        
        JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
        lineView.indicatorWidth = 24;
        lineView.indicatorHeight = 2;
        lineView.indicatorCornerRadius = 1;
        lineView.indicatorColor = [UIColor ctMainColor];
        lineView.verticalMargin = 0;
        _categoryView.indicators = @[lineView];
    }
    return _categoryView;
}

-(JXCategoryListContainerView*)listContainerView{
    if(!_listContainerView){
        _listContainerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_ScrollView delegate:self];
        _listContainerView.frame = CGRectMake(0,kNavBar_Height + 44, CGRectGetWidth(self.view.bounds), kScreen_Height - kNavBar_Height - 44 - kTabBar_Height);
    }
    return _listContainerView;
}

- (NSMutableArray *)childVCs {
    if (!_childVCs) {
        _childVCs = [[NSMutableArray alloc] init];
    }
    return _childVCs;
}

@end
