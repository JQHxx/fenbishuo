//
//  CTFHomePageVC.m
//  ChalkTalks
//
//  Created by vision on 2019/12/26.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFHomePageVC.h"
#import "CTFUserHeaderView.h"
#import "CTFHomePageViewModel.h"
#import "CTFMyQuestionTableViewCell.h"
#import "CTFMyAnswerCell.h"
#import "CTFUserLikeView.h"
#import "CTFBaseBlankView.h"
#import "HFStretchableTableHeaderView.h"
#import "CTFSkeletonCellFive.h"
#import "MainPageViewModel.h"
#import "CTFTopicDetailsViewModel.h"
#import "CTFMineViewModel.h"
#import "ZFPlayer.h"
#import "ZFPlayerControlView.h"
#import "ZFAVPlayerManager.h"
#import "CTFVideoMuteManager.h"
#import "CTFCommonManager.h"
#import "CTFAudioPlayerManager.h"
#import "NSString+Size.h"


@interface CTFHomePageVC () <UITableViewDelegate, UITableViewDataSource, CTFUserHeaderViewDelegate, UIScrollViewDelegate, CTFMyAnswerCellDelegate, CTFSkeletonDelegate> {
    BOOL       hasShowNavbar;
    CGFloat    offsetY;
    BOOL       netError;
}

@property (nonatomic,strong) UIButton             *backBtn;
//头像 昵称
@property (nonatomic,strong) UIView               *tempNarbarView;
@property (nonatomic,strong) UIImageView          *tempHeadImgView;
@property (nonatomic,strong) UILabel              *nameLab;
@property (nonatomic,strong) UITableView          *homePageTableView;

@property (nonatomic,strong) HFStretchableTableHeaderView *stretchHeaderView;
@property (nonatomic,strong) UIImageView          *bgHeadImgView;
@property (nonatomic,strong) CTFUserHeaderView    *headerView;
@property (nonatomic,strong) CTFBaseBlankView     *blankView;

@property (nonatomic,strong) CTFHomePageViewModel *myViewModel;
@property (nonatomic, strong) CTFMineViewModel    *mineVM;
@property (nonatomic,strong) MainPageViewModel    *mainViewModel;
@property (nonatomic,strong) CTFTopicDetailsViewModel *adpater;

@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) ZFPlayerControlView *controlView;
@property (nonatomic, assign) BOOL isFullScreen;

@property (nonatomic,assign) NSInteger            userId;
@property (nonatomic,assign) BOOL                 isMine;
@property (nonatomic,strong) PagingModel          *pageModel;
@property (nonatomic,strong) NSIndexPath          *currentAudioIndexPath;
@property (nonatomic,strong) MBProgressHUD        *hud;
@property (nonatomic,assign) BOOL                 commentIn;

#pragma mark - skeleton : property
@property (nonatomic, assign) BOOL skeleton_isLoaded;

@end

@implementation CTFHomePageVC

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

- (void)skeleton_show_tableView {
    self.skeleton_isLoaded = NO;
    [self.homePageTableView registerClass:[CTFSkeletonCellFive class] forCellReuseIdentifier:@"CTFSkeletonCellFive"];
    [self.homePageTableView ctf_showSkeleton];
}

- (void)skeleton_hide_tableView {
    self.skeleton_isLoaded = YES;
    [self.homePageTableView ctf_hideSkeleton];
}

- (void)skeleton_abelView {
    
    self.homePageTableView.hidden = NO;
    self.headerView.hidden = NO;
}

- (void)skeleton_show_headerView {
    [self.headerView ctf_showSkeleton];
}

- (void)skeleton_hide_headerView {
    [self.headerView ctf_hideSkeleton];
}

