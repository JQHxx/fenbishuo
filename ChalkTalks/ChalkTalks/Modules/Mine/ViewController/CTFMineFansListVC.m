//
//  CTFMineFansListVC.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/18.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFMineFansListVC.h"
#import "CTFMineViewModel.h"
#import "CTFFansListCell.h"
#import "CTFSkeletonCellOne.h"
#import "CTFTopicDetailsViewModel.h"
#import "CTFBaseBlankView.h"

@interface CTFMineFansListVC () <UITableViewDelegate, UITableViewDataSource, CTFSkeletonDelegate>
@property (nonatomic, strong) UITableView *fansListTView;
@property (nonatomic, strong) CTFMineViewModel *adpater;
@property (nonatomic, strong) PagingModel *pagingModel;

@property (nonatomic, assign) NSInteger userId;

@property (nonatomic, strong) CTFTopicDetailsViewModel *topicDetailsVM;

@property (nonatomic, strong) CTFBaseBlankView *blankView;//空白页

@end

@implementation CTFMineFansListVC

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
    [self.fansListTView registerClass:[CTFSkeletonCellOne class] forCellReuseIdentifier:@"CTFSkeletonCellOne"];
    [self.fansListTView ctf_showSkeleton];
}

- (void)skeleton_hide {
    [self.fansListTView ctf_hideSkeleton];
    self.fansListTView.rowHeight = UITableViewAutomaticDimension;
    [self.fansListTView reloadData];
    [self.fansListTView ctf_hideSkeleton];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.userId = [self.schemaArgu[@"userId"] integerValue];
    self.baseTitle = @"粉丝";
    self.adpater = [[CTFMineViewModel alloc] init];
    self.topicDetailsVM = [[CTFTopicDetailsViewModel alloc] init];
    [self skeleton_show];
    [self.fansListTView.mj_header beginRefreshing];
}

- (void)downData {
    @weakify(self);
    [self.adpater svr_fetchFansListByUserId:self.userId page:self.pagingModel complete:^(BOOL isSuccess) {
        @strongify(self);
        [self skeleton_hide];
        [self.fansListTView.mj_header endRefreshing];
        [self.fansListTView.mj_footer endRefreshing];
        if (isSuccess) {
            [self hideNetErrorView];
            [self loadDataComplete];
            if ([self.adpater numberOfFansList] == 0) {
                self.blankView.hidden = NO;
            } else {
                self.blankView.hidden = YES;
            }
        }else{
            [self.view makeToast:self.adpater.errorString];
            [self showNetErrorViewWithType:self.adpater.errorType whetherLittleIconModel:NO frame:self.fansListTView.frame];
        }
    }];
}

#pragma mark 刷新试试
-(void)baseRefreshData{
    [self.fansListTView.mj_header beginRefreshing];
}

- (void)loadDataComplete {
    [self.fansListTView reloadData];
    [self createLoadMoreView];
}

- (UITableView *)fansListTView {
    if (!_fansListTView) {
        _fansListTView = [[UITableView alloc] initWithFrame:CGRectMake(0,kNavBar_Height, kScreen_Width, kScreen_Height - kNavBar_Height) style:UITableViewStylePlain];
        _fansListTView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _fansListTView.backgroundColor = [UIColor whiteColor];
        _fansListTView.delegate = self;
        _fansListTView.dataSource = self;
        _fansListTView.estimatedRowHeight = [CTFSkeletonCellOne defaultHeight];
        _fansListTView.rowHeight = UITableViewAutomaticDimension;
        _fansListTView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _fansListTView.showsVerticalScrollIndicator = NO;
        [_fansListTView registerClass:[CTFFansListCell class] forCellReuseIdentifier:@"CTFFansListCell"];
        @weakify(self)
        _fansListTView.mj_header = [[CTRefreshHeader alloc] initWithRefreshingBlock:^{
            @strongify(self)
            [self refreshData];
        }];
        
        [self.view addSubview:_fansListTView];
        [_fansListTView addSubview:self.blankView];
        self.blankView.hidden = YES;
    }
    return _fansListTView;
}

- (void)createLoadMoreView {
    if ([self.adpater hasMoreFansListData]) {
        @weakify(self);
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{
            @strongify(self);
            [self loadmoreData];
        }];
        self.fansListTView.mj_footer = foot;
    }else{
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{
        }];
        self.fansListTView.mj_footer = foot;
        if (self.pagingModel.page > 1) {
            if (self.pagingModel.count < self.pagingModel.pageSize) {
                [foot setState:MJRefreshStateNoMoreData];
            }
        }else{
            if (self.fansListTView.contentSize.height > self.fansListTView.height) {
                [foot setState:MJRefreshStateNoMoreData];
            }else{
                if (self.pagingModel.count < self.pagingModel.pageSize) {
                    self.fansListTView.mj_footer = nil;
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
    self.pagingModel.pageSize = 8;
    [self downData];
}

- (void)loadmoreData {
    self.pagingModel.page++;
    [self downData];
}

#pragma mark - tableViewDataSource,UITableViewDelegate

// 行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.adpater numberOfFansList];
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CTFFansUserModel *model = [self.adpater fansModelAtIndex:indexPath.row];
    if (!self.monitorPull) {
        model.pull.isRead = YES;
    }
    
    CTFFansListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CTFFansListCell"];
    @weakify(self);
    cell.deleteFollowBlock = ^(NSInteger userId, NSInteger indexRow) {
        @strongify(self);
        
        @weakify(self);
        [self.topicDetailsVM followActionToUser:userId needFollow:NO complete:^(BOOL isSuccess) {
            @strongify(self);
            CTFFansUserModel *model = [self.adpater fansModelAtIndex:indexPath.row];
            model.isFollowing = NO;
            [self.fansListTView reloadData];
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
            CTFFansUserModel *model = [self.adpater fansModelAtIndex:indexPath.row];
            model.isFollowing = YES;
            [self.fansListTView reloadData];
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
    
    CTFFansUserModel *model = [self.adpater fansModelAtIndex:indexPath.row];
    [ROUTER routeByCls:kCTFHomePageVC withParam:@{@"userId": @(model.fansId)}];
    model.pull.isRead = YES;
    
    /* 如果是从消息模块跳转进来的，点击cell还需要通知该消息已读（如果消息未读情况下） */
    if (self.monitorPull) {
        if (!kIsEmptyString(model.pull.idString)) {
            [self.adpater svr_readFansMessageByPullId:model.pull.idString complete:^(BOOL isSuccess) {
                if (isSuccess) {
                    CTFPull *pull = [[CTFPull alloc] init];
                    pull.isRead = YES;
                    model.pull = pull;
                    [tableView reloadData];
                }
            }];
        }
    }
}

#pragma mark 空白页
- (CTFBaseBlankView *)blankView{
    if (!_blankView) {
        if (self.userId == [UserCache getUserInfo].userId) {
            _blankView = [[CTFBaseBlankView alloc] initWithFrame:self.fansListTView.bounds blankType:CTFBlankType_FansForMe imageOffY:112];
        } else {
            _blankView = [[CTFBaseBlankView alloc] initWithFrame:self.fansListTView.bounds blankType:CTFBlankType_FansForOther imageOffY:112];
        }
    }
    return _blankView;
}

@end
