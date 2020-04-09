//
//  CTFMineFollowListVC.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/18.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFMineFollowListVC.h"
#import "CTFMineViewModel.h"
#import "CTFollowListCell.h"
#import "CTFSkeletonCellOne.h"
#import "CTFTopicDetailsViewModel.h"
#import "CTFBaseBlankView.h"

@interface CTFMineFollowListVC () <UITableViewDelegate, UITableViewDataSource, CTFSkeletonDelegate>
@property (nonatomic, strong) UITableView *followListTView;
@property (nonatomic, strong) CTFMineViewModel *adpater;
@property (nonatomic, strong) PagingModel *pagingModel;

@property (nonatomic, assign) NSInteger userId;

@property (nonatomic, strong) CTFTopicDetailsViewModel *topicDetailsVM;

@property (nonatomic, strong) CTFBaseBlankView *blankView;//空白页

@end

@implementation CTFMineFollowListVC

#pragma mark - skeleton - function
- (NSInteger)collectionSkeletonView:(UITableView *)skeletonView numberOfRowsInSection:(NSInteger)section {
    return kScreen_Height / [CTFSkeletonCellOne defaultHeight];
}

- (NSInteger)numSectionsIn:(UITableView *)collectionSkeletonView {
    return 1;
}

- (NSString *)collectionSkeletonView:(UITableView *)skeletonView cellIdentifierForRowAt:(NSIndexPath *)indexPath {
    return @"CTFSkeletonCellOne";
}

- (void)skeleton_show {
    [self.followListTView registerClass:[CTFSkeletonCellOne class] forCellReuseIdentifier:@"CTFSkeletonCellOne"];
    [self.followListTView ctf_showSkeleton];
}

- (void)skeleton_hide {
    [self.followListTView ctf_hideSkeleton];
    self.followListTView.rowHeight = UITableViewAutomaticDimension;
    [self.followListTView reloadData];
    [self.followListTView ctf_hideSkeleton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.userId = [self.schemaArgu[@"userId"] integerValue];
    self.baseTitle = @"关注";
    self.adpater = [[CTFMineViewModel alloc] init];
    self.topicDetailsVM = [[CTFTopicDetailsViewModel alloc] init];
    [self skeleton_show];
    [self.followListTView.mj_header beginRefreshing];
    
}

- (void)downData {
    
    @weakify(self);
    [self.adpater svr_fetchFollowListByUserId:self.userId page:self.pagingModel complete:^(BOOL isSuccess) {
        @strongify(self);
        [self skeleton_hide];
        [self.followListTView.mj_header endRefreshing];
        [self.followListTView.mj_footer endRefreshing];
        if (isSuccess) {
            [self hideNetErrorView];
            [self loadDataComplete];
            if ([self.adpater numberOfFollowList] == 0) {
                self.blankView.hidden = NO;
            } else {
                self.blankView.hidden = YES;
            }
        }else{
            [self.view makeToast:self.adpater.errorString];
            [self showNetErrorViewWithType:self.adpater.errorType whetherLittleIconModel:NO frame:self.followListTView.frame];
        }
    }];
}

#pragma mark 刷新试试
-(void)baseRefreshData{
    [self.followListTView.mj_header beginRefreshing];
}

- (void)loadDataComplete {
    [self.followListTView reloadData];
    [self createLoadMoreView];
}

- (UITableView *)followListTView {
    if (!_followListTView) {
        _followListTView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBar_Height, kScreen_Width, kScreen_Height - kNavBar_Height) style:UITableViewStylePlain];
        _followListTView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _followListTView.backgroundColor = [UIColor whiteColor];
        _followListTView.delegate = self;
        _followListTView.dataSource = self;
        _followListTView.estimatedRowHeight = [CTFSkeletonCellOne defaultHeight];
        _followListTView.rowHeight = UITableViewAutomaticDimension;
        _followListTView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _followListTView.showsVerticalScrollIndicator = NO;
        [_followListTView registerClass:[CTFollowListCell class] forCellReuseIdentifier:@"CTFollowListCell"];
        @weakify(self)
        _followListTView.mj_header = [[CTRefreshHeader alloc] initWithRefreshingBlock:^{
            @strongify(self)
            [self refreshData];
        }];
        [self.view addSubview:_followListTView];
        [_followListTView addSubview:self.blankView];
        self.blankView.hidden = YES;
    }
    return _followListTView;
}

