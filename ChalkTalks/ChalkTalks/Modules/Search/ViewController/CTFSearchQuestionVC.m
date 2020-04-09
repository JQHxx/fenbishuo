//
//  CTFSearchQuestionVC.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/28.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFSearchQuestionVC.h"
#import "BaseNavigationController.h"
#import "PublishTopicViewController.h"
#import "CTFSearchQuestionListCell.h"
#import "CTFSearchQuestionModel.h"
#import "ChalkTalks-Swift.h"
#import "CTFBasePublishView.h"

#define kViewWidth (kScreen_Width-48)/2.0
#define kViewHeight kViewWidth*(130.0/156.0)

@interface CTFSearchQuestionVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MBProgressHUD *loadingHUD;
@property (nonatomic, strong) UIView *customBlankView;//空白页
@property (nonatomic, strong) CTFBasePublishView *requestView;//提要求
@property (nonatomic, strong) CTFBasePublishView *recommendView;//求推荐
@end

@implementation CTFSearchQuestionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupViewContent];
}

- (void)beginTableViewRefresh {
    if (self.isViewLoaded) {
        self.customBlankView.hidden = YES;
        [self.adpater removeAllSearchResult_question];
        [self.tableView reloadData];
        [self.loadingHUD showAnimated:YES];
        @weakify(self);
        [self.adpater fetchUpdate_QuestionSearchListByKeyword:self.keyword complete:^(BOOL isSuccess) {
            @strongify(self);
            [self.loadingHUD hideAnimated:YES];
            [self loadDataComplete:isSuccess];
        }];
    }
}

- (void)loadDataComplete:(BOOL)isSuccess {
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    [self.tableView reloadData];
    if (isSuccess) {
        [self hideNetErrorView]; //隐藏网络错误
        if ([self.adpater query_QuestionSearchList].count == 0) {
            self.customBlankView.hidden = NO;
        } else {
            self.customBlankView.hidden = YES;
        }
    } else {
        [self.tableView makeToast:self.adpater.errorString];
        if ([self.adpater query_QuestionSearchList].count == 0) {
            [self showNetErrorViewWithType:self.adpater.errorType whetherLittleIconModel:NO frame:self.tableView.frame];
        }
    }
    [self createLoadMoreView];
}

- (void)createLoadMoreView {
    if ([self.adpater fetchMore_QuestionSearchList_Complete:^(BOOL isSuccess) {}]) {
        @weakify(self);
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{
            @strongify(self);
            [self loadmoreData];
        }];
        self.tableView.mj_footer = foot;
    } else if ([self.adpater query_QuestionSearchList].count != 0) {
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{}];
        self.tableView.mj_footer = foot;
        [foot setState:MJRefreshStateNoMoreData];
    } else {
        self.tableView.mj_footer = nil;
    }
}

- (void)loadmoreData {
    @weakify(self);
    [self.adpater fetchMore_QuestionSearchList_Complete:^(BOOL isSuccess) {
        @strongify(self);
        [self loadDataComplete:isSuccess];
    }];
}

// 网络错误空白页上的刷新按钮响应事件
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
    [self.tableView addSubview:self.customBlankView];
    self.customBlankView.hidden = YES;
}

#pragma mark - tableViewDataSource,UITableViewDelegate
// 行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.adpater query_QuestionSearchList].count;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CTFSearchQuestionModel *model = [[self.adpater query_QuestionSearchList] objectAtIndex:indexPath.row];
    
    CTFSearchQuestionListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CTFSearchQuestionListCell"];
    if (!cell) {
        cell = [[CTFSearchQuestionListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CTFSearchQuestionListCell"];
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
    [MobClick event:@"search_topicitem"];
    CTFSearchQuestionModel *model = [[self.adpater query_QuestionSearchList] objectAtIndex:indexPath.row];
    
    NSString *sid = [NSString stringWithFormat:@"%@?questionId=%zd", kCTFTopicDetailsVC, model.questionId];
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
- (UIView *)customBlankView {
    if (!_customBlankView) {
        _customBlankView = [[UIView alloc] initWithFrame:self.tableView.bounds];
        //
        UIImageView *myImgView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreen_Width-120)/2.f, 112, 120, 120)];
        myImgView.image = ImageNamed(@"empty_NoSearch_120x120");
        [_customBlankView addSubview:myImgView];
        //
        UILabel *tipslab = [[UILabel alloc] initWithFrame:CGRectMake(10, myImgView.bottom+20, kScreen_Width-20, 52)];
        tipslab.numberOfLines = 0;
        tipslab.text = @"未匹配到想要的话题\n我来“发布一个新话题~”";
        tipslab.font = [UIFont regularFontWithSize:15];
        tipslab.textColor = [UIColor ctColor99];
        tipslab.textAlignment = NSTextAlignmentCenter;
        [_customBlankView addSubview:tipslab];
        //
        [_customBlankView addSubview:self.requestView];
        //
        [_customBlankView addSubview:self.recommendView];
    }
    return _customBlankView;
}

#pragma mark 提要求
- (CTFBasePublishView *)requestView{
    if (!_requestView) {
        _requestView = [[CTFBasePublishView alloc] initWithFrame:CGRectMake(16, 344, kViewWidth, kViewHeight) desc:@"让大家来帮忙\n评测一样东西" image:@"btn_add_request"];
        _requestView.backgroundColor = UIColorFromHEXWithAlpha(0xFF3568, 0.06);;
        _requestView.tag = 100;
        [_requestView addTapPressed:@selector(seekRecommendationAction:) target:self];
    }
    return _requestView;
}

#pragma mark 求推荐
- (CTFBasePublishView *)recommendView {
    if (!_recommendView) {
        _recommendView = [[CTFBasePublishView alloc] initWithFrame:CGRectMake(self.requestView.right+16, 344, kViewWidth, kViewHeight) desc:@"想要买买买\n但不知道哪个品牌好" image:@"btn_add_recommend"];
        _recommendView.backgroundColor = UIColorFromHEXWithAlpha(0xFFC028, 0.1);
        _recommendView.tag = 101;
        [_recommendView addTapPressed:@selector(seekRecommendationAction:) target:self];
    }
    return _recommendView;
}

- (MBProgressHUD *)loadingHUD {
    if (!_loadingHUD) {
        _loadingHUD = [MBProgressHUD ctfShowLoading:self.view title:nil];
    }
    return _loadingHUD;
}

#pragma mark 提要求、求推荐--响应事件
- (void)seekRecommendationAction:(UITapGestureRecognizer *)gesture {
    if (![self ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded]) {
        return;
    }
    
    NSInteger index = gesture.view.tag-100;
    CTFQuestionsModel *model = [[CTFQuestionsModel alloc] init];
    model.type = index==0?@"demand":@"recommend";
    PublishTopicViewController *topicVC = [[PublishTopicViewController alloc] init];
    topicVC.questionsModel = model;
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:topicVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

@end