#pragma mark - 控制器生命周期
- (void)viewDidLoad {
    [super viewDidLoad];

    self.isHiddenNavBar = YES;
    self.userId = [self.schemaArgu safe_integerForKey:@"userId"];
    NSInteger myUserId = [[UserCache getCurrentUserID] integerValue];
    self.isMine = myUserId==self.userId;
    self.commentIn = [self.schemaArgu safe_integerForKey:@"commentIn"];
    self.myViewModel = [[CTFHomePageViewModel alloc] initWithUserId:self.userId isMine:self.isMine];
    self.mainViewModel = [[MainPageViewModel alloc] init];
    self.mineVM = [[CTFMineViewModel alloc] init];
    self.adpater = [[CTFTopicDetailsViewModel alloc] init];
    [self initHomePageView];
    [self setupAVVideoPlayer];
    [self loadUserDetailsData];
    [self loadActivitiesDataWithLoading:YES];
    [self skeleton_abelView];
    [self skeleton_show_headerView];
    [self skeleton_show_tableView];
    [self queryBadgedWallMessage];
    [self setupMonitor];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([CTFCommonManager sharedCTFCommonManager].homePageLoad) {
        [self loadUserDetailsData];
        [CTFCommonManager sharedCTFCommonManager].homePageLoad = NO;
    }
    [self.homePageTableView reloadData];
    [self playVideoIfNeed];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if ([CTFCommonManager sharedCTFCommonManager].needVideoStop) {
        [self stopVideoIfNeed];
        [CTFCommonManager sharedCTFCommonManager].needVideoStop = NO;
    } else {
        [self pauseVideoIfNeed];
    }
    [self stopCurrentAudio];
}

#pragma mark - 监听
- (void)setupMonitor {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(monitor_loginSuccess) name:kLoginedNotification object:nil];
}

- (void)monitor_loginSuccess {
    /* 由于用户在没有登录的状态可以进入到个人主页，在个人主页触发某些操作后触发登录，登录成功后需要刷新当前界面 */
    [self baseRefreshData];
}

#pragma mark 状态栏
-(UIStatusBarStyle)preferredStatusBarStyle{
    if (!netError) {
        if (offsetY>224) {
            return UIStatusBarStyleDefault;
        } else {
           return UIStatusBarStyleLightContent;
        }
    } else {
        return UIStatusBarStyleDefault;
    }
}

#pragma mark 状态栏是否隐藏
- (BOOL)prefersStatusBarHidden {
    return self.isFullScreen;
}

#pragma mark  UITableViewDataSource and UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.myViewModel numberOfActitivitiesData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CTFActivityModel *activityModel = [self.myViewModel getActivityModelWithIndex:indexPath.row];
    if ([activityModel.resourceType isEqualToString:@"question"]) {
        CTFMyQuestionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CTFMyQuestionTableViewCell identifier] forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.cardIndexPath = indexPath;
        cell.activityModel = activityModel;
        return cell;
    } else {
        CTFMyAnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:[CTFMyAnswerCell identifier]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setDelegate:self withIndexPath:indexPath];
        [cell fillContentWithData:activityModel.feedCellLayout];
        return cell;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.skeleton_isLoaded) {
        CTFActivityModel *activityModel = [self.myViewModel getActivityModelWithIndex:indexPath.row];
        if ([activityModel.resourceType isEqualToString:@"answer"]) {
            return activityModel.feedCellLayout.height;
        } else {
            CGFloat height = [CTFMyQuestionTableViewCell getMyQuestionCellHeightWithMode:activityModel];
            return height;
        }
        return 0;
    } else {
        return [CTFSkeletonCellFive defaultHeight];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CTFActivityModel *activityModel = [self.myViewModel getActivityModelWithIndex:indexPath.row];
    if ([activityModel.resourceType isEqualToString:@"question"]) {
        [MobClick event:@"homepage_listitemclick"];
        [CTFCommonManager sharedCTFCommonManager].needVideoStop = YES;
        NSString *sid = [NSString stringWithFormat:@"%@?questionId=%zd", kCTFTopicDetailsVC, activityModel.question.questionId];
        APPROUTE(sid);
    }
}

- (void)queryBadgedWallMessage {
    [self.mineVM svr_fetchBadgesForUserId:self.userId complete:^(BOOL isSuccess) {
        if (isSuccess) {
            [self.headerView updateBadgesWall:[self.mineVM queryBadges]];
        }
    }];
}

