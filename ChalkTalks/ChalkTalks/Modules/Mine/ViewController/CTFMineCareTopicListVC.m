//
//  CTFMineCareTopicListVC.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/18.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFMineCareTopicListVC.h"
#import "CTFMineViewModel.h"
#import "CTFTopicDetailsViewModel.h"
#import "CTFMineCareTopicListCell.h"
#import "CTFSkeletonCellTwo.h"
#import "CTFBaseBlankView.h"

@interface CTFMineCareTopicListVC () <UITableViewDelegate, UITableViewDataSource, CTFSkeletonDelegate>
@property (nonatomic, strong) UITableView *mineCareVoteListTView;
@property (nonatomic, strong) CTFMineViewModel *adpater;
@property (nonatomic, strong) CTFTopicDetailsViewModel *topicViewModel;
@property (nonatomic, strong) PagingModel *pagingModel;

@property (nonatomic, strong) CTFBaseBlankView *blankView;//空白页

@end

@implementation CTFMineCareTopicListVC

#pragma mark - skeleton : function
- (NSInteger)collectionSkeletonView:(UITableView *)skeletonView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)numSectionsIn:(UITableView *)collectionSkeletonView {
    return 1;
}

- (NSString *)collectionSkeletonView:(UITableView *)skeletonView cellIdentifierForRowAt:(NSIndexPath *)indexPath {
    return @"CTFSkeletonCellTwo";
}

- (void)skeleton_show {
    [self.mineCareVoteListTView registerClass:[CTFSkeletonCellTwo class] forCellReuseIdentifier:@"CTFSkeletonCellTwo"];
    [self.mineCareVoteListTView ctf_showSkeleton];
}

- (void)skeleton_hide {
    [self.mineCareVoteListTView ctf_hideSkeleton];
    self.mineCareVoteListTView.rowHeight = UITableViewAutomaticDimension;
    [self.mineCareVoteListTView reloadData];
    [self.mineCareVoteListTView ctf_hideSkeleton];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.baseTitle = @"我关心的";
    self.adpater = [[CTFMineViewModel alloc] init];
    self.topicViewModel = [[CTFTopicDetailsViewModel alloc] init];
    [self.mineCareVoteListTView.mj_header beginRefreshing];
    [self skeleton_show];
}

- (void)downData {
    @weakify(self);
    [self.adpater svr_fetchMineCareTopicListByPage:self.pagingModel complete:^(BOOL isSuccess) {
        @strongify(self);
        [self skeleton_hide];
        [self.mineCareVoteListTView.mj_header endRefreshing];
        [self.mineCareVoteListTView.mj_footer endRefreshing];
        if (isSuccess) {
            [self hideNetErrorView];
            [self loadDataComplete];
            if ([self.adpater numberOfMineCareTopic] == 0) {
                self.blankView.hidden = NO;
            } else {
                self.blankView.hidden = YES;
            }
        } else {
            [self.view makeToast:self.adpater.errorString];
            if ([self.adpater numberOfMineCareTopic] == 0) {
                [self showNetErrorViewWithType:self.adpater.errorType whetherLittleIconModel:NO frame:self.mineCareVoteListTView.frame];
            }
        }
        
    }];
}

#pragma mark 刷新试试
-(void)baseRefreshData{
    [self.mineCareVoteListTView.mj_header beginRefreshing];
}

- (void)loadDataComplete {
    [self.mineCareVoteListTView reloadData];
    
    [self createLoadMoreView];
}

- (UITableView *)mineCareVoteListTView {
    if (!_mineCareVoteListTView) {
        _mineCareVoteListTView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBar_Height, kScreen_Width, kScreen_Height - kNavBar_Height) style:UITableViewStylePlain];
        _mineCareVoteListTView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _mineCareVoteListTView.backgroundColor = [UIColor whiteColor];
        _mineCareVoteListTView.delegate = self;
        _mineCareVoteListTView.dataSource = self;
        _mineCareVoteListTView.estimatedRowHeight = [CTFSkeletonCellTwo defaultHeight];
        _mineCareVoteListTView.rowHeight = UITableViewAutomaticDimension;
        _mineCareVoteListTView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mineCareVoteListTView.showsVerticalScrollIndicator = NO;
        [_mineCareVoteListTView registerClass:[CTFMineCareTopicListCell class] forCellReuseIdentifier:@"CTFMineCareTopicListCell"];
        @weakify(self)
        _mineCareVoteListTView.mj_header = [[CTRefreshHeader alloc] initWithRefreshingBlock:^{
            @strongify(self)
            [self refreshData];
        }];
        [self.view addSubview:_mineCareVoteListTView];
        [_mineCareVoteListTView addSubview:self.blankView];
        self.blankView.hidden = YES;
    }
    return _mineCareVoteListTView;
}

- (void)createLoadMoreView {
    if ([self.adpater hasMoreMineCareTopicListData]) {
        @weakify(self);
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{
            @strongify(self);
            [self loadmoreData];
        }];
        self.mineCareVoteListTView.mj_footer = foot;
    }else{
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{
        }];
        self.mineCareVoteListTView.mj_footer = foot;
        [foot setState:MJRefreshStateNoMoreData];
        if (self.pagingModel.page > 1) {
            if (self.pagingModel.count < self.pagingModel.pageSize) {
                [foot setState:MJRefreshStateNoMoreData];
            }
        }else{
            if (self.mineCareVoteListTView.contentSize.height > self.mineCareVoteListTView.height) {
                [foot setState:MJRefreshStateNoMoreData];
            }else{
                if (self.pagingModel.count < self.pagingModel.pageSize) {
                    self.mineCareVoteListTView.mj_footer = nil;
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
    self.pagingModel.pageSize = 4;
    [self downData];
}

- (void)loadmoreData {
    self.pagingModel.page++;
    [self downData];
}

#pragma mark - tableViewDataSource,UITableViewDelegate

// 行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.adpater numberOfMineCareTopic];
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CTFQuestionsModel *model = [self.adpater mineCareTopicModelAtIndex:indexPath.row];
    
    CTFMineCareTopicListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CTFMineCareTopicListCell"];
    cell.cardIndexPath = indexPath;
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

    CTFQuestionsModel *model = [self.adpater mineCareTopicModelAtIndex:indexPath.row];
    
    NSString *sid = [NSString stringWithFormat:@"%@?questionId=%zd", kCTFTopicDetailsVC, model.questionId];
    APPROUTE(sid);
}

#pragma mark 点击事件
-(void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo{
    if(![self ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded]){
        return;
    }
    CTFQuestionsModel *model = [userInfo safe_objectForKey:kTopicDataModelKey];
    if ([eventName isEqualToString:kTopicLikeEvent]){
        [self.topicViewModel votersToQuestion:model.questionId attitude:model.attitude complete:^(BOOL isSuccess) {
            
        }];
    }else if ([eventName isEqualToString:kTopicUnlikeEvent]){
        [self.topicViewModel votersToQuestion:model.questionId attitude:model.attitude complete:^(BOOL isSuccess) {
            
        }];
    }
}

#pragma mark 空白页
- (CTFBaseBlankView *)blankView {
    if (!_blankView) {
        _blankView = [[CTFBaseBlankView alloc] initWithFrame:self.mineCareVoteListTView.bounds blankType:CTFBlankType_MineCareTopic imageOffY:112];
    }
    return _blankView;
}

@end
