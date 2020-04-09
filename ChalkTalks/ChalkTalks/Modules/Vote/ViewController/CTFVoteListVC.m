//
//  CTFVoteListVC.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/5.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFVoteListVC.h"
#import "UIView+Frame.h"
#import <MJRefresh.h>
#import "UIView+ShowMessageView.h"
#import "MBProgressHUD+CTF.h"
#import "UIView+ShowMessageView.h"
#import "CTFVoteListCell.h"
#import "CTFVoteListHeadView.h"
#import "CTFBaseBlankView.h"

#import "ChalkTalks-Swift.h"

#import <Masonry.h>
#import "CTFSkeletonCellFive.h"
#import "CTFLearningGuideView.h"

typedef void(^MJRefreshBlock)(BOOL isSuccess);

@interface CTFVoteListVC () <UITableViewDelegate, UITableViewDataSource, CTFSkeletonDelegate, CTFVoteListCellDelegate>

@property (nonatomic, strong) UITableView *voteListTView;
@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, assign) NSInteger temp_sign;

@property (nonatomic, strong) CTFVoteListHeadView *voteListHeadView;

@property (nonatomic,strong) CTFBaseBlankView *blankView;  //空白页

@property (nonatomic, assign) BOOL isShowingSkeletonView;//骨架屏是否在展示

@property (nonatomic, copy) MJRefreshBlock refreshBlock;

@property (nonatomic, strong) CTFLearningGuideView *learningGuideView;// 投票页面的学习引导

@end

@implementation CTFVoteListVC

#pragma mark - skeleton : function
- (NSInteger)collectionSkeletonView:(UITableView *)skeletonView numberOfRowsInSection:(NSInteger)section {
    return kScreen_Height / [CTFSkeletonCellFive defaultHeight];
}

- (NSInteger)numSectionsIn:(UITableView *)collectionSkeletonView {
    return 1;
}

- (NSString *)collectionSkeletonView:(UITableView *)skeletonView cellIdentifierForRowAt:(NSIndexPath *)indexPath {
    return @"CTFSkeletonCellFive";
}

- (void)skeleton_show {
    [self.voteListTView registerClass:[CTFSkeletonCellFive class] forCellReuseIdentifier:@"CTFSkeletonCellFive"];
    [self.voteListHeadView ctf_showSkeleton];
    [self.voteListTView ctf_showSkeleton];
    self.isShowingSkeletonView = YES;
}

- (void)skeleton_hide {
    if (!self.isShowingSkeletonView) {
        return;
    }
    [self.voteListHeadView ctf_hideSkeleton];
    [self.voteListTView ctf_hideSkeleton];
    self.voteListTView.rowHeight = UITableViewAutomaticDimension;
    [self.voteListTView reloadData];
    [self.voteListTView ctf_hideSkeleton];
    self.isShowingSkeletonView = NO;
}

#pragma mark - 控制器生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupData];
    [self.view addSubview:self.voteListTView];
    [self.voteListTView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    [self skeleton_show];
    [self refreshDataComplete:nil];// 获取某个频道下的投票列表第一页数据
    if (self.categoryId == 0) {
        [self loadData_carouslesList];// 获取投票的轮播信息
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showLearningWhenViewWillAppear];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideLearningWhenViewWillDisappear];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - 界面搭建
- (void)setupData {
    NSString *categoryIdString = [NSString stringWithFormat:@"%ld", self.categoryId];
    NSString *sortTypeString = [[self.adpater local_queryVoteListSortType] objectForKey:categoryIdString];
    if (sortTypeString && sortTypeString.length > 0) {
        self.sortType = sortTypeString;
    } else {
        self.sortType = @"default";/* @"default"、@"last" */
        [self.adpater local_updateVoteListSortType:@"default" toCategoryId:self.categoryId];
    }
    [self.voteListTView registerClass:[CTFVoteListCell class] forCellReuseIdentifier:@"CTFVoteListCell"];
}

- (void)beginTableViewRefreshWithMJHeadLoading:(BOOL)MJHeadLoading complete:(void(^)(BOOL isSuccess))completeBlock {
    if (self.isViewLoaded) {
        if (MJHeadLoading) {
            [self.voteListTView.mj_header beginRefreshing];
            self.refreshBlock = completeBlock;
        } else {
            [self refreshDataComplete:completeBlock];
        }
    }
}

#pragma mark - 网络请求
// 获取投票的轮播信息
- (void)loadData_carouslesList {
    @weakify(self);
    [self.adpater svr_fetchVoteCarouselsComplete:^(BOOL isSuccess) {
        @strongify(self);
        if (isSuccess) {
            [self.voteListHeadView updateDataByWheelData:[self.adpater carouselsMessageList] sortType:self.sortType];
        }
    }];
}

