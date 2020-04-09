//
//  VoteViewController.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "VoteViewController.h"
#import "CTFVoteListVC.h"
#import "CTFVoteViewModel.h"
#import <JXCategoryView/JXCategoryView.h>

@interface VoteViewController () <JXCategoryViewDelegate, JXCategoryListContainerViewDelegate>

@property (nonatomic, strong) CTFVoteViewModel *adpater;

@property(nonatomic,strong) JXCategoryTitleView *categoryView;
@property(nonatomic,strong) JXCategoryListContainerView *listContainerView;

@property (nonatomic, strong) NSMutableArray<NSString *> *titleNameArray;
@property (nonatomic, strong) NSMutableArray<CTFVoteListVC *> *viewControllerArray;

@property (nonatomic, strong) MBProgressHUD *loadingHUD;

@property (nonatomic, strong) UIScrollView *scrollView_guideView;

@end

@implementation VoteViewController
{
    NSInteger _currentPageIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isHiddenBackBtn = YES;
    [self setupData];
    [self downDataTabs];
}

- (void)setupData {
    self.adpater = [[CTFVoteViewModel alloc] init];
    _currentPageIndex = 0;
}

- (void)downDataTabs {
    [self.loadingHUD showAnimated:YES];
    @weakify(self);
    [self.adpater svr_fetchVoteTopTabListComplete:^(BOOL isSuccess) {
        @strongify(self);
        [self.loadingHUD hideAnimated:YES];
        if (isSuccess) {
            [self setupViewContent];
        }else {
            [self.view makeToast:self.adpater.errorString];
            [self showNetErrorViewWithType:self.adpater.errorType whetherLittleIconModel:NO frame:CGRectMake(0, kNavBar_Height, self.view.bounds.size.width, self.view.bounds.size.height)];
            
        }
    }];
}

-(void)baseRefreshData{
    [self hideNetErrorView];
    [self downDataTabs];
}

- (void)setupViewContent {
    
    if ([self.adpater categoriesList].count <= 0) {
        //TO DO
        return;
    }
    
    //ViewControllers
    self.titleNameArray = [NSMutableArray array];
    self.viewControllerArray = [NSMutableArray array];
    NSInteger count = 0;
    for (CategoriesModel *category in self.adpater.categoriesList) {
        [self.titleNameArray addObject:category.name];
        
        CTFVoteListVC *vc = [[CTFVoteListVC alloc] init];
        vc.categoryId = category.categoryId;
        vc.adpater = self.adpater;
        vc.index = count;
        [self.viewControllerArray addObject:vc];
        count ++;
    }
    
    self.categoryView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(-14, kNavBar_Height - 44, CGRectGetWidth(self.view.bounds)+14, 47)];
    self.self.categoryView.defaultSelectedIndex = _currentPageIndex;
    self.categoryView.cellSpacing = 30;
    self.categoryView.delegate = self;
    [self.view addSubview:self.categoryView];
    
    JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
    lineView.indicatorWidth = 24;
    lineView.indicatorHeight = 2;
    lineView.indicatorCornerRadius = 1;
    lineView.indicatorColor = [UIColor ctMainColor];
    lineView.verticalMargin = 0;
    _categoryView.indicators = @[lineView];
    
    self.listContainerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_ScrollView delegate:self];
    
    self.categoryView.titles = self.titleNameArray;
    self.categoryView.titleFont = [UIFont mediumFontWithSize:16];
    self.categoryView.titleSelectedFont = [UIFont mediumFontWithSize:16];
    self.categoryView.titleColor = [UIColor ctColor99];
    self.categoryView.titleSelectedColor = [UIColor blackColor];
    self.categoryView.titleColorGradientEnabled = YES;
    self.categoryView.listContainer = self.listContainerView;
    self.listContainerView.frame = CGRectMake(0, kNavBar_Height - 44 + 47, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - kNavBar_Height - 44 + 47);
    [self.categoryView reloadData];
    [self.view addSubview:self.listContainerView];
    
    if ([CTFSystemCache query_whetherShowVoteGuide]) {
        self.scrollView_guideView = [self voteGuideView];
        [self.view addSubview:self.scrollView_guideView];
        [self.scrollView_guideView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
    }
}

