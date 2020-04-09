//
//  CTFCommentDetailsVC.m
//  ChalkTalks
//
//  Created by vision on 2020/2/21.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFCommentDetailsVC.h"
#import "CTFCommentView.h"
#import "CTFCommentsTableView.h"
#import "CTFCommentBottomView.h"
#import "CTFCommentToolView.h"
#import "CTFMoreHandleView.h"
#import "CTFCommentViewModel.h"
#import "NSString+Size.h"
#import "UIResponder+Event.h"
#import "CTFReportTypeOptionVC.h"
#import <HWPanModal.h>
#import <IQKeyboardManager.h>

@interface CTFCommentDetailsVC ()<HWPanModalPresentable>

@property (nonatomic,strong) UIView               *navBarView;
@property (nonatomic,strong) UIScrollView         *rootScrollView;
@property (nonatomic,strong) CTFCommentView       *mainCommentView;
@property (nonatomic,strong) UIView               *headView;
@property (nonatomic,strong) CTFCommentsTableView *subCommentsView;
@property (nonatomic,strong) CTFCommentBottomView *bottomView;
@property (nonatomic,strong) CTFCommentToolView   *commentToolView;    //评论输入框

@property (nonatomic,strong) PagingModel          *pagingModel;
@property (nonatomic,strong) CTFCommentViewModel  *commentViewModel;
@property (nonatomic,strong) CTFCommentModel      *currentComment; //被回复的评论
@property (nonatomic, copy ) NSString             *authorName;
@property (nonatomic,strong) MBProgressHUD        *hud;

@end

@implementation CTFCommentDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    
    self.authorName = self.model.author.name;
    
    [self initCommentDetailsView];
    [self loadCommentDetailsDataAnimation:YES];
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

#pragma mark -- HWPanModalPresentable
#pragma mark 支持同步拖拽的scrollView
- (nullable UIScrollView *)panScrollable {
    return self.rootScrollView;
}

#pragma mark 当pan状态为long的高度
- (PanModalHeight)longFormHeight {
    return PanModalHeightMake(PanModalHeightTypeMaxTopInset,kStatusBar_Height);
}

- (CGFloat)topOffset {
    return 0;
}

#pragma mark 是否显示drag指示view
- (BOOL)showDragIndicator {
    return NO;
}

- (BOOL)allowsExtendedPanScrolling {
    return YES;
}

#pragma mark -- Event Response
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
        [self showCommentInputWithContent:content];
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
                [self reportCommentWithId:model.commentId];
            }
        }];
    }
}

#pragma mark 返回
- (void)leftNavigationItemAction {
    NSString *currentContent = self.bottomView.content;
    //保存回答草稿
    if (!kIsEmptyString(currentContent)) {
        [[CTDrafts share] storeCommentWithAnswerId:self.answerId commentId:self.model.commentId content:currentContent];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- Private methods
#pragma mark 初始化
- (void)initCommentDetailsView{
    [self.view addSubview:self.navBarView];
    [self.view addSubview:self.rootScrollView];
    [self.rootScrollView addSubview:self.mainCommentView];
    [self.rootScrollView addSubview:self.headView];
    [self.rootScrollView addSubview:self.subCommentsView];
    [self.view addSubview:self.bottomView];
}

#pragma mark 加载数据
- (void)loadCommentDetailsDataAnimation:(BOOL)isAnimation{
    if (isAnimation) {
        self.hud = [MBProgressHUD ctfShowLoading:self.view title:nil];
    }
    [self.commentViewModel loadSubCommentsDataByPage:self.pagingModel commentId:self.model.commentId complete:^(BOOL isSuccess) {
        [self.hud hideAnimated:YES];
        [self.rootScrollView.mj_footer endRefreshing];
        if (isSuccess) {
            self.model.childComments = [self.commentViewModel subCommentsData];
            self.subCommentsView.commentModel = self.model;
            [self updateUI];
            [self createLoadMoreView];
            [self hw_panModalSetNeedsLayoutUpdate];
        } else {
            self.pagingModel.page -- ;
            [self.view makeToast:self.commentViewModel.errorString duration:1.0 position:CSToastPositionCenter];
        }
    }];
}

#pragma mark 加载更多
- (void)loadMoreSubCommentsData{
    self.pagingModel.page ++ ;
    [self loadCommentDetailsDataAnimation:NO];
}

#pragma mark  加载更多
- (void)createLoadMoreView {
    if ([self.commentViewModel hasMoreSubCommentsData]) {
        @weakify(self);
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{
            @strongify(self);
            [self loadMoreSubCommentsData];
        }];
        self.rootScrollView.mj_footer = foot;
    } else {
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{
            
        }];
        self.rootScrollView.mj_footer = foot;
        [foot setState:MJRefreshStateNoMoreData];
    }
}