// 获取某个频道下的投票列表第一页数据
- (void)refreshDataComplete:(void(^)(BOOL isSuccess))completeBlock {
    
    [self.adpater resetPageModelByCategoryId:self.categoryId];
    PagingModel *currentPageModel = [self.adpater fetchPageModelByCategoryId:self.categoryId];
    @weakify(self);
    [self.adpater svr_fetchVoteListByCategoryID:self.categoryId page:currentPageModel sortType:self.sortType complete:^(BOOL isSuccess) {
        @strongify(self);
        [self skeleton_hide];
        [self loadDataComplete:isSuccess];
        if (completeBlock) {
            completeBlock(isSuccess);
        }
        if (!isSuccess) {
            self.isShowingSkeletonView = YES;
        }
    }];
}

// 获取某个频道下的投票列表数据
- (void)loadmoreData {
    
    PagingModel *currentPageModel = [self.adpater fetchPageModelByCategoryId:self.categoryId];
    currentPageModel.page++;
    @weakify(self);
    [self.adpater svr_fetchVoteListByCategoryID:self.categoryId page:currentPageModel sortType:self.sortType complete:^(BOOL isSuccess) {
        @strongify(self);
        [self loadDataComplete:isSuccess];
    }];
}

#pragma mark - 刷新界面
- (void)loadDataComplete:(BOOL)isSuccess {
    [self.voteListTView.mj_header endRefreshing];
    [self.voteListTView.mj_footer endRefreshing];
    
    if (isSuccess) {
        [self hideNetErrorView]; //隐藏网络错误
        [self.voteListTView reloadData];
        
        if (self.categoryId == 0) {
            [self loadData_carouslesList];
        } else {
            [self.voteListHeadView updateDataByAccount:[self.adpater totalOfVoteListByCatogoryId:self.categoryId] sortType:self.sortType];
        }
        
        if ([self.adpater totalOfVoteListByCatogoryId:self.categoryId] == 0) {
            self.voteListHeadView.hidden = YES;
            self.blankView.hidden = NO;
        } else {
            self.voteListHeadView.hidden = NO;
            self.blankView.hidden = YES;
            /* 2.1.10版本先不使用
            // 显示学习引导页
            [self addsubViewVoteLearningView];
             */
        }
        
    } else {
        [self.voteListTView makeToast:self.adpater.errorString];
        if ([self.adpater totalOfVoteListByCatogoryId:self.categoryId] == 0) {
            [self showNetErrorViewWithType:self.adpater.errorType whetherLittleIconModel:NO frame:self.voteListTView.frame];
            self.blankView.hidden = YES;
            self.voteListHeadView.hidden = YES;
        }
    }
    [self createLoadMoreView];
}

-(void)baseRefreshData{
    [self hideNetErrorView];
    [self refreshDataComplete:nil];
}

#pragma mark - 懒加载
- (UITableView *)voteListTView {
    if (!_voteListTView) {
        _voteListTView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _voteListTView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _voteListTView.backgroundColor = [UIColor whiteColor];
        _voteListTView.delegate = self;
        _voteListTView.dataSource = self;
        _voteListTView.estimatedRowHeight = [CTFSkeletonCellFive defaultHeight];
        _voteListTView.rowHeight = UITableViewAutomaticDimension;
        _voteListTView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _voteListTView.showsVerticalScrollIndicator = NO;
        [_voteListTView registerClass:[CTFVoteListCell class] forCellReuseIdentifier:@"CTFVoteListCell"];
        [_voteListTView addSubview:self.blankView];
        self.blankView.hidden = YES;
        
        @weakify(self)
        _voteListTView.mj_header = [[CTRefreshHeader alloc] initWithRefreshingBlock:^{
            @strongify(self)
            [self refreshDataComplete:self.refreshBlock];
            if (self.categoryId == 0) {
                [self loadData_carouslesList];
            }
        }];
    }
    return _voteListTView;
}

- (void)createLoadMoreView {
    if ([self.adpater hasMoreData_voteCategoryId:self.categoryId]) {
        @weakify(self);
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{
            @strongify(self);
            [self loadmoreData];
        }];
        self.voteListTView.mj_footer = foot;
    } else if ([self.adpater totalOfVoteListByCatogoryId:self.categoryId] != 0) {
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{}];
        self.voteListTView.mj_footer = foot;
        [foot setState:MJRefreshStateNoMoreData];
    } else {
        self.voteListTView.mj_footer = nil;
    }
}

#pragma mark 空白页
- (CTFBaseBlankView *)blankView{
    if (!_blankView) {
        _blankView = [[CTFBaseBlankView alloc] initWithFrame:self.voteListTView.bounds blankType:CTFBlankType_VoteList imageOffY:120];
    }
    return _blankView;
}