#pragma mark -- UIResponse
#pragma mark 事件传递
-(void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo{
    AnswerModel *model = [userInfo safe_objectForKey:kViewpointDataModelKey];
    NSIndexPath *indexPath = [userInfo safe_objectForKey:kCellIndexPathKey];
    if (self.player.playingIndexPath && self.player.playingIndexPath == indexPath) {
        [CTFCommonManager sharedCTFCommonManager].needVideoStop = NO;
    } else {
        [CTFCommonManager sharedCTFCommonManager].needVideoStop = YES;
    }
    if ([eventName isEqualToString:kTopicTitleEvent]) {
        [MobClick event:@"homepage_listitemclick"];
        [CTFCommonManager sharedCTFCommonManager].needVideoStop = YES;
        NSString *sid = [NSString stringWithFormat:@"%@?questionId=%zd", kCTFTopicDetailsVC, model.question.questionId];
        APPROUTE(sid);
    } else if ([eventName isEqualToString:kViewpointIntroEvent]) {
        [MobClick event:@"homepage_listitemclick"];
        [CTFCommonManager sharedCTFCommonManager].needVideoStop = YES;
        NSString *sid = [NSString stringWithFormat:@"%@?answerId=%zd&questionId=%zd", kCTFTopicDetailsVC,model.answerId,model.question.questionId];
        APPROUTE(sid);
    } else if ([eventName isEqualToString:kReloadAnswerCommentEvent]) {
        [self pauseVideoIfNeed];
        [self.homePageTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        if (self.player.playingIndexPath && self.player.playingIndexPath == indexPath) {
            [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
        }
    }  else if ([eventName isEqualToString:kAnswerDeleteEvent] || [eventName isEqualToString:kAnswerNotInterestedEvent]) { //删除回答或不感兴趣
        [self stopCurrentAudio];
        [self stopVideoIfNeed];
        [self.myViewModel deleteMyActivityWithAnswerId:model.answerId];
        [self.homePageTableView reloadData];
        if ([self.myViewModel isEmpty]) {
            self.blankView.hidden = NO;
            self.homePageTableView.mj_footer = nil;
        }
    } else if ([eventName isEqualToString:kEnterBrowseImageEvent]||[eventName isEqualToString:kAudioFeedPlayEvent]) {
        NSIndexPath *indexPath = [userInfo safe_objectForKey:kCellIndexPathKey];
        if (self.currentAudioIndexPath&&self.currentAudioIndexPath!=indexPath) {
           [self stopCurrentAudio];
        }
        self.currentAudioIndexPath = indexPath;
        [self stopVideoIfNeed];
    } else if ([eventName isEqualToString:kAudioImageScrollEvent]) { //记录语图图片滚动位置
        NSIndexPath *indexPath = [userInfo safe_objectForKey:kCellIndexPathKey];
        CTFActivityModel *activity = [self.myViewModel getActivityModelWithIndex:indexPath.row];
        if ([activity.feedCellLayout.model.type isEqualToString:@"audioImage"]) {
            activity.feedCellLayout.model.currentIndex = [userInfo safe_integerForKey:@"currentIndex"];
        }
    } else if ([eventName isEqualToString:kExitBrowseImageEvent]) {
        NSIndexPath *indexPath = [userInfo safe_objectForKey:kCellIndexPathKey];
        self.currentAudioIndexPath = indexPath;
    } else if ([eventName isEqualToString:kTopicLikeEvent] || [eventName isEqualToString:kTopicUnlikeEvent]) {
        CTFQuestionsModel *model = [userInfo safe_objectForKey:kTopicDataModelKey];
        [self.adpater votersToQuestion:model.questionId attitude:model.attitude complete:^(BOOL isSuccess) {
        
        }];
    } else if ([eventName isEqualToString:kAnswerReportEvent]) {
        [self pauseVideoIfNeed];
        [self stopCurrentAudio];
    } else if ([eventName isEqualToString:kAnswerReportDismissEvent]) {
        [self playVideoIfNeed];
    }
}

#pragma mark -- Delegate
#pragma mark CTFMyAnswerCellDelegate
- (void)myAnswerCell:(CTFMyAnswerCell *)cell avcellPlayVideoAtIndexPath:(NSIndexPath *)indexPath{
    if([[CTFNetReachabilityManager sharedInstance] currentNetStatus] == AFNetworkReachabilityStatusNotReachable) {
        CTFMyAnswerCell *cell = [self.homePageTableView cellForRowAtIndexPath:indexPath];
        [cell showLoadingFailView];
        [self.view makeToast:@"暂无网络，无法播放"];
    } else {
        [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
    }
}

#pragma mark CTFUserHeaderViewDelegate
#pragma mark  个人设置
-(void)userHeaderViewDidPushToUserSet:(CTFUserHeaderView *)headerView{
    if (![self ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded]) {
        return;
    }
    [CTFCommonManager sharedCTFCommonManager].needVideoStop = YES;
    [MobClick event:@"homepage_setting"];
    [ROUTER routeByCls:@"CTFPersonalSettingVC"];
}

#pragma mark  关注
-(void)userHeaderViewDidFollow:(CTFUserHeaderView *)headerView needFollow:(BOOL)needFollow{
    if (![self ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded]) {
        return;
    }
    @weakify(self);
    [self.myViewModel requestForFollowNeed:needFollow complete:^(BOOL isSuccess) {
        @strongify(self);
        if (isSuccess) {
            self.headerView.userDetails = [self.myViewModel getUserInfo];
        } else {
            [self.view makeToast:self.myViewModel.errorString];
        }
    }];
}

#pragma mark 靠谱\粉丝、关注
-(void)userHeaderView:(CTFUserHeaderView *)headerView setActionWithTag:(NSInteger)tag{
    UserModel *user = [self.myViewModel getUserInfo];
    if (tag==100) { //靠谱
        [self pauseVideoIfNeed];
        kSelfWeak;
        BOOL isMine = user.userId == UserCache.getUserInfo.userId;
        [CTFUserLikeView showUserLikeViewWithFrame:CGRectMake(0, 0, 247, 239) isMine:isMine name:user.name like:user.likeCount dismiss:^{
            [weakSelf playVideoIfNeed];
        }];
    } else if (tag==101) { //粉丝
        [CTFCommonManager sharedCTFCommonManager].needVideoStop = YES;
        [ROUTER routeByCls:@"CTFMineFansListVC" withParam:@{@"userId" : [NSNumber numberWithInteger:user.userId]}];
    } else { //关注
        [CTFCommonManager sharedCTFCommonManager].needVideoStop = YES;
        [ROUTER routeByCls:@"CTFMineFollowListVC" withParam:@{@"userId" : [NSNumber numberWithInteger:user.userId]}];
    }
}

#pragma mark - UIScrollViewDelegate   列表播放必须实现
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidEndDecelerating];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [scrollView zf_scrollViewDidEndDraggingWillDecelerate:decelerate];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScrollToTop];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScroll];
    
    [self.stretchHeaderView scrollViewDidScroll:scrollView];
    
    //导航栏显示或隐藏
    [self scrollingForNavbarShowOrNot:scrollView];
    
    //音频播放监听
    [self scrollViewDidscrollForAudioPlay];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewWillBeginDragging];
}