- (void)createLoadMoreView {
    if ([self.adpater hasMoreFollowListData]) {
        @weakify(self);
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{
            @strongify(self);
            [self loadmoreData];
        }];
        self.followListTView.mj_footer = foot;
    }else{
        @weakify(self);
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{
            @strongify(self);
            [self loadmoreData];
        }];
        self.followListTView.mj_footer = foot;
        [foot setState:MJRefreshStateNoMoreData];
        
        if (self.pagingModel.page > 1) {
            if (self.pagingModel.count < self.pagingModel.pageSize) {
                [foot setState:MJRefreshStateNoMoreData];
            }
        }else{
            if (self.followListTView.contentSize.height > self.followListTView.height) {
                [foot setState:MJRefreshStateNoMoreData];
            }else{
                if (self.pagingModel.count < self.pagingModel.pageSize) {
                    self.followListTView.mj_footer = nil;
                }
            }
        }
    }
}

- (void)refreshData {
    self.blankView.hidden = YES;
    if(self.pagingModel == nil) {
        self.pagingModel = [[PagingModel alloc] init];
    }
    self.pagingModel.page = 1;
    self.pagingModel.pageSize = 10;
    [self downData];
}

- (void)loadmoreData {
    self.pagingModel.page++;
    [self downData];
}

#pragma mark - tableViewDataSource,UITableViewDelegate

// 行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.adpater numberOfFollowList];
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CTFFollowUserModel *model = [self.adpater followModelAtIndex:indexPath.row];
    
    CTFollowListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CTFollowListCell"];
    @weakify(self);
    cell.deleteFollowBlock = ^(NSInteger userId, NSInteger indexRow) {
        @strongify(self);
        
        @weakify(self);
        [self.topicDetailsVM followActionToUser:userId needFollow:NO complete:^(BOOL isSuccess) {
            @strongify(self);
            CTFFollowUserModel *model = [self.adpater followModelAtIndex:indexRow];
            model.isFollowing = NO;
            [self.followListTView reloadData];
        }];
    };
    cell.addFollowBlock = ^(NSInteger userId, NSInteger indexRow) {
        @strongify(self);
        if (userId == [UserCache getUserInfo].userId) {
            [MBProgressHUD ctfShowMessage:@"无法关注自己哦~"];
            return;
        }
        @weakify(self);
        [self.topicDetailsVM followActionToUser:userId needFollow:YES complete:^(BOOL isSuccess) {
            @strongify(self);
            CTFFollowUserModel *model = [self.adpater followModelAtIndex:indexRow];
            model.isFollowing = YES;
            [self.followListTView reloadData];
        }];
    };
    [cell fillContentWithData:model];
    cell.indexRow = indexPath.row;
    return cell;
}

// 区尾高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

//当已经点击cell时
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    CTFFollowUserModel *model = [self.adpater followModelAtIndex:indexPath.row];
    [ROUTER routeByCls:kCTFHomePageVC withParam:@{@"userId": @(model.followId)}];
}

#pragma mark 空白页
- (CTFBaseBlankView *)blankView{
    if (!_blankView) {
        if (self.userId == [UserCache getUserInfo].userId) {
            _blankView = [[CTFBaseBlankView alloc] initWithFrame:self.followListTView.bounds blankType:CTFBlankType_FollowForMe imageOffY:112];
        } else {
            _blankView = [[CTFBaseBlankView alloc] initWithFrame:self.followListTView.bounds blankType:CTFBlankType_FollowForOther imageOffY:112];
        }
    }
    return _blankView;
}

@end
