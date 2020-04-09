//
//  CTFCommentListVC.m
//  ChalkTalks
//
//  Created by vision on 2020/3/24.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFCommentListVC.h"
#import "CTFReportTypeOptionVC.h"
#import "CTFCommentViewModel.h"
#import "CTFViewpointTableViewCell.h"
#import "CTFCommentTableViewCell.h"
#import "CTFCommentToolView.h"
#import "CTFCommentBottomView.h"
#import "CTFBaseBlankView.h"
#import "CTFMoreHandleView.h"
#import "UIResponder+Event.h"
#import <HWPanModal.h>
#import <IQKeyboardManager.h>
#import "CTFCommonManager.h"

@interface CTFCommentListVC ()<UITableViewDelegate,UITableViewDataSource,HWPanModalPresentable>

@property (nonatomic,strong) UIView               *navView;
@property (nonatomic,strong) UILabel              *titleLab;
@property (nonatomic,strong) UITableView          *commentTableView;
@property (nonatomic,strong) CTFCommentBottomView *bottomView;
@property (nonatomic,strong) CTFBaseBlankView     *blankView;          //空白页
@property (nonatomic,strong) CTFCommentToolView   *commentToolView;    //评论输入框
//viewmodel
@property (nonatomic,strong) CTFCommentViewModel  *commentViewModel;
@property (nonatomic,strong) PagingModel          *pagingModel;

@property (nonatomic, copy ) NSString             *authorName;       //作者
@property (nonatomic,strong) CTFCommentModel      *currentComment;   //当前被回复的评论
//加载器
@property (nonatomic,strong) MBProgressHUD        *hud;
@property (nonatomic,assign) BOOL     needRefresh;

@end

@implementation CTFCommentListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isHiddenNavBar = YES;
   
    self.needRefresh = NO;
    self.authorName = self.name;
    self.commentViewModel = [[CTFCommentViewModel alloc] initWithAnswerId:self.answerId];
    
    [self initCommentListView];
    [self fetchDataAnimation:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = NO;
    [self hw_panModalTransitionTo:PresentationStateLong animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.commentViewModel numberOfCommentsList];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CTFCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(CTFCommentTableViewCell.class) forIndexPath:indexPath];
    CTFCommentModel *model = [self.commentViewModel getCommentModelWithIndex:indexPath.row];
    NSInteger commentCount = [self.commentViewModel answerAllCommentCount];
    [cell fillCommentData:model answerId:self.answerId commentCount:commentCount];
    @weakify(self);
    cell.setCellExpandBlock = ^{
        @strongify(self);
        [self.commentTableView reloadData];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CTFCommentModel *model = [self.commentViewModel getCommentModelWithIndex:indexPath.row];
    return [CTFCommentTableViewCell getCommentCellHeight:model];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark HWPanModalPresentable
#pragma mark 支持同步拖拽的scrollView
- (nullable UIScrollView *)panScrollable {
    return self.commentTableView;
}

#pragma mark 当pan状态为long的高度
- (PanModalHeight)longFormHeight {
    return PanModalHeightMake(PanModalHeightTypeMaxTopInset, kStatusBar_Height);
}

- (CGFloat)topOffset {
    return 0;
}

- (BOOL)showDragIndicator {
    return NO;
}

- (BOOL)isAutoHandleKeyboardEnabled {
    return NO;
}

- (BOOL)allowsExtendedPanScrolling {
    return YES;
}

#pragma mark -- Event response
#pragma mark 事件传递
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo{
    CTFCommentModel *model = [userInfo valueForKey:kCommentDataModelKey];
    if ([eventName isEqualToString:kViewpointUserInfoEvent]) {
        BOOL commentIn = [userInfo safe_integerForKey:@"commentIn"];
        CTFHomePageVC *homepageVC = [[CTFHomePageVC alloc] init];
        homepageVC.schemaArgu = @{@"userId":@(model.author.authorId),@"commentIn":@(commentIn)};
        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:homepageVC];
        nav.modalPresentationStyle = UIModalPresentationCustom;
        [self presentViewController:nav animated:YES completion:nil];
    } else if ([eventName isEqualToString:kCommentReplyEvent]) { //回复评论
        self.currentComment = model;
        self.authorName = self.currentComment.author.name;
        NSString *content = [[CTDrafts share] getCommentWithAnswerId:self.answerId commentId:self.currentComment.commentId];
        [self showCommentInputToolWithIsAuthor:NO content:content];
    } else if ([eventName isEqualToString:kCommentReliableEvent]){ //设置靠谱
        [self.commentViewModel voteCommentWithCommentId:model.commentId attitude:model.attitude complete:^(BOOL isSuccess) {
            
        }];
    } else if ([eventName isEqualToString:kCommentMoreHandleEvent]){//更多操作
        @weakify(self);
        [CTFMoreHandleView showMoreHandleViewWithFrame:CGRectMake(0, 0, kScreen_Width,100+kTabBar_Height) isAuthor:model.isAuthor isReply:model.isReply  handle:^{
            @strongify(self);
            if (model.isAuthor) { //删除评论
                [self deleteCommentWithId:model.commentId];
            } else { //举报评论
                [self reportCommentWithId:model.commentId isReply:model.isReply];
            }
        }];
    }
}