- (void)viewDidLayoutSubviews{
    [self.stretchHeaderView resizeView];
}

#pragma mark -- Event response
#pragma mark 返回
-(void)backToLastPageAction:(UIButton *)sender{
    if (self.commentIn) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -- Private methods
#pragma mark 界面初始化
-(void)initHomePageView{
    [self.view addSubview:self.homePageTableView];
    self.stretchHeaderView = [HFStretchableTableHeaderView new];
    [self.stretchHeaderView stretchHeaderForTableView:self.homePageTableView withView:self.bgHeadImgView subViews:self.headerView];
    
    [self.homePageTableView addSubview:self.blankView];
    self.blankView.hidden = self.homePageTableView.hidden = YES;
    
    [self.view addSubview:self.backBtn];
    [self.view addSubview:self.tempNarbarView];
    self.backBtn.hidden = self.tempNarbarView.hidden = YES;
}

#pragma mark 刷新数据
-(void)baseRefreshData{
    [self loadUserDetailsData];
    self.pageModel.page = 1;
    [self loadActivitiesDataWithLoading:YES];
    [self queryBadgedWallMessage];
}

#pragma mark 加载数据
-(void)loadUserDetailsData{
    @weakify(self);
    [self.hud showAnimated:YES];
    [self.myViewModel loadUserDetilsComplete:^(BOOL isSuccess) {
        @strongify(self);
        [self.hud hideAnimated:YES];
        [self skeleton_hide_headerView];
        if (isSuccess) {
            self.homePageTableView.hidden = self.headerView.hidden = NO;
            UserModel *userInfo = [self.myViewModel getUserInfo];
            self.headerView.userDetails = userInfo;
            [self.homePageTableView reloadData];
            [self setUserAvatarWithUserInfo:userInfo];
        } else {
            [self.view makeToast:self.myViewModel.errorString];
            self.homePageTableView.hidden = self.headerView.hidden = YES;
        }
        [self setErrorViewShow:isSuccess];
    }];
}

#pragma mark 加载动态数据
-(void)loadActivitiesDataWithLoading:(BOOL)showLoading{
    @weakify(self);
    if (showLoading) {
        [self.hud showAnimated:YES];
    }
    [self.myViewModel loadUserActivitiesDataByPage:self.pageModel complete:^(BOOL isSuccess) {
        @strongify(self);
        [self skeleton_hide_tableView];
        if (showLoading) {
            [self.hud hideAnimated:YES];
        }
        self.homePageTableView.hidden = NO;
        [self.homePageTableView.mj_footer endRefreshing];
        if (isSuccess) {
            [self.homePageTableView reloadData];
            [self createLoadMoreView];
            self.blankView.hidden = ![self.myViewModel isEmpty];
        } else {
            if (self.pageModel.page>1) {
                self.pageModel.page -- ;
            }
            [self.view makeToast:self.myViewModel.errorString];
        }
        [self setErrorViewShow:isSuccess];
    }];
}

#pragma mark 加载更多动态
-(void)loadMoreActivitiesListData{
    self.pageModel.page ++;
    [self loadActivitiesDataWithLoading:NO];
}

#pragma mark  加载更多
- (void)createLoadMoreView {
    if ([self.myViewModel hasMoreActitivtiesListData]) {
        @weakify(self);
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{
            @strongify(self);
            [self loadMoreActivitiesListData];
        }];
        self.homePageTableView.mj_footer = foot;
    } else if (![self.myViewModel isEmpty]) {
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{
            
        }];
        self.homePageTableView.mj_footer = foot;
        [foot setState:MJRefreshStateNoMoreData];
    } else {
        self.homePageTableView.mj_footer = nil;
    }
}

