//
//  CTFMineTopicListVC.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/18.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFMineTopicListVC.h"
#import "CTFMineViewModel.h"
#import "CTFTopicDetailsViewModel.h"
#import "CTFMineVoteListCell.h"
#import "CTFSkeletonCellTwo.h"
#import "CTFBaseBlankView.h"

@interface CTFMineTopicListVC () <UITableViewDelegate, UITableViewDataSource, CTFSkeletonDelegate>
@property (nonatomic, strong) UITableView *mineTopicListTView;
@property (nonatomic, strong) CTFMineViewModel *adpater;
@property (nonatomic, strong) CTFTopicDetailsViewModel *topicViewModel;
@property (nonatomic, strong) PagingModel *pagingModel;

@property (nonatomic, strong) CTFBaseBlankView *blankView;//空白页

@end

@implementation CTFMineTopicListVC

#pragma mark - skeleton : function
- (NSInteger)collectionSkeletonView:(UITableView *)skeletonView numberOfRowsInSection:(NSInteger)section {
    return kScreen_Height / [CTFSkeletonCellTwo defaultHeight];
}

- (NSInteger)numSectionsIn:(UITableView *)collectionSkeletonView {
    return 1;
}

- (NSString *)collectionSkeletonView:(UITableView *)skeletonView cellIdentifierForRowAt:(NSIndexPath *)indexPath {
    return @"CTFSkeletonCellTwo";
}

- (void)skeleton_show {
    [self.mineTopicListTView registerClass:[CTFSkeletonCellTwo class] forCellReuseIdentifier:@"CTFSkeletonCellTwo"];
    [self.mineTopicListTView ctf_showSkeleton];
}

- (void)skeleton_hide {
    [self.mineTopicListTView ctf_hideSkeleton];
    self.mineTopicListTView.rowHeight = UITableViewAutomaticDimension;
    [self.mineTopicListTView reloadData];
    [self.mineTopicListTView ctf_hideSkeleton];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.baseTitle = @"我想知道";
    self.adpater = [[CTFMineViewModel alloc] init];
    self.topicViewModel = [[CTFTopicDetailsViewModel alloc] init];
    [self.mineTopicListTView.mj_header beginRefreshing];
    [self skeleton_show];
}

- (void)downData {
    @weakify(self);
    [self.adpater svr_fetchMineTopicListByPage:self.pagingModel complete:^(BOOL isSuccess) {
        @strongify(self);
        [self skeleton_hide];
        [self.mineTopicListTView.mj_header endRefreshing];
        [self.mineTopicListTView.mj_footer endRefreshing];
        if (isSuccess) {
            [self hideNetErrorView];
            [self loadDataComplete];
            if ([self.adpater numberOfMineTopic] == 0) {
                self.blankView.hidden = NO;
            } else {
                self.blankView.hidden = YES;
            }
        }else{
            [self.view makeToast:self.adpater.errorString];
            [self showNetErrorViewWithType:self.adpater.errorType whetherLittleIconModel:NO frame:self.mineTopicListTView.frame];
        }
    }];
}

#pragma mark 刷新试试
-(void)baseRefreshData{
    [self.mineTopicListTView.mj_header beginRefreshing];
}

- (void)loadDataComplete {
    [self.mineTopicListTView reloadData];
    [self createLoadMoreView];
}

- (UITableView *)mineTopicListTView {
    if (!_mineTopicListTView) {
        _mineTopicListTView = [[UITableView alloc] initWithFrame:CGRectMake(0,kNavBar_Height, kScreen_Width, kScreen_Height - kNavBar_Height) style:UITableViewStylePlain];
        _mineTopicListTView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _mineTopicListTView.backgroundColor = [UIColor whiteColor];
        _mineTopicListTView.delegate = self;
        _mineTopicListTView.dataSource = self;
        _mineTopicListTView.estimatedRowHeight = [CTFSkeletonCellTwo defaultHeight];
        _mineTopicListTView.rowHeight = UITableViewAutomaticDimension;
        _mineTopicListTView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mineTopicListTView.showsVerticalScrollIndicator = NO;
        [_mineTopicListTView registerClass:[CTFMineVoteListCell class] forCellReuseIdentifier:@"CTFMineVoteListCell"];
        @weakify(self)
        _mineTopicListTView.mj_header = [[CTRefreshHeader alloc] initWithRefreshingBlock:^{
            @strongify(self)
            [self refreshData];
        }];
        [self.view addSubview:_mineTopicListTView];
        [_mineTopicListTView addSubview:self.blankView];
        self.blankView.hidden = YES;
    }
    return _mineTopicListTView;
}

- (void)createLoadMoreView {
    if ([self.adpater hasMoreMineTopicListData]) {
        @weakify(self);
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{
            @strongify(self);
            [self loadmoreData];
        }];
        self.mineTopicListTView.mj_footer = foot;
    }else{
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{
        }];
        self.mineTopicListTView.mj_footer = foot;
                if (self.pagingModel.page > 1) {
            if (self.pagingModel.count < self.pagingModel.pageSize) {
                [foot setState:MJRefreshStateNoMoreData];
            }
        }else{
            if (self.mineTopicListTView.contentSize.height > self.mineTopicListTView.height) {
                [foot setState:MJRefreshStateNoMoreData];
            }else{
                if (self.pagingModel.count < self.pagingModel.pageSize) {
                    self.mineTopicListTView.mj_footer = nil;
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
    return [self.adpater numberOfMineTopic];
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CTFMineVoteListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CTFMineVoteListCell"];
    CTFQuestionsModel *model = [self.adpater mineTopicModelAtIndex:indexPath.row];
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
    CTFQuestionsModel *model = [self.adpater mineTopicModelAtIndex:indexPath.row];
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
        _blankView = [[CTFBaseBlankView alloc] initWithFrame:self.mineTopicListTView.bounds blankType:CTFBlankType_MineTopic imageOffY:112];
    }
    return _blankView;
}

@end