#pragma mark 关闭
- (void)closeCurrentVC {
    NSString *currentContent = self.bottomView.content;
    //保存回答草稿
    if (!kIsEmptyString(currentContent)) {
        [[CTDrafts share] storeCommentWithAnswerId:self.answerId content:currentContent];
    }
    NSInteger commentCount = [self.commentViewModel answerAllCommentCount];
    self.dismissCallBack(self.needRefresh, commentCount);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- Private methods
#pragma mark 加载数据
- (void)fetchDataAnimation:(BOOL)isAnimation {
    if (isAnimation) {
        self.hud = [MBProgressHUD ctfShowLoading:self.view title:nil];
    }
    @weakify(self);
    [self.commentViewModel loadCommentsListByPage:self.pagingModel complete:^(BOOL isSuccess) {
        @strongify(self);
        [self.hud hideAnimated:YES];
        [self.commentTableView.mj_footer endRefreshing];
        if (isSuccess) {
            [self hideNetErrorView]; //隐藏网络错误
            [self.commentTableView reloadData];
            [self createLoadMoreView];
            
            NSInteger totalComment = [self.commentViewModel numberOfCommentsList];
            self.blankView.hidden = totalComment>0;
            if (totalComment==0) {
                [self showCommentInputToolWithIsAuthor:YES content:self.bottomView.content];
            }
            NSInteger commentCount = [self.commentViewModel answerAllCommentCount];
            self.titleLab.text = [NSString stringWithFormat:@"全部%ld条评论",commentCount];
            
            [self hw_panModalSetNeedsLayoutUpdate];
        } else {
            if (self.pagingModel.page>1) {
                self.pagingModel.page -- ;
            }
            [self.commentTableView makeToast:self.commentViewModel.errorString];
            [self showNetErrorViewWithType:self.commentViewModel.errorType whetherLittleIconModel:YES frame:self.commentTableView.frame]; //显示网络错误
        }
    }];
}

#pragma mark 加载更多
- (void)createLoadMoreView {
    if ([self.commentViewModel hasMoreCommentsListData]) {
        @weakify(self);
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{
            @strongify(self);
            [self loadMoreCommentsListData];
        }];
        self.commentTableView.mj_footer = foot;
    } else if (![self.commentViewModel isEmpty]) {
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{
            
        }];
        self.commentTableView.mj_footer = foot;
        [foot setState:MJRefreshStateNoMoreData];
    } else{
        self.commentTableView.mj_footer = nil;
    }
}

#pragma mark 加载更多评论数据
-(void)loadMoreCommentsListData{
    self.pagingModel.page ++;
    [self fetchDataAnimation:NO];
}

#pragma mark 刷新数据
-(void)baseRefreshData{
    self.pagingModel.page = 1;
    [self fetchDataAnimation:YES];
}