#pragma mark - tableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// 行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger cellNumber = [self.adpater numberOfList_voteCategoryId:self.categoryId];
    return cellNumber;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CTFQuestionsModel *model = [self.adpater voteModelForCategoryId:self.categoryId index:indexPath.row];
    CTFVoteListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CTFVoteListCell"];
    cell.delegate = self;
    [cell fillContentWithData:model indexNum:indexPath.row sortType:self.sortType];
    return cell;
}

// 区尾高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

//当已经点击cell时
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.index==0) {
        [MobClick event:@"vote_listitemclick"];
    }
}

// 自定义sectionheader显示的view
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.voteListHeadView;
}

// 设置sectionheader的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 36;
}

#pragma mark - CTFVoteListCellDelegate
// 点击cell
- (void)tableViewCell:(CTFVoteListCell *)cell touchedSkipQuestionDetailId:(NSInteger)questionId {
    NSString *sid = [NSString stringWithFormat:@"%@?questionId=%zd", kCTFTopicDetailsVC, questionId];
    APPROUTE(sid);
}

#pragma mark -- Event
#pragma mark 事件传递
-(void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo{
    if(![self ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded]){
        return;
    }
    CTFQuestionsModel *model = [userInfo safe_objectForKey:kTopicDataModelKey];
    if ([eventName isEqualToString:kTopicLikeEvent]||[eventName isEqualToString:kTopicUnlikeEvent]){
        [self.adpater svr_voteQuestionId:model.questionId toState:model.attitude complete:^(BOOL isSuccess) {
            
        }];
    } else if ([eventName isEqualToString:kViewpointUserInfoEvent]){
        [ROUTER routeByCls:kCTFHomePageVC withParam:@{@"userId": @(model.author.authorId)}];
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

- (CTFVoteListHeadView *)voteListHeadView {
    if (!_voteListHeadView) {
        if (self.categoryId == 0) {
            _voteListHeadView = [[CTFVoteListHeadView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 36) wheelData:@[] sortType:self.sortType];
        } else {
            _voteListHeadView = [[CTFVoteListHeadView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 36) account:0 sortType:self.sortType];
        }
    }
    return _voteListHeadView;
}

#pragma mark - 投票的学习引导

// 显示投票的学习引导
- (void)addsubViewVoteLearningView {
    if (self.categoryId == 0 && ![CTFSystemCache query_showedLearningGuideForFunctionView:CTFLearningGuideViewType_Vote] && self.learningGuideView == nil) {
        
        [self handleApplicationDidEnterBackground];
        
        NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        CGRect rectInTableView = [self.voteListTView rectForRowAtIndexPath:cellIndexPath];
        CGRect rect = [self.voteListTView convertRect:rectInTableView toView:kAPPDELEGATE.window];

        CGRect cellRect = CGRectMake(rect.origin.x+16, rect.origin.y+8, rect.size.width-32, rect.size.height-16);
        
        CGRect ignoreRect = CGRectMake(cellRect.origin.x+cellRect.size.width-40, cellRect.origin.y, 40, cellRect.size.height);
        
        CGRect frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
        
        @weakify(self);
        CTFLearningGuideView *learningGuideView = [[CTFLearningGuideView alloc] initWithFrame:frame alpha:0.7 hollowFrame:cellRect hollowCornerRadius:8 imageName:@"icon_vote_learningGuide_179x100" imageFrame:CGRectMake(cellRect.origin.x+cellRect.size.width-179-12, cellRect.origin.y-100+15, 179, 100) ignoreRect:ignoreRect clickSelfBlcok:^{
            @strongify(self);
            [self removeVoteLearningView];
        }];
        
        self.learningGuideView = learningGuideView;
        [kAPPDELEGATE.window addSubview:learningGuideView];
    }
}

// 隐藏投票的学习引导
- (void)removeVoteLearningView {
    [self.learningGuideView removeFromSuperview];
    self.learningGuideView = nil;
    [CTFSystemCache revise_showedLearningGuide:YES ForFunctionView:CTFLearningGuideViewType_Vote];
}

// UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.learningGuideView && self.learningGuideView.hidden == NO) {
        scrollView.contentOffset = CGPointMake(0, 0);
    }
}

//
- (void)showLearningWhenViewWillAppear {
    self.learningGuideView.hidden = NO;
}

//
- (void)hideLearningWhenViewWillDisappear {
    self.learningGuideView.hidden = YES;
}

//
- (void)handleApplicationDidEnterBackground {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeVoteLearningView) name:kApplicationWillTerminateNotification object:nil];
}

@end