#pragma mark 更新UI
- (void)updateUI{
    //主评论
    [self.mainCommentView fillCommentData:self.model];
    NSString *mainContent = self.model.isDeleted?@"该评论已删除":self.model.content;
    CGFloat contentH = [mainContent boundingRectWithSize:CGSizeMake(kScreen_Width-72, CGFLOAT_MAX) withTextFont:[UIFont regularFontWithSize:15]].height;
    self.mainCommentView.frame = CGRectMake(0, 0, kScreen_Width, contentH+73);
    
    //头部视图
    self.headView.frame = CGRectMake(0, self.mainCommentView.bottom, kScreen_Width, 50);
    
    CGFloat childCommentH = 0;
    for (CTFCommentModel *model in self.model.childComments) {
        NSString *content = model.isDeleted?@"该评论已删除":model.content;
        CGFloat tempH = [content boundingRectWithSize:CGSizeMake(kScreen_Width-72, CGFLOAT_MAX) withTextFont:[UIFont regularFontWithSize:15]].height;
        childCommentH += tempH+73;
    }
    self.subCommentsView.frame = CGRectMake(0, self.headView.bottom, kScreen_Width, childCommentH);
    [self.rootScrollView setContentSize:CGSizeMake(kScreen_Width, self.subCommentsView.bottom)];
}

#pragma mark 发布评论
- (void)submitCommentWithContent:(NSString *)content{
    NSInteger commentId = self.currentComment?self.currentComment.commentId:self.model.commentId;
    self.hud = [MBProgressHUD ctfShowLoading:self.view title:@"发布中..."];
    @weakify(self);
    [self.commentViewModel createReplyWithCommentId:commentId content:content complete:^(BOOL isSuccess) {
        @strongify(self);
        [self.hud hideAnimated:YES];
        self.authorName = self.model.author.name;
        self.bottomView.content = @"";
        if (isSuccess) {
            [kKeyWindow makeToast:@"评论成功"];
            
            //删除草稿
            if (self.currentComment) {
                [[CTDrafts share] removeCommentWithAnswerId:self.answerId commentId:self.currentComment.commentId];
                self.currentComment = nil;
            } else {
                [[CTDrafts share] removeCommentWithAnswerId:self.answerId commentId:self.model.commentId];
            }
        
            //通知发布成功
            self.commentCount ++ ;
            NSDictionary *dict = @{@"commentCount":@(self.commentCount)};
            [[NSNotificationCenter defaultCenter] postNotificationName:kPublishCommentsNotification object:dict];
            
            self.model.childComments = [self.commentViewModel subCommentsData];
            self.subCommentsView.commentModel = self.model;
            [self updateUI];
            [self hw_panModalSetNeedsLayoutUpdate];
        } else {
            [self.view makeToast:self.commentViewModel.errorString];
        }
    }];
}

#pragma mark 删除评论
- (void)deleteCommentWithId:(NSInteger)commentId{
    self.hud = [MBProgressHUD ctfShowLoading:self.view title:nil];
    @weakify(self);
    [self.commentViewModel deleteCommentWithCommentId:commentId complete:^(BOOL isSuccess) {
        @strongify(self);
        [self.hud hideAnimated:YES];
        if (isSuccess) {
            [kKeyWindow makeToast:@"删除成功"];
            if (self.model.commentId == commentId) {
                self.model.isDeleted = YES;
                [self.mainCommentView fillCommentData:self.model];
            }else{
                self.model.childComments = [self.commentViewModel subCommentsData];
                self.subCommentsView.commentModel = self.model;
                [self updateUI];
            }
        } else {
            [kKeyWindow makeToast:self.commentViewModel.errorString];
        }
    }];
}

#pragma mark 举报评论
- (void)reportCommentWithId:(NSInteger)commentId {
    CTFReportTypeOptionVC *reportTypeOptionVC = [[CTFReportTypeOptionVC alloc] initWithFeedBackType:FeedBackType_Comment resourceTypeId:commentId];
    reportTypeOptionVC.dismissBlock = ^{
        
    };
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:reportTypeOptionVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark 显示评论输入框
- (void)showCommentInputWithContent:(NSString *)content{
    [CTFCommentToolView showCommentInputViewWithFrame:CGRectMake(0,kScreen_Height, kScreen_Width, 157) type:CTFInputToolViewTypeComment  isAuthor:NO name:self.authorName content:content submit:^(NSString *content) {
        [self submitCommentWithContent:content];
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
                [[CTDrafts share] storeCommentWithAnswerId:self.answerId commentId:self.model.commentId content:content];
            } else {
                [[CTDrafts share] removeCommentWithAnswerId:self.answerId commentId:self.model.commentId];
            }
        }
    }];
}