#pragma mark 初始化
- (void)initCommentListView {
    [self.view addSubview:self.navView];
    [self.view addSubview:self.commentTableView];
    [self.view addSubview:self.bottomView];
    [self.commentTableView addSubview:self.blankView];
    self.blankView.hidden = YES;
}

#pragma mark 提交评论
- (void)submitCommentInfoWithContent:(NSString *)content{
    self.hud = [MBProgressHUD ctfShowLoading:self.view title:nil];
    @weakify(self);
    if (self.currentComment) { //回复评论
        [self.commentViewModel createReplyWithCommentId:self.currentComment.commentId content:content complete:^(BOOL isSuccess) {
            @strongify(self);
            [self.hud hideAnimated:YES];
            self.authorName = self.name;
            self.bottomView.content = @"";
            if (isSuccess) {
                [kKeyWindow makeToast:@"评论成功"];
                
                //重置所选评论
                if (self.currentComment) {
                    //删除草稿
                    [[CTDrafts share] removeCommentWithAnswerId:self.answerId commentId:self.currentComment.commentId];
                    self.currentComment = nil;
                }
                
                //发布成功通知
                self.needRefresh = YES;
                NSInteger commentCount = [self.commentViewModel answerAllCommentCount];
                NSDictionary *dict = @{@"commentCount":@(commentCount)};
                [[NSNotificationCenter defaultCenter] postNotificationName:kPublishCommentsNotification object:dict];
                
                //更新界面
                self.titleLab.text = [NSString stringWithFormat:@"全部%ld条评论",commentCount];
                [self.commentTableView reloadData];
                [self hw_panModalSetNeedsLayoutUpdate];
            } else {
                [self.commentTableView makeToast:self.commentViewModel.errorString];
            }
        }];
    } else { //评论观点
        [MobClick event:@"comment_submit"];
        [self.commentViewModel createCommentWithContent:content complete:^(BOOL isSuccess) {
            @strongify(self);
            [self.hud hideAnimated:YES];
            self.bottomView.content = @"";
            if (isSuccess) {
                [kKeyWindow makeToast:@"评论成功"];
                //删除草稿
                [[CTDrafts share] removeCommentWithAnswerId:self.answerId];
                
                //发布成功通知
                self.needRefresh = YES;
                NSInteger commentCount = [self.commentViewModel answerAllCommentCount];
                NSDictionary *dict = @{@"commentCount":@(commentCount)};
                [[NSNotificationCenter defaultCenter] postNotificationName:kPublishCommentsNotification object:dict];
                
                //更新界面
                self.titleLab.text = [NSString stringWithFormat:@"全部%ld条评论",commentCount];
                self.blankView.hidden = YES;
                [self.commentTableView reloadData];
                [self.commentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
                [self hw_panModalSetNeedsLayoutUpdate];
            } else {
                [self.commentTableView makeToast:self.commentViewModel.errorString];
            }
        }];
    }
}

#pragma mark 删除评论
- (void)deleteCommentWithId:(NSInteger)commentId{
    self.hud = [MBProgressHUD ctfShowLoading:self.view title:nil];
    @weakify(self);
    [self.commentViewModel deleteCommentWithCommentId:commentId complete:^(BOOL isSuccess) {
        @strongify(self);
        [self.hud hideAnimated:YES];
        if (isSuccess) {
            [self.commentTableView reloadData];
            [self.commentTableView makeToast:@"删除成功"];
        } else {
            [self.commentTableView makeToast:self.commentViewModel.errorString];
        }
    }];
}

#pragma mark 举报评论
- (void)reportCommentWithId:(NSInteger)commentId isReply:(BOOL)isReply {
    FeedBackType feedBackType = isReply ? FeedBackType_Reply : FeedBackType_Comment;
    CTFReportTypeOptionVC *reportTypeOptionVC = [[CTFReportTypeOptionVC alloc] initWithFeedBackType:feedBackType resourceTypeId:commentId];
    reportTypeOptionVC.dismissBlock = ^{
        
    };
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:reportTypeOptionVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark 显示评论输入框
- (void)showCommentInputToolWithIsAuthor:(BOOL)isAuthor content:(NSString *)content{
    [CTFCommentToolView showCommentInputViewWithFrame:CGRectMake(0,kScreen_Height, kScreen_Width, 157) type:CTFInputToolViewTypeComment  isAuthor:isAuthor name:self.authorName content:content submit:^(NSString *content) {
        [self submitCommentInfoWithContent:content];
    } dismiss:^(NSString *content) {
        if (self.currentComment) {
            if (!kIsEmptyString(content)) {
                [[CTDrafts share] storeCommentWithAnswerId:self.answerId commentId:self.currentComment.commentId content:content];
            } else {
                [[CTDrafts share] removeCommentWithAnswerId:self.answerId commentId:self.currentComment.commentId];
            }
            self.currentComment = nil;
        } else {
            self.bottomView.content = content;
            if (!kIsEmptyString(content)) {
                [[CTDrafts share] storeCommentWithAnswerId:self.answerId content:content];
            }   
        }
    }];
}

#pragma mark -- Getters
#pragma mark 导航栏
- (UIView *)navView {
    if (!_navView) {
        _navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 50)];
        _navView.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(50,10, kScreen_Width-100, 30)];
        titleLab.font = [UIFont mediumFontWithSize:16];
        titleLab.textColor = [UIColor ctColor33];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.text = @"全部0条评论";
        [_navView addSubview:titleLab];
        self.titleLab = titleLab;
        
        UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(10,10, 30, 30)];
        [closeBtn setImage:ImageNamed(@"comment_icon_close") forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(closeCurrentVC) forControlEvents:UIControlEventTouchUpInside];
        [_navView addSubview:closeBtn];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49, kScreen_Width, 1)];
        lineView.backgroundColor = UIColorFromHEXWithAlpha(0x999999, 0.19);
        [_navView addSubview:lineView];
    }
    return _navView;
}

