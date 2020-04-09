//
//  CTFSearchVC.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/26.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFSearchVC.h"
#import "CTFSearchVM.h"
#import "CTFSearchQuestionVC.h"
#import "CTFSearchAnswerVC.h"
#import "CTFSearchUserVC.h"
#import "CTFSearchHistoryCell.h"
#import <JXCategoryView/JXCategoryView.h>

typedef void(^TableViewScrolledBlock)(void);

@interface CTFSearchVC () <UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,JXCategoryViewDelegate,JXCategoryListContainerViewDelegate>

@property (nonatomic, strong) CTFSearchVM *adpater;

@property (nonatomic,strong) JXCategoryTitleView *categoryView;
@property (nonatomic,strong) JXCategoryListContainerView *listContainerView;

@property (nonatomic, strong) NSArray<NSString *> *titleNameArray;
@property (nonatomic, strong) NSArray<UIViewController *> *viewControllerArray;

@property (nonatomic, copy) NSString *currentKeyword;
@property (nonatomic, strong) UITextField *searchTextField;

@property (nonatomic, strong) UITableView *searchHistoryListTableView;/* 历史搜索记录tableView */
@property (nonatomic, strong) UIView *headView;

@property (nonatomic, assign) NSInteger signNumber;

@property (nonatomic, copy) TableViewScrolledBlock tableViewScrolledBlock;

@property (nonatomic, strong) NSMutableArray *sign_searchedArray;

@property (nonatomic, copy) NSString *currentTrendingSearchWord;

@end

@implementation CTFSearchVC
{
    NSInteger _currentPageIndex;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setupData];
    self.view.backgroundColor = UIColorFromHEX(0xFFFFFF);
    [self setupNavigationContent];
    [self loadData_trendingSearchWord];
    [self.searchTextField becomeFirstResponder];
}

- (void)loadData_trendingSearchWord {
    @weakify(self);
    [self.adpater svr_fetchTrendingSearchWordComplete:^(BOOL isSuccess) {
        @strongify(self);
        self.currentTrendingSearchWord = [self.adpater queryTrendingSearchWord];
        self.searchTextField.placeholder = self.currentTrendingSearchWord;
    }];
}

- (void)setupData {
    
    self.adpater = [[CTFSearchVM alloc] init];
    
    self.signNumber = 1;//从没有搜索的情况下，setupViewContent的界面不显示
    
    self.sign_searchedArray = [NSMutableArray arrayWithArray:@[@(0), @(0), @(0)]];//搜索后第一次切换segment时才进行网络请求
    
    @weakify(self);
    self.tableViewScrolledBlock = ^{
        @strongify(self);
        [self.searchTextField endEditing:YES];
    };//滑动搜索结果列表时需要收起搜索框的键盘
}

- (void)setupNavigationContent {
    
    //
    self.isHiddenBackBtn = YES;
    
    //搜索栏
    UIView *searchBgView = [[UIView alloc] initWithFrame:CGRectMake(16, kStatusBar_Height+5, kScreen_Width-16-62, 35)];
    searchBgView.backgroundColor = UIColorFromHEX(0xEFEFEF);
    searchBgView.layer.masksToBounds = YES;
    searchBgView.layer.cornerRadius = 5;
    
    UIImageView *searchImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 8, 17, 17)];
    searchImage.image = [UIImage imageNamed:@"icon_xiaosousuo"];
    [searchBgView addSubview:searchImage];

    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(36, 8, kScreen_Width-114, 20)];
    self.searchTextField.placeholder = @"你想找什么...";
    self.searchTextField.font = [UIFont systemFontOfSize:16];
    self.searchTextField.delegate = self;
    [self.searchTextField addTarget:self action:@selector(searchTextFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    self.searchTextField.textColor = UIColorFromHEX(0x333333);
    self.searchTextField.tintColor = UIColorFromHEX(0xFF6885);
    self.searchTextField.clearButtonMode=UITextFieldViewModeAlways;
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    [searchBgView addSubview:self.searchTextField];
    
    [self.view addSubview:searchBgView];
    
    // 取消按钮
    UIButton *rightBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width-62, kStatusBar_Height+2, 62, 40)];
    [rightBtn setTitle:@"取消" forState:UIControlStateNormal];
    [rightBtn setTitleColor:UIColorFromHEX(0x333333) forState:UIControlStateNormal];
    [rightBtn setTitleColor:UIColorFromHEXWithAlpha(0x333333, 0.6) forState:UIControlStateHighlighted];
    [rightBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [rightBtn addTarget:self action:@selector(rightNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightBtn];
}

- (void)rightNavigationItemAction {
    
    [MobClick event:@"search_cancel"];
    [self.searchTextField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupViewContent {
    
    //ViewControllers
    self.titleNameArray = [[NSMutableArray alloc] init];
    self.viewControllerArray = [[NSMutableArray alloc] init];
        
    CTFSearchQuestionVC *searchQuestionVC = [[CTFSearchQuestionVC alloc] init];
    searchQuestionVC.adpater = self.adpater;
    searchQuestionVC.tableViewScrolledBlock = self.tableViewScrolledBlock;
    
    CTFSearchAnswerVC *searchAnswerVC = [[CTFSearchAnswerVC alloc] init];
    searchAnswerVC.adpater = self.adpater;
    searchAnswerVC.tableViewScrolledBlock = self.tableViewScrolledBlock;
    
    CTFSearchUserVC *searchUserVC = [[CTFSearchUserVC alloc] init];
    searchUserVC.adpater = self.adpater;
    searchUserVC.tableViewScrolledBlock = self.tableViewScrolledBlock;
    
    self.viewControllerArray = @[searchQuestionVC, searchAnswerVC, searchUserVC];
    self.titleNameArray = @[@"话题", @"回答", @"用户"];
    
    self.categoryView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(-14, kStatusBar_Height+44, 215, 47)];
    self.self.categoryView.defaultSelectedIndex = _currentPageIndex;
    self.categoryView.titleColorGradientEnabled = NO;
    self.categoryView.titleFont = [UIFont mediumFontWithSize:16];
    self.categoryView.titleColor = [UIColor ctColor99];
    self.categoryView.titleSelectedFont = [UIFont mediumFontWithSize:16];
    self.categoryView.titleSelectedColor = [UIColor ctColor33];
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
    self.categoryView.listContainer = self.listContainerView;
    self.listContainerView.frame = CGRectMake(0, kStatusBar_Height+44+47, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) + 47);
    [self.categoryView reloadData];
    [self.view addSubview:self.listContainerView];
}

//
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField.text.length == 0 && [self.adpater query_SearchHistory].count > 0) {
        self.searchHistoryListTableView.hidden = NO;
        [self.view bringSubviewToFront:self.searchHistoryListTableView];
    }
}