#pragma mark -- Getters
#pragma mark 导航栏
-(UIView *)navBarView{
    if (!_navBarView) {
        _navBarView = [[UIView alloc] initWithFrame:CGRectMake(0,0, kScreen_Width,50)];
        _navBarView.backgroundColor = [UIColor whiteColor];
        
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10,10, 30, 30)];
        [backBtn setImage:ImageNamed(@"comment_icon_back") forState:UIControlStateNormal];
        [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0,-10.0, 0, 0)];
        [backBtn addTarget:self action:@selector(leftNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
        [_navBarView addSubview:backBtn];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(50,10, kScreen_Width-100, 30)];
        titleLab.font = [UIFont mediumFontWithSize:16];
        titleLab.textColor = [UIColor ctColor33];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.text = @"评论详情";
        [_navBarView addSubview:titleLab];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 49, kScreen_Width, 1)];
        lineView.backgroundColor = UIColorFromHEXWithAlpha(0x999999, 0.19);
        [_navBarView addSubview:lineView];
    }
    return _navBarView;
}

#pragma mark 根滚动视图
- (UIScrollView *)rootScrollView{
    if (!_rootScrollView) {
        _rootScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,self.navBarView.bottom, kScreen_Width, kScreen_Height- kStatusBar_Height- self.navBarView.bottom - 50)];
        _rootScrollView.backgroundColor = [UIColor whiteColor];
        _rootScrollView.showsVerticalScrollIndicator = NO;
    }
    return _rootScrollView;
}

#pragma mark 主评论
- (CTFCommentView *)mainCommentView{
    if (!_mainCommentView) {
        _mainCommentView = [[CTFCommentView alloc] init];
    }
    return _mainCommentView;
}

#pragma mark 头部视图
- (UIView *)headView{
    if (!_headView) {
        _headView = [[UIView alloc] init];
        _headView.backgroundColor = [UIColor whiteColor];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 6)];
        line.backgroundColor = [UIColor ctColorF8];
        [_headView addSubview:line];
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(kMarginLeft, line.bottom+10, kScreen_Width-2*kMarginLeft, 24)];
        titleLab.font = [UIFont mediumFontWithSize:16];
        titleLab.textColor = [UIColor ctColor33];
        titleLab.text = [NSString stringWithFormat:@"%ld条回复",self.model.childCommentsCount];
        [_headView addSubview:titleLab];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, 49, kScreen_Width, 1)];
        line2.backgroundColor = [UIColor ctColorEE];
        [_headView addSubview:line2];
    }
    return _headView;
}

#pragma mark 子评论
- (CTFCommentsTableView *)subCommentsView {
    if (!_subCommentsView) {
        _subCommentsView = [[CTFCommentsTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _subCommentsView.isSubComment = NO;
        _subCommentsView.lineLeft = 0;
    }
    return _subCommentsView;
}

#pragma mark 发布评论
- (CTFCommentBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[CTFCommentBottomView alloc] initWithFrame:CGRectMake(0, kScreen_Height-kStatusBar_Height-kTabBar_Height, kScreen_Width, kTabBar_Height)];
        NSString *defaultContent = [[CTDrafts share] getCommentWithAnswerId:self.answerId commentId:self.model.commentId];
        _bottomView.content = defaultContent;
        kSelfWeak;
        _bottomView.handleBlock = ^(NSInteger index) {
            if (index == 0) {
                weakSelf.authorName = weakSelf.model.author.name;
                [weakSelf showCommentInputWithContent:weakSelf.bottomView.content];
            } else {
                [weakSelf submitCommentWithContent:weakSelf.bottomView.content];
            }
        };
    }
    return _bottomView;
}

- (CTFCommentViewModel *)commentViewModel {
    if (!_commentViewModel) {
        _commentViewModel = [[CTFCommentViewModel alloc] init];
        _commentViewModel.isDetails = YES;
    }
    return _commentViewModel;
}

- (PagingModel *)pagingModel {
    if (!_pagingModel) {
        _pagingModel = [[PagingModel alloc] init];
        _pagingModel.page = 1;
        _pagingModel.pageSize = 8;
    }
    return _pagingModel;
}



@end