#pragma mark 主页
- (UITableView *)commentTableView {
    if (!_commentTableView) {
        _commentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.navView.bottom, kScreen_Width, kScreen_Height - self.navView.bottom - 50 - kStatusBar_Height) style:UITableViewStylePlain];
        _commentTableView.rowHeight = UITableViewAutomaticDimension;
        [_commentTableView registerClass:CTFCommentTableViewCell.class forCellReuseIdentifier:NSStringFromClass(CTFCommentTableViewCell.class)];
        _commentTableView.estimatedRowHeight = 60;
        _commentTableView.estimatedSectionHeaderHeight = 0;
        _commentTableView.estimatedSectionFooterHeight = 0;
        _commentTableView.delegate = self;
        _commentTableView.dataSource = self;
        _commentTableView.tableFooterView = [[UIView alloc] init];
        _commentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _commentTableView;
}

#pragma mark 发布评论
-(CTFCommentBottomView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[CTFCommentBottomView alloc] initWithFrame:CGRectMake(0, kScreen_Height - kTabBar_Height - kStatusBar_Height, kScreen_Width, kTabBar_Height)];
        NSString *defaultContent = [[CTDrafts share] getCommentWithAnswerId:self.answerId];
        _bottomView.content = defaultContent;
        kSelfWeak;
        _bottomView.handleBlock = ^(NSInteger index) {
            if (index == 0) {
                weakSelf.authorName = weakSelf.name;
                [weakSelf showCommentInputToolWithIsAuthor:YES content:weakSelf.bottomView.content];
            } else {
                [weakSelf submitCommentInfoWithContent:weakSelf.bottomView.content];
            }
        };
    }
    return _bottomView;
}

#pragma mark 空白页
-(CTFBaseBlankView *)blankView{
    if (!_blankView) {
        _blankView = [[CTFBaseBlankView alloc] initWithFrame:self.commentTableView.bounds blankType:CTFBlankTypeComment imageOffY:158];
    }
    return _blankView;
}

-(PagingModel *)pagingModel{
    if (!_pagingModel) {
        _pagingModel = [[PagingModel alloc] init];
        _pagingModel.page = 1;
        _pagingModel.pageSize = 8;
    }
    return _pagingModel;
}




@end