//点击搜索的响应事件
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [MobClick event:@"search_search"];
    [textField resignFirstResponder];
    self.searchHistoryListTableView.hidden = YES;
    if (textField.text.length > 0) {
        [self.adpater add_SearchHistory:textField.text];
    }
    
    self.currentKeyword = textField.text;
    if (self.signNumber == 1) {
       [self setupViewContent];
       self.signNumber = 2;
    }
    if (textField.text.length > 0) {
       CTFSearchQuestionVC *currentVC = (CTFSearchQuestionVC *)self.viewControllerArray[_currentPageIndex];
       currentVC.keyword = self.currentKeyword;
       [currentVC beginTableViewRefresh];
       self.sign_searchedArray[0] = @(0);
       self.sign_searchedArray[1] = @(0);
       self.sign_searchedArray[2] = @(0);
       self.sign_searchedArray[_currentPageIndex] = @(1);
    } else {
        if (self.currentTrendingSearchWord.length > 0) {
            self.searchTextField.text = self.currentTrendingSearchWord;
            [self textFieldShouldReturn:self.searchTextField];
        }
    }
    return YES;
}

//
- (void)searchTextFieldValueChanged:(UITextField *)textField {
    [CTFWordLimit computeWordCountWithTextField:textField maxNumber:15];
    if (textField.text.length == 0 && [self.adpater query_SearchHistory].count > 0) {
        self.searchHistoryListTableView.hidden = NO;
        [self.view bringSubviewToFront:self.searchHistoryListTableView];
        [self.searchHistoryListTableView reloadData];
    }
}

#pragma mark - JXCategoryViewDelegate
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    //侧滑手势处理
    if(index == _currentPageIndex) return;
    _currentPageIndex = index;

    //切换完之后进行网路请求刷新数据
    if (_currentPageIndex == 0 && [self.sign_searchedArray[_currentPageIndex] integerValue] == 0) {
        [MobClick event:@"search_topictab"];
        CTFSearchQuestionVC *currentVC = (CTFSearchQuestionVC *)self.viewControllerArray[_currentPageIndex];
        currentVC.keyword = self.searchTextField.text;
        [currentVC beginTableViewRefresh];
        self.sign_searchedArray[_currentPageIndex] = @(1);
    }
    
    if (_currentPageIndex == 1 && [self.sign_searchedArray[_currentPageIndex] integerValue] == 0) {
        [MobClick event:@"search_answertab"];
        CTFSearchAnswerVC *currentVC = (CTFSearchAnswerVC *)self.viewControllerArray[_currentPageIndex];
        currentVC.keyword = self.searchTextField.text;
        [currentVC beginTableViewRefresh];
        self.sign_searchedArray[_currentPageIndex] = @(1);
    }
    
    if (_currentPageIndex == 2  && [self.sign_searchedArray[_currentPageIndex] integerValue] == 0) {
        CTFSearchUserVC *currentVC = (CTFSearchUserVC *)self.viewControllerArray[_currentPageIndex];
        currentVC.keyword = self.searchTextField.text;
        [currentVC beginTableViewRefresh];
        self.sign_searchedArray[_currentPageIndex] = @(1);
    }
}