#pragma mark 是否显示错误
-(void)setErrorViewShow:(BOOL)success{
    if (success) {
        self->netError = NO;
        [self hideNetErrorView]; //隐藏网络错误
        self.tempNarbarView.hidden = YES;
        self.backBtn.hidden = NO;
    } else {
        self->netError = YES;
        self.tempNarbarView.hidden = NO;
        self.backBtn.hidden = YES;
        self.nameLab.text = @"个人主页";
        self.nameLab.frame = CGRectMake(60, kStatusBar_Height+12, kScreen_Width-120, 20);
        [self showNetErrorViewWithType:self.myViewModel.errorType whetherLittleIconModel:NO frame:CGRectMake(0, 300, kScreen_Width, kScreen_Height-300)]; //显示网络错误
    }
    [self setNeedsStatusBarAppearanceUpdate]; //更新状态栏
}

#pragma mark 导航栏滑动切换
- (void)scrollingForNavbarShowOrNot:(UIScrollView *)scrollView{
    offsetY = scrollView.contentOffset.y;
    if (offsetY>224) {
        if (!hasShowNavbar) {
            self.backBtn.hidden = YES;
            self.tempNarbarView.hidden = NO;
            self.tempNarbarView.alpha = 0.0;
            [UIView animateWithDuration:0.3 animations:^{
                self.tempNarbarView.alpha = 1.0;
            }];
            hasShowNavbar = YES;
        } else {
            self.tempNarbarView.hidden = NO;
        }
    } else {
        if (hasShowNavbar) {
            self.tempNarbarView.alpha = 1.0;
            [UIView animateWithDuration:0.3 animations:^{
                self.tempNarbarView.alpha = 0.0;
            }completion:^(BOOL finished) {
                self.backBtn.hidden = NO;
                self.tempNarbarView.hidden = YES;
            }];
            hasShowNavbar = NO;
        } else {
            self.tempNarbarView.hidden = YES;
        }
    }
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark 滚动时音频停止播放监听
- (void)scrollViewDidscrollForAudioPlay{
    if (self.currentAudioIndexPath) {
        //标记的cell  在tableView中的坐标值
        CGRect  recttIntableview = [self.homePageTableView rectForRowAtIndexPath:self.currentAudioIndexPath];
        //当前cell在屏幕中的坐标值
        CGRect rectInSuperView = [self.homePageTableView convertRect:recttIntableview toView:[self.homePageTableView superview]];
        // 对已经移出屏幕的 Cell 做相应的处理
        CTFActivityModel *activity = [self.myViewModel getActivityModelWithIndex:self.currentAudioIndexPath.row];
        CGFloat headHeight = 46;
        CGFloat contentH = kIsEmptyString(activity.feedCellLayout.model.content)?50:[activity.feedCellLayout.model.content ctTextSizeWithFont:[UIFont regularFontWithSize:16] numberOfLines:2 constrainedWidth:kScreen_Width-2*kMarginLeft].height;
        CGFloat bottomHeight = contentH + 78;
        
        if (rectInSuperView.origin.y + rectInSuperView.size.height - bottomHeight - 95 < 0 || rectInSuperView.origin.y - headHeight - bottomHeight - 110 > rectInSuperView.size.height) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kAudioStopPlayNotification object:nil];
            [self stopCurrentAudio];
        }
    }
}