#pragma mark - JXCategoryViewDelegate
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    //侧滑手势处理
    if(index == _currentPageIndex) return;
    _currentPageIndex = index;
    
    if (_currentPageIndex==0) {
        [MobClick event:@"vote_all"];
    }else{
        [MobClick event:@"vote_"];
    }
    
    //切换完之后进行网路请求刷新数据
    CTFVoteListVC *currentVoteListVC = self.viewControllerArray[_currentPageIndex];
    [currentVoteListVC beginTableViewRefreshWithMJHeadLoading:NO complete:nil];
}

#pragma mark - JXCategoryListContainerViewDelegate
- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    return self.viewControllerArray[index];
}

- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.viewControllerArray.count;
}

#pragma mark - lazy load
- (MBProgressHUD *)loadingHUD {
    if (!_loadingHUD) {
        _loadingHUD = [MBProgressHUD ctfShowLoading:self.view title:nil];
    }
    return _loadingHUD;
}

#pragma mark - 投票引导页（老版本）
- (UIScrollView *)voteGuideView {
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.scrollEnabled = NO;
    scrollView.backgroundColor = UIColorFromHEXWithAlpha(0x000000, 0.8);
    scrollView.contentSize = CGSizeMake(kScreen_Width * 2, self.view.frame.size.height);
    
    UIView *bgView1 = [[UIView alloc] init];
    bgView1.frame = CGRectMake(0, 0, kScreen_Width, self.view.frame.size.height);
    [scrollView addSubview:bgView1];

    UIImageView *imageView1 = [[UIImageView alloc] init];
    imageView1.image = [UIImage imageNamed:@"guide_vote_care"];
    [bgView1 addSubview:imageView1];
    [imageView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(bgView1.mas_centerX);
        make.top.mas_equalTo(bgView1.mas_top).offset(kNavBar_Height + 20);
        make.size.mas_equalTo(CGSizeMake(359, 302));
    }];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setTitle:@"下一步(1/2)" forState:UIControlStateNormal];
    [btn1 setTitleColor:UIColorFromHEX(0xFFFFFF) forState:UIControlStateNormal];
    [btn1.titleLabel setFont:[UIFont systemFontOfSize:16.7]];
    [btn1 setBackgroundImage:[UIImage imageNamed:@"guide_vote_btn"] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(btn1Action) forControlEvents:UIControlEventTouchUpInside];
    [bgView1 addSubview:btn1];
    [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(bgView1.mas_centerX);
        make.bottom.mas_equalTo(bgView1.mas_bottom).offset(-47);
        make.size.mas_equalTo(CGSizeMake(151, 35));
    }];
    
    UIView *bgView2 = [[UIView alloc] init];
    bgView2.frame = CGRectMake(kScreen_Width, 0, kScreen_Width, self.view.frame.size.height);
    [scrollView addSubview:bgView2];

    UIImageView *imageView2 = [[UIImageView alloc] init];
    imageView2.image = [UIImage imageNamed:@"guide_vote_step"];
    [bgView2 addSubview:imageView2];
    [imageView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(bgView2.mas_centerX);
        make.bottom.mas_equalTo(bgView2.mas_bottom).offset(-128);
        make.size.mas_equalTo(CGSizeMake(359, 302));
    }];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setTitle:@"完成" forState:UIControlStateNormal];
    [btn2 setTitleColor:UIColorFromHEX(0xFFFFFF) forState:UIControlStateNormal];
    [btn2.titleLabel setFont:[UIFont systemFontOfSize:16.7]];
    [btn2 setBackgroundImage:[UIImage imageNamed:@"guide_vote_btn"] forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(btn2Action) forControlEvents:UIControlEventTouchUpInside];
    [bgView2 addSubview:btn2];
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(bgView2.mas_centerX);
        make.bottom.mas_equalTo(bgView2.mas_bottom).offset(-47);
        make.size.mas_equalTo(CGSizeMake(151, 35));
    }];
    
    return scrollView;
}

- (void)btn1Action {
    [self.scrollView_guideView setContentOffset:CGPointMake(kScreen_Width, 0) animated:YES];
    [CTFSystemCache revise_whetherShowedVoteGuide:[NSNumber numberWithBool:YES]];
}

- (void)btn2Action {
    [self.scrollView_guideView removeFromSuperview];
}

@end