#pragma mark - JXCategoryListContainerViewDelegate
- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    if (index == 0) {
        return (CTFSearchQuestionVC *)self.viewControllerArray[0];
    } else if (index == 1) {
        return (CTFSearchAnswerVC *)self.viewControllerArray[1];
    } else {
        return (CTFSearchUserVC *)self.viewControllerArray[2];
    }
}

- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.viewControllerArray.count;
}

- (UITableView *)searchHistoryListTableView {
    if (!_searchHistoryListTableView) {
        _searchHistoryListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kStatusBar_Height+44, kScreen_Width, kScreen_Height - kNavBar_Height) style:UITableViewStylePlain];
        _searchHistoryListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _searchHistoryListTableView.backgroundColor = UIColorFromHEX(0xFFFFFF);
        _searchHistoryListTableView.delegate = self;
        _searchHistoryListTableView.dataSource = self;
        _searchHistoryListTableView.estimatedRowHeight = 42;
        _searchHistoryListTableView.rowHeight = UITableViewAutomaticDimension;
        _searchHistoryListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _searchHistoryListTableView.showsVerticalScrollIndicator = YES;
        [self.view addSubview:_searchHistoryListTableView];
        [self.view bringSubviewToFront:_searchHistoryListTableView];
        _searchHistoryListTableView.hidden = YES;
        
        self.headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 44)];
        self.headView.backgroundColor = UIColorFromHEX(0xFFFFFF);
        self.headView.layer.cornerRadius = 5;
        self.headView.layer.masksToBounds = YES;
        
        UILabel *headView_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 13, 60, 22)];
        headView_titleLabel.text = @"历史记录";
        headView_titleLabel.font = [UIFont systemFontOfSize:12];
        headView_titleLabel.textColor = UIColorFromHEX(0x999999);
        [self.headView addSubview:headView_titleLabel];
        
        UIButton *headView_deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [headView_deleteBtn setImage:[UIImage imageNamed:@"icon_qingchu"] forState:UIControlStateNormal];
        [headView_deleteBtn addTarget:self action:@selector(headView_deleteBtnAction) forControlEvents:UIControlEventTouchUpInside];
        headView_deleteBtn.frame = CGRectMake(kScreen_Width-34, 11, 18, 19);
        [self.headView addSubview:headView_deleteBtn];
    }
    _searchHistoryListTableView.tableHeaderView = self.headView;
    return _searchHistoryListTableView;
}

- (void)headView_deleteBtnAction {
    
    NSString *title = @"确定清空搜索历史吗？";
    NSString *message = @"";
    NSString *cancelButtonTitle = @"取消";
    NSString *otherButtonTitle = @"清空";

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

    }];
    
    @weakify(self);
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        @strongify(self);
        [MobClick event:@"search_clearhistoryall"];
        [[SDImageCache sharedImageCache] clearMemory];
        @weakify(self);
        [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
            @strongify(self);
            [self.adpater delete_SearchHistoryAll];
            [self.searchHistoryListTableView reloadData];
            self.searchHistoryListTableView.tableHeaderView = nil;
        }];
    }];
    
    [otherAction setValue:UIColorFromHEX(0xFF6885) forKey:@"titleTextColor"];
    [cancelAction setValue:UIColorFromHEX(0x999999) forKey:@"titleTextColor"];
    
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == self.searchHistoryListTableView) {
        [self.searchTextField endEditing:YES];
        self.searchHistoryListTableView.hidden = NO;
        [self.view bringSubviewToFront:self.searchHistoryListTableView];
    }
}

#pragma mark - tableViewDataSource,UITableViewDelegate
// 行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.adpater query_SearchHistory].count;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *historyString = [[self.adpater query_SearchHistory] objectAtIndex:[self.adpater query_SearchHistory].count - 1 - indexPath.row];

    CTFSearchHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CTFSearchHistoryCell"];
    if (!cell) {
        cell = [[CTFSearchHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CTFSearchHistoryCell"];
    }
    @weakify(self);
    cell.deleteHistory = ^{
        [MobClick event:@"search_delonehistory"];
        @strongify(self);
        [self.adpater delete_SearchHistoryWithIndexRow:([self.adpater query_SearchHistory].count - 1 - indexPath.row)];
        [self.searchHistoryListTableView reloadData];
        if ([self.adpater query_SearchHistory].count == 0) {
            self.searchHistoryListTableView.tableHeaderView = nil;
        }
    };
    [cell fillContentWithData:historyString];
    return cell;
}

// 区尾高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

//当已经点击cell时
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [MobClick event:@"search_historyclick"];
    NSString *historyString = [[self.adpater query_SearchHistory] objectAtIndex:[self.adpater query_SearchHistory].count - 1 - indexPath.row];
    [self.adpater delete_SearchHistoryWithIndexRow:[self.adpater query_SearchHistory].count - 1 - indexPath.row];
    self.searchTextField.text = historyString;
    [self textFieldShouldReturn:self.searchTextField];
}

@end