#pragma mark 停止当前音频播放
-(void)stopCurrentAudio{
    if (self.currentAudioIndexPath) {
        CTFMyAnswerCell *cell = [self.homePageTableView cellForRowAtIndexPath:self.currentAudioIndexPath];
        [cell stopAuido];
        self.currentAudioIndexPath = nil;
    }
}

#pragma mark 停止播放
- (void)stopVideoIfNeed {
    if (self.player.playingIndexPath) {
        NSIndexPath *indexPath = self.player.playingIndexPath;
        CTFActivityModel *activity = [self.myViewModel getActivityModelWithIndex:indexPath.row];
        activity.answer.video.aleayPlayDuration = 0;
    }
    [self.player stopCurrentPlayingCell];
}

#pragma mark 暂停视频播放
- (void)pauseVideoIfNeed{
    if (self.player.playingIndexPath && self.player.currentPlayerManager.playState == ZFPlayerPlayStatePlaying) {
        [self.player.currentPlayerManager pause];
    }
}

#pragma mark 继续视频播放
- (void)playVideoIfNeed{
    if (self.player.playingIndexPath && self.player.currentPlayerManager.playState == ZFPlayerPlayStatePaused) {
        [self.player.currentPlayerManager play];
    }
}

#pragma mark 设置播放器
-(void)setupAVVideoPlayer{
    /// playerManager
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
    self.player = [ZFPlayerController playerWithScrollView:self.homePageTableView playerManager:playerManager containerViewTag:1000];
    self.player.controlView = self.controlView;
    /// 1.0是消失100%时候
    self.player.playerDisapperaPercent = 0.5f;
    /// 播放器view露出一半时候开始播放
    self.player.playerApperaPercent = 1;
    self.player.currentPlayerManager.muted = [[CTFVideoMuteManager sharedInstance] getAudoMuteInFeed];
    self.player.WWANAutoPlay = NO;
    self.player.shouldAutoPlay = NO;
    self.player.exitFullScreenWhenStop = NO;
    
    @weakify(self)
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        @strongify(self)
        NSIndexPath *index = self.player.playingIndexPath;
        CTFActivityModel *activity = [self.myViewModel getActivityModelWithIndex:index.row];
        AnswerModel *model = activity.answer;
        model.video.aleayPlayDuration = 0;
    };
    self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        @strongify(self)
        [self stopCurrentAudio];
        self.isFullScreen = isFullScreen;
        [self setNeedsStatusBarAppearanceUpdate];
    };

    self.player.playerPlayTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration){
        @strongify(self)
        NSIndexPath *index = self.player.playingIndexPath;
        CTFActivityModel *activity = [self.myViewModel getActivityModelWithIndex:index.row];
        AnswerModel *model = activity.answer;
        model.video.aleayPlayDuration = currentTime;
    };
    
    //播放状态改变
    self.player.playerPlayStateChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerPlaybackState playState) {
        @strongify(self)
        if (playState == ZFPlayerPlayStatePlaying) {
            [self stopCurrentAudio];
        }
    };
}

