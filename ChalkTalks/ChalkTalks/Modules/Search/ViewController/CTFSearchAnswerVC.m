//
//  CTFSearchAnswerVC.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/28.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFSearchAnswerVC.h"
#import "CTFSearchAnswerListCell.h"
#import "CTFSearchAnswerModel.h"
#import "CTFBaseBlankView.h"

@interface CTFSearchAnswerVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MBProgressHUD *loadingHUD;
@property (nonatomic, strong) CTFBaseBlankView *blankView;//空白页
@end

@implementation CTFSearchAnswerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViewContent];
}

- (void)beginTableViewRefresh {
    self.blankView.hidden = YES;
    [self.adpater removeAllSearchResult_answer];
    [self.tableView reloadData];
    [self.loadingHUD showAnimated:YES];
    @weakify(self);
    [self.adpater fetchUpdate_AnswerSearchListByKeyword:self.keyword complete:^(BOOL isSuccess) {
        @strongify(self);
        [self.loadingHUD hideAnimated:YES];
        [self loadDataComplete:isSuccess];
    }];
}

- (void)loadDataComplete:(BOOL)isSuccess {
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    [self.tableView reloadData];
    if (isSuccess) {
        [self hideNetErrorView]; //隐藏网络错误
        if ([self.adpater query_AnswerSearchList].count == 0) {
            self.blankView.hidden = NO;
        } else {
            self.blankView.hidden = YES;
        }
    } else {
        [self.tableView makeToast:self.adpater.errorString];
        if ([self.adpater query_AnswerSearchList].count == 0) {
            [self showNetErrorViewWithType:self.adpater.errorType whetherLittleIconModel:NO frame:self.tableView.frame];
        }
    }
    [self createLoadMoreView];
}

- (void)createLoadMoreView {
    if ([self.adpater fetchMore_AnswerSearchList_Complete:^(BOOL isSuccess) {}]) {
        @weakify(self);
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{
            @strongify(self);
            [self loadmoreData];
        }];
        self.tableView.mj_footer = foot;
    } else if ([self.adpater query_AnswerSearchList].count != 0) {
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{}];
        self.tableView.mj_footer = foot;
        [foot setState:MJRefreshStateNoMoreData];
    } else {
        self.tableView.mj_footer = nil;
    }
}

- (void)loadmoreData {
    @weakify(self);
    [self.adpater fetchMore_AnswerSearchList_Complete:^(BOOL isSuccess) {
        @strongify(self);
        [self loadDataComplete:isSuccess];
    }];
}

// 网络错误空白页上的刷新按钮响应时间
- (void)baseRefreshData {
    [self hideNetErrorView];
    [self beginTableViewRefresh];
}

- (void)setupViewContent {
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - kNavBar_Height - 47) style:UITableViewStylePlain];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = UIColorFromHEX(0xFFFFFF);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 185;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:self.tableView];
    [self.tableView addSubview:self.blankView];
    self.blankView.hidden = YES;
}

#pragma mark - tableViewDataSource,UITableViewDelegate
// 行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.adpater query_AnswerSearchList].count;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CTFSearchAnswerModel *model = [[self.adpater query_AnswerSearchList] objectAtIndex:indexPath.row];
    
    CTFSearchAnswerListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CTFSearchAnswerListCell"];
    if (!cell) {
        cell = [[CTFSearchAnswerListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CTFSearchAnswerListCell"];
    }
    [cell fillContentWithData:model];
    return cell;
}

// 区尾高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

//当已经点击cell时
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [MobClick event:@"search_answeritem"];
    CTFSearchAnswerModel *model = [[self.adpater query_AnswerSearchList] objectAtIndex:indexPath.row];
    
    NSString *sid = [NSString stringWithFormat:@"%@?answerId=%zd&questionId=%zd", kCTFTopicDetailsVC, model.searchAnswerId, model.question.questionInfoModelId];
    APPROUTE(sid);
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        self.tableViewScrolledBlock();
    }
}

#pragma mark - JXCategoryListContentViewDelegate
- (UIView *)listView {
    return self.view;
}

- (void)listDidAppear{

}

-(void)listDidDisappear{

}

#pragma mark 空白页
- (CTFBaseBlankView *)blankView{
    if (!_blankView) {
        _blankView = [[CTFBaseBlankView alloc] initWithFrame:self.tableView.bounds blankType:CTFBlankType_SearchResult imageOffY:112];
    }
    return _blankView;
}

- (MBProgressHUD *)loadingHUD {
    if (_loadingHUD) {
        _loadingHUD = [MBProgressHUD ctfShowLoading:nil title:nil];
    }
    return _loadingHUD;
}

@end