#pragma mark - 播放视频
- (void)playTheVideoAtIndexPath:(NSIndexPath *)indexPath scrollToTop:(BOOL)scrollToTop {
    if ([[CTFNetReachabilityManager sharedInstance] currentNetStatus] != AFNetworkReachabilityStatusNotReachable){
        [MobClick event:@"homepage_listitemplay"];
        //停止当前音频
        [self stopCurrentAudio];
        CTFActivityModel *activity = [self.myViewModel getActivityModelWithIndex:indexPath.row];
        AnswerModel *model = activity.answer;
        
        BOOL shupin = YES;
        if(model.video.rotation == 0||model.video.rotation==180) {
            if(model.video.width > model.video.height) shupin = NO;
        }
        
        if (!kIsEmptyString(model.video.url)) {
            NSURL *URL = [NSURL safe_URLWithString:model.video.url];
            BOOL isLarge = [AppMargin isLargeScaleIsWidth:model.video.width height:model.video.height rotation:model.video.rotation];
            [self.controlView showTitle:nil coverURLString:model.video.coverUrl fullScreenMode: shupin ? ZFFullScreenModePortrait : ZFFullScreenModeLandscape isLarge:isLarge];
            [self.player playTheIndexPath:indexPath assetURL:URL seek:model.video.aleayPlayDuration scrollToTop:scrollToTop];
        } else {
            if (self.isMine) {
                NSString *origUrl =  [[CTVideoCache share] getVideoWithQuestionId:model.question.questionId];
                if(!kIsEmptyString(origUrl)) {
                   NSURL *URL = [NSURL fileURLWithPath:origUrl];
                    ZLLog(@"播放本地视频：%@",URL);
                    [self.player playTheIndexPath:indexPath assetURL:URL seek:model.video.aleayPlayDuration scrollToTop:scrollToTop];
                }
            }
        }
    }
}

#pragma mark 设置头像
-(void)setUserAvatarWithUserInfo:(UserModel *)userInfo{
    if (kIsEmptyString(userInfo.avatarUrl)) {
        self.bgHeadImgView.image = [UIImage blurryImage:ImageNamed(@"placeholder_headBg_375x146") withBlurLevel:10];
    } else {
        @weakify(self);
         [self.bgHeadImgView sd_setImageWithURL:[NSURL URLWithString:userInfo.avatarUrl] placeholderImage:ImageNamed(@"placeholder_headBg_375x146") completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
             @strongify(self);
             self.bgHeadImgView.image = [UIImage blurryImage:image withBlurLevel:10];
        }];
    }
    [self.tempHeadImgView sd_setImageWithURL:[NSURL URLWithString:userInfo.avatarUrl] placeholderImage:ImageNamed(@"placeholder_head_78x78")];
    self.nameLab.text = userInfo.name;
}

#pragma mark -- Getters
#pragma mark 主页
-(UITableView *)homePageTableView{
    if (!_homePageTableView) {
        _homePageTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height) style:UITableViewStylePlain];
        _homePageTableView.delegate = self;
        _homePageTableView.dataSource = self;
        _homePageTableView.tableFooterView = [[UIView alloc] init];
        _homePageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _homePageTableView.showsVerticalScrollIndicator = NO;
        _homePageTableView.estimatedRowHeight = [CTFSkeletonCellFive defaultHeight];
        _homePageTableView.estimatedSectionHeaderHeight = 0 ;
        _homePageTableView.estimatedSectionFooterHeight = 0 ;
        if (@available(iOS 11.0, *)) {
            _homePageTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        NSArray* _tableCardsClsName = @[@"CTBaseCard",
                                        @"CTFMyQuestionTableViewCell",
                                        @"CTFMyAnswerCell",
                                    ];
        for (NSString *cls in _tableCardsClsName) {
            Class card = NSClassFromString(cls);
            [_homePageTableView registerClass:[card class] forCellReuseIdentifier:cls];
        }
        @weakify(self);
        _homePageTableView.zf_scrollViewDidStopScrollCallback = ^(NSIndexPath * _Nonnull indexPath) {
            @strongify(self)
            if (!self.player.playingIndexPath) {
                [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
            }
        };
    }
    return _homePageTableView;
}

#pragma mark 头部用户信息
-(CTFUserHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[CTFUserHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 349) isMine:self.isMine];
        _headerView.viewDelegate = self;
    }
    return _headerView;
}

#pragma mark 头像背景
-(UIImageView *)bgHeadImgView{
    if (!_bgHeadImgView) {
        _bgHeadImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 349)];
        _bgHeadImgView.contentMode = UIViewContentModeScaleAspectFill;
        _bgHeadImgView.clipsToBounds = YES;
    }
    return _bgHeadImgView;
}

#pragma mark 返回
-(UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, kStatusBar_Height, 26, 40)];
        [_backBtn setImage:ImageNamed(@"icon_white_back") forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backToLastPageAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

#pragma mark 导航栏
-(UIView *)tempNarbarView{
    if (!_tempNarbarView) {
        _tempNarbarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kNavBar_Height)];
        _tempNarbarView.backgroundColor = [UIColor whiteColor];
        
        UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, kStatusBar_Height, 26, 40)];
        [leftBtn setImage:ImageNamed(@"app_navback_btn") forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(backToLastPageAction:) forControlEvents:UIControlEventTouchUpInside];
        [_tempNarbarView addSubview:leftBtn];
        
        self.tempHeadImgView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreen_Width/2.0-38, kStatusBar_Height+8, 28, 28)];
        [self.tempHeadImgView setBorderWithCornerRadius:14 type:UIViewCornerTypeAll];
        [_tempNarbarView addSubview:self.tempHeadImgView];
        
        self.nameLab = [[UILabel alloc] initWithFrame:CGRectMake(self.tempHeadImgView.right+10, kStatusBar_Height+12, kScreen_Width/2.0-60, 20)];
        self.nameLab.font = [UIFont mediumFontWithSize:16];
        self.nameLab.textColor = [UIColor ctColor33];
        [_tempNarbarView addSubview:self.nameLab];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,kNavBar_Height-1, kScreen_Width, 1)];
        lineView.backgroundColor = [UIColor ctColorEE];
        [_tempNarbarView addSubview:lineView];
    }
    return _tempNarbarView;
}

#pragma mark 播放器显示
- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [ZFPlayerControlView new];
    }
    return _controlView;
}

#pragma mark 空白页
-(CTFBaseBlankView *)blankView{
    if (!_blankView) {
        if (self.isMine) {
            _blankView = [[CTFBaseBlankView alloc] initWithFrame:CGRectMake(0, 349, kScreen_Width, kScreen_Height-300) blankType:CTFBlankTypeHomepage imageOffY:65];
        } else {
            _blankView = [[CTFBaseBlankView alloc] initWithFrame:CGRectMake(0, 349, kScreen_Width, kScreen_Height-300) blankType:CTFBlankTypeOtherPage imageOffY:65];
        }
    }
    return _blankView;
}

- (MBProgressHUD *)hud {
    if (!_hud) {
        _hud = [MBProgressHUD ctfShowLoading:self.view title:nil];
    }
    return _hud;
}

-(PagingModel *)pageModel{
    if (!_pageModel) {
        _pageModel = [[PagingModel alloc] init];
        _pageModel.page = 1;
        _pageModel.pageSize = 8;
    }
    return _pageModel;
}

-(void)dealloc{
    [self stopVideoIfNeed];
    [self stopCurrentAudio];
}


@end
