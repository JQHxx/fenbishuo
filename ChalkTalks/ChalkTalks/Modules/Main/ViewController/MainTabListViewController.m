//
//  MainTabListViewController.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/20.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "MainTabListViewController.h"
#import "CTFCellularPlayerVideo.h"
#import "CTFNetReachabilityManager.h"
#import "ZFPlayer.h"
#import "ZFAVPlayerManager.h"
#import "ZFPlayerControlView.h"
#import "NSURL+Ext.h"
#import <KTVHTTPCache/KTVHTTPCache.h>
#import "CTFMainTableViewCell.h"
#import "CTFVideoMuteManager.h"
#import "CTFAudioPlayerManager.h"
#import "CTFSkeletonCellFive.h"
#import "NSString+Size.h"
#import "CTFCommonManager.h"
#import "CTFBaseBlankView.h"
#import "NSUserDefaultsInfos.h"
#import "BaseTabBarViewController.h"
#import "CTFLearningGuideView.h"

@interface MainTabListViewController ()<UITableViewDataSource,UITableViewDelegate,CTFMainTableViewCellDelegate,CTFSkeletonDelegate>

@property (nonatomic,strong) UITableView         *mainTableView;
@property (nonatomic,strong) ZFPlayerController  *player;
@property (nonatomic,strong) ZFPlayerControlView *controlView;
@property (nonatomic,strong) NSIndexPath         *currentAudioIndexPath;
@property (nonatomic,strong) CTFBaseBlankView    *blankView;  //空白页
@property (nonatomic,strong) UILabel             *refreshTipsLab;
@property (nonatomic,assign) BOOL                isHeadRefresh; //下拉

@property (nonatomic, strong) CTFLearningGuideView *learningGuideView;// 投票页面的学习引导

#pragma mark - skeleton : property
@property (nonatomic, assign) BOOL skeleton_isLoaded;

@end


@implementation MainTabListViewController

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
    self.skeleton_isLoaded = NO;
    [self.mainTableView registerClass:[CTFSkeletonCellFive class] forCellReuseIdentifier:@"CTFSkeletonCellFive"];
    [self.mainTableView ctf_showSkeleton];
}

- (void)skeleton_hide {
    self.skeleton_isLoaded = YES;
    [self.mainTableView ctf_hideSkeleton];
}

#pragma mark - 构建方法
-(instancetype)initWithCategoryId:(NSInteger)cid{
    self = [super init];
    if(self){
        self.categoryId = cid;
    }
    return self;
}

#pragma mark - 控制器的生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.isHiddenNavBar = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupUI];
    [self skeleton_show];
    [self setupAVVideoPlayer];
    
    if (self.index == 0) {
        [self loadFirstLaunchFeedsData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registNotification];
    [self showLearningWhenViewWillAppear];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self hideLearningWhenViewWillDisappear];
}

- (BOOL)shouldAutorotate {
    return self.player.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.player.isFullScreen && self.player.orientationObserver.fullScreenMode == ZFFullScreenModeLandscape) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.player.isFullScreen) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    /// 如果只是支持iOS9+ 那直接return NO即可，这里为了适配iOS8
    return self.player.isStatusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

#pragma mark - Notificaion
#pragma mark 视频开启静音
-(void)videoMuteChangedInFeedNotification:(id)sender{
    if (self.player.currentPlayerManager.isMuted&&self.index==0) {
        [MobClick event:@"home_feeds_itemsilence"];
    }
}

#pragma mark 登录成功
-(void)loginedNotification:(id)sender{
    [NSUserDefaultsInfos putKey:kFeedLoginIn andValue:[NSNumber numberWithBool:YES]];
}

#pragma mark 切换环境
- (void)switchEnvNotification:(NSNotification *)notication {
    [NSUserDefaultsInfos putKey:kAPPlicationFinishLaunching andValue:[NSNumber numberWithBool:YES]];
    kAPPDELEGATE.window.rootViewController = [[BaseTabBarViewController alloc] init];
}

#pragma mark UITableViewDataSource and UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   return [self.delegate numberOfList:self];;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CTFFeedCellLayout *layout = [self.delegate modelForView:self index:indexPath.row];
    CTFMainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CTFMainTableViewCell identifier]];
    [cell setDelegate:self withIndexPath:indexPath];
    [cell fillContentWithData:layout];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.skeleton_isLoaded) {
        CTFFeedCellLayout *layout = [self.delegate modelForView:self index:indexPath.row];
        return layout.height;
    } else {
        return [CTFSkeletonCellFive defaultHeight];
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
    [self forbidScrollWhenLearningGuideViewDisplay:scrollView];
    [scrollView zf_scrollViewDidScroll];
    
    [self scrollingForHandleAudioImage];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewWillBeginDragging];
}

#pragma mark - JXCategoryListContentViewDelegate
- (UIView *)listView {
    return self.view;
}

#pragma mark 列表显示的时候调用
- (void)listDidAppear{
    BOOL applauching = [[NSUserDefaultsInfos getValueforKey:kAPPlicationFinishLaunching] boolValue];
    if (!applauching) {
        [self fetchData];
    }
    self.player.currentPlayerManager.muted = [[CTFVideoMuteManager sharedInstance] getAudoMuteInFeed];
}

#pragma mark 列表将要消失的时候调用
-(void)listWillDisappear{
    if ([CTFCommonManager sharedCTFCommonManager].needVideoStop) {
        [self stopVideoIfNeed];
        [CTFCommonManager sharedCTFCommonManager].needVideoStop = NO;
    } else {
        [self pauseVideoIfNeed];
    }
    [self stopCurrentAudio];
}

#pragma mark - CTFMainTableViewCellDelegate
- (void)mainTableViewCell:(CTFMainTableViewCell *)cell avcellPlayVideoAtIndexPath:(NSIndexPath *)indexPath{
    if ([[CTFNetReachabilityManager sharedInstance] currentNetStatus] == AFNetworkReachabilityStatusNotReachable){
         CTFMainTableViewCell *cell = [self.mainTableView cellForRowAtIndexPath:indexPath];
        [cell showLoadingFailView];
        [self.view makeToast:@"暂无网络，无法播放"];
   } else {
        [self playAtIndexPath:indexPath scrollToTop:NO];
   }
}

#pragma mark - routerEventWithName
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo{
    AnswerModel *model = [userInfo safe_objectForKey:kViewpointDataModelKey];
    NSIndexPath *indexPath = [userInfo safe_objectForKey:kCellIndexPathKey];
    if (self.player.playingIndexPath && self.player.playingIndexPath == indexPath) {
        [CTFCommonManager sharedCTFCommonManager].needVideoStop = NO;
    } else {
        [CTFCommonManager sharedCTFCommonManager].needVideoStop = YES;
    }
    if ([eventName isEqualToString:kReloadAnswerCommentEvent]) {
        [self pauseVideoIfNeed];
        [self.mainTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        if (self.player.playingIndexPath == indexPath) {
            [self playAtIndexPath:indexPath scrollToTop:NO];
        }
    } else if ([eventName isEqualToString:kAnswerDeleteEvent] || [eventName isEqualToString:kAnswerNotInterestedEvent]) { //删除回答或不感兴趣
        [self handerDetailMyAnswer:model.answerId ip:indexPath];
    } else if ([eventName isEqualToString:kTopicTitleEvent]) {
        if (self.index == 0) {
            [MobClick event:@"home_feeds_itemclick"];
        } else {
            [MobClick event:@"home_ask_itemclick"];
        }
        NSString *sid = [NSString stringWithFormat:@"%@?answerId=%zd&questionId=%zd", kCTFTopicDetailsVC,model.answerId,model.question.questionId];
        APPROUTE(sid);
    } else if ([eventName isEqualToString:kViewpointIntroEvent]) {
        if (self.player.playingIndexPath && self.player.playingIndexPath == indexPath) {
            [CTFCommonManager sharedCTFCommonManager].needVideoStop = NO;
        } else {
            [CTFCommonManager sharedCTFCommonManager].needVideoStop = YES;
        }
        if (self.index==0) {
            [MobClick event:@"home_feeds_itemclick"];
        } else {
            [MobClick event:@"home_ask_itemclick"];
        }
        NSString *sid = [NSString stringWithFormat:@"%@?answerId=%zd&questionId=%zd", kCTFTopicDetailsVC,model.answerId,model.question.questionId];
        APPROUTE(sid);
    } else if ([eventName isEqualToString:kEnterBrowseImageEvent]||[eventName isEqualToString:kAudioFeedPlayEvent]) {
        if (self.currentAudioIndexPath&&self.currentAudioIndexPath!=indexPath) {
           [self stopCurrentAudio];
        }
        self.currentAudioIndexPath = indexPath;
        [self stopVideoIfNeed];
    } else if ([eventName isEqualToString:kExitBrowseImageEvent]) {
        NSIndexPath *indexPath = [userInfo safe_objectForKey:kCellIndexPathKey];
        self.currentAudioIndexPath = indexPath;
    } else if ([eventName isEqualToString:kAudioImageScrollEvent]) { //记录语图图片滚动位置
        NSIndexPath *indexPath = [userInfo safe_objectForKey:kCellIndexPathKey];
        CTFFeedCellLayout *layout = [self.delegate modelForView:self index:indexPath.row];
        if ([layout.model.type isEqualToString:@"audioImage"]) {
            layout.model.currentIndex = [userInfo safe_integerForKey:@"currentIndex"];
        }
        [self stopVideoIfNeed];
    } else if ([eventName isEqualToString:kAnswerReportEvent]) {
        [self pauseVideoIfNeed];
        [self stopCurrentAudio];
    } else if ([eventName isEqualToString:kAnswerReportDismissEvent]) {
        [self playVideoIfNeed];
    }
}

#pragma mark - private method
#pragma mark 注册通知
-(void)registNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchEnvNotification:) name:CTENVConfig.kChangedEnvNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoMuteChangedInFeedNotification:) name:kVideoMuteChangedInFeedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginedNotification:) name:kLoginedNotification object:nil];
}
 
#pragma mark 移除通知
-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CTENVConfig.kChangedEnvNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kVideoMuteChangedInFeedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginedNotification object:nil];
}

#pragma mark 播放视频
- (void)playAtIndexPath:(NSIndexPath *)indexPath scrollToTop:(BOOL)scrollToTop {
    [self stopCurrentAudio];
    NSInteger index = indexPath.row;
    if([[CTFNetReachabilityManager sharedInstance] currentNetStatus] != AFNetworkReachabilityStatusNotReachable){
        if (self.index==0) {//推荐列表项视频播放
            [MobClick event:@"home_feeds_itemplay"];
        }
        CTFFeedCellLayout *layout = [self.delegate modelForView:self index:index];
        if([layout.model.type isEqualToString:@"video"] && !kIsEmptyString(layout.model.video.url)){
            NSURL *URL = [NSURL safe_URLWithString:layout.model.video.url];
            BOOL shupin = YES;
            if(layout.model.video.rotation == 0||layout.model.video.rotation==180){
                if(layout.model.video.width > layout.model.video.height) shupin = NO;
            }
            BOOL isLarge = [AppMargin isLargeScaleIsWidth:layout.model.video.width height:layout.model.video.height rotation:layout.model.video.rotation];
            [self.controlView showTitle:nil coverURLString:layout.model.video.coverUrl fullScreenMode: shupin ? ZFFullScreenModePortrait : ZFFullScreenModeLandscape isLarge:isLarge];
            [self.player playTheIndexPath:indexPath assetURL:URL seek:layout.model.video.aleayPlayDuration scrollToTop:scrollToTop];
       }
    }
}

#pragma mark 删除问题
-(void)handerDetailMyAnswer:(NSInteger)answerId ip:(NSIndexPath*)ip{
    [self stopVideoIfNeed];
    [self stopCurrentAudio];
    [self.delegate deleteModel:self index:ip.row];
    [self.mainTableView reloadData];
}

#pragma mark - Loading Data
#pragma mark 加载完成
-(void)loadDataComplete:(BOOL)isSuccess{
    [self skeleton_hide];
    [self.mainTableView.mj_header endRefreshing];
    [self.mainTableView.mj_footer endRefreshing];
    [self.mainTableView reloadData];
    if (isSuccess) {
        [self showRefreshFeedsDataTips];
        [self hideNetErrorView];
        self.blankView.hidden = ![self.delegate isEmpty:self];
        if (![self.delegate isEmpty:self]) {
            [self addSubviewMainPageLearningView];
        }
        
        //播放进度重置
        NSInteger count = [self.delegate numberOfList:self];
        for (NSInteger i = 0; i < count; i++) {
            CTFFeedCellLayout *layout = [self.delegate modelForView:self index:i];
            layout.model.video.aleayPlayDuration = 0;
        }
        @weakify(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.learningGuideView != nil) {
                return;
            }
            [self.mainTableView zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath *indexPath) {
                @strongify(self)
                [self playAtIndexPath:indexPath scrollToTop:NO];
            }];
        });
        
        [self createLoadMoreView];
    } else {
        if ([self.action isEqualToString:@"up"] && self.page.page > 1) {
            self.page.page--;
        }
        [self.view makeToast:[self.delegate errorString:self]];
        if ([self.delegate numberOfList:self]==0) {
            [self showNetErrorViewWithType:[self.delegate getRequsetErrorType:self] whetherLittleIconModel:NO frame:self.mainTableView.frame]; //显示网络错误
            self.blankView.hidden = YES;
        }
    }
}

#pragma mark 刷新数据
- (void)baseRefreshData {
    if (self.mainTableView.mj_header.isRefreshing) return;
    [self.mainTableView.mj_header beginRefreshing];
}

#pragma mark 第一次进入拉取数据
- (void)loadFirstLaunchFeedsData {
    self.isHeadRefresh = YES;
    if (self.page == nil) {
        self.page = [[PagingModel alloc] init];
    }
    self.page.page = 1;
    self.page.pageSize = 8;
    
    if ([self.delegate respondsToSelector:@selector(loadFirstLaunchingFeedsData:)]) {
        [self.delegate loadFirstLaunchingFeedsData:self];
    }
}

#pragma mark 加载最新数据
-(void)refreshData{
    [self stopCurrentAudio];
    [self stopVideoIfNeed];
    BOOL isLogin = [[NSUserDefaultsInfos getValueforKey:kFeedLoginIn] boolValue];
    if (isLogin && self.index == 0) {
        self.isHeadRefresh = YES;
        [self loadFirstLaunchFeedsData];
    } else {
        if (self.index == 0) {
            self.isHeadRefresh = YES;
            self.action = @"down";
        } else {
            self.action = @"up";
            if(self.page == nil){
                self.page = [[PagingModel alloc] init];
            }
            self.page.page = 1;
            self.page.pageSize = 8;
        }
        [self.delegate refreshData:self];
    }
}

#pragma mark 加载更多
-(void)loadmoreData{
    [self stopCurrentAudio];
    [self stopVideoIfNeed];
    self.action = @"up";
    self.page.page ++;
    self.page.pageSize = 8;
    [self.delegate refreshData:self];
}

#pragma mark 每次进入刷新数据
-(void)fetchData{
   if ([self.delegate numberOfList:self] <= 0){
       [self refreshData];
   } else {
       [self playVideoIfNeed];
   }
}

#pragma mark 显示推荐数据提示
- (void)showRefreshFeedsDataTips {
    if (self.isHeadRefresh) {
        NSString *tips = nil;
        NSInteger count = [self.delegate refreshFeedDataCount:self];
        self.isHeadRefresh = NO;
        if (count > 0) {
            tips = @"热门已更新";
        } else {
            tips = @"暂无新推荐内容";
        }
        
        [self.view addSubview:self.refreshTipsLab];
        self.refreshTipsLab.text = tips;
        [UIView animateWithDuration:0.25 animations:^{
            self.refreshTipsLab.frame = CGRectMake(0, 0, kScreen_Width, 26);
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.25 animations:^{
                self.refreshTipsLab.frame = CGRectMake(0, 0, kScreen_Width, 0);
            } completion:^(BOOL finished) {
                [self.refreshTipsLab removeFromSuperview];
                self.refreshTipsLab = nil;
            }];
        });
    }
}

#pragma mark 续播
- (void)playVideoIfNeed {
    if (self.player.playingIndexPath && self.player.currentPlayerManager.playState == ZFPlayerPlayStatePaused) {
        [self.player.currentPlayerManager play];
    }
}

#pragma mark 停止视频播放
- (void)stopVideoIfNeed {
    if (self.player.playingIndexPath) {
        NSIndexPath *indexPath = self.player.playingIndexPath;
        CTFFeedCellLayout *layout = [self.delegate modelForView:self index:indexPath.row];
        layout.model.video.aleayPlayDuration = 0;
    }
    [self.player stopCurrentPlayingCell];
}

#pragma mark 暂停视频播放
- (void)pauseVideoIfNeed{
    if (self.player.playingIndexPath && self.player.currentPlayerManager.playState == ZFPlayerPlayStatePlaying) {
        [self.player.currentPlayerManager pause];
    }
}

#pragma mark 滚动过程中音频处理回调
- (void)scrollingForHandleAudioImage {
    if (self.currentAudioIndexPath) {
        //标记的cell  在tableView中的坐标值
        CGRect  recttIntableview = [self.mainTableView rectForRowAtIndexPath:self.currentAudioIndexPath];
        //当前cell在屏幕中的坐标值
        CGRect rectInSuperView = [self.mainTableView convertRect:recttIntableview toView:[self.mainTableView superview]];
        
        CTFFeedCellLayout *layout = [self.delegate modelForView:self index:self.currentAudioIndexPath.row];
        //图片上面高度
        CGFloat titleHeight = [layout.model.question.title boundingRectWithSize:CGSizeMake(kScreen_Width-2*kMarginLeft, CGFLOAT_MAX) withTextFont:[UIFont mediumFontWithSize:18]].height;
        CGFloat headHeight = titleHeight + 64;
        
        //图片下面高度
        CGFloat contentH = kIsEmptyString(layout.model.content)?-20:[layout.model.content ctTextSizeWithFont:[UIFont regularFontWithSize:14] numberOfLines:2 constrainedWidth:kScreen_Width-2*kMarginLeft].height;
        CGFloat bottomHeight = contentH + 70;
        
        BOOL upScroll = kStatusBar_Height>20?rectInSuperView.origin.y + contentH + 30 > rectInSuperView.size.height:rectInSuperView.origin.y + headHeight + bottomHeight > rectInSuperView.size.height;
        if (rectInSuperView.origin.y + rectInSuperView.size.height - bottomHeight -15 < 0||upScroll) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kAudioStopPlayNotification object:nil];
            [self stopCurrentAudio];
        }
    }
}

#pragma mark 停止当前音频播放
- (void)stopCurrentAudio{
    if (self.currentAudioIndexPath) {
        CTFMainTableViewCell *cell = [self.mainTableView cellForRowAtIndexPath:self.currentAudioIndexPath];
        [cell stopAuido];
        self.currentAudioIndexPath = nil;
    }
}

#pragma mark - UI
-(void)createLoadMoreView{
    if ([self.delegate hasMoreData:self]) {
        @weakify(self);
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{
            @strongify(self);
            [self loadmoreData];
        }];
        self.mainTableView.mj_footer = foot;
    } else if (![self.delegate isEmpty:self]) {
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{}];
        self.mainTableView.mj_footer = foot;
        [foot setState:MJRefreshStateNoMoreData];
    } else {
        self.mainTableView.mj_footer = nil;
    }
}

#pragma mark 界面初始化
- (void)setupUI{
    [self.view addSubview:self.mainTableView];
    [self.mainTableView addSubview:self.blankView];
    self.blankView.hidden = YES;
}

#pragma mark -- Getters
#pragma mark 主页
- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height-kNavBar_Height-44-kTabBar_Height) style:UITableViewStylePlain];
        _mainTableView.dataSource = self;
        _mainTableView.delegate = self;
        _mainTableView.rowHeight = 0;
        _mainTableView.estimatedSectionFooterHeight = 0;
        _mainTableView.estimatedSectionHeaderHeight = 0;
        _mainTableView.estimatedRowHeight = 0;
        _mainTableView.backgroundColor = [UIColor clearColor];
        [_mainTableView registerClass:[CTFMainTableViewCell class] forCellReuseIdentifier:[CTFMainTableViewCell identifier]];
        [_mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_mainTableView setShowsVerticalScrollIndicator:NO];
        [self.view addSubview:_mainTableView];
        @weakify(self)
        _mainTableView.zf_scrollViewDidStopScrollCallback = ^(NSIndexPath * _Nonnull indexPath) {
            @strongify(self);
            if ([self.delegate isShowInSegment:self] && !self.player.playingIndexPath) {
                [self playAtIndexPath:indexPath scrollToTop:NO];
            }
        };
        
        _mainTableView.mj_header = [[CTRefreshHeader alloc] initWithRefreshingBlock:^{
            @strongify(self)
            [self refreshData];
        }];
    }
    return _mainTableView;
}

#pragma mark 空白页
- (CTFBaseBlankView *)blankView{
    if (!_blankView) {
        _blankView = [[CTFBaseBlankView alloc] initWithFrame:self.mainTableView.bounds blankType:CTFBlankType_VoteList imageOffY:120];
    }
    return _blankView;
}

-(void)setupAVVideoPlayer{
    /// playerManager
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
    
    /// player,tag值必须在cell里设置
    self.player = [ZFPlayerController playerWithScrollView:self.mainTableView playerManager:playerManager containerViewTag:1000];
    self.player.controlView = self.controlView;
    /// 1.0是消失100%时候
    self.player.playerDisapperaPercent = 0.5f;
    /// 播放器view露出一半时候开始播放
    self.player.playerApperaPercent = 1;
    self.player.currentPlayerManager.muted = [[CTFVideoMuteManager sharedInstance] getAudoMuteInFeed];
    self.player.WWANAutoPlay = NO;
    self.player.shouldAutoPlay = YES;
    self.player.exitFullScreenWhenStop = NO;
    self.player.allowOrentitaionRotation = NO;
    self.player.customAudioSession = YES;
    self.player.umengEventPath = @"homefeed";
    
    @weakify(self)
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        @strongify(self)
        NSIndexPath *index = self.player.playingIndexPath;
        CTFFeedCellLayout *layout = [self.delegate modelForView:self index:index.row];
        layout.model.video.aleayPlayDuration = 0;
    };
    
    self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        @strongify(self)
        if(isFullScreen){
            if (self.index==0) { //推荐列表项视频全屏
                [MobClick event:@"home_feeds_itemfullscreen"];
            }
            [self stopCurrentAudio];
            [self.delegate videoEnterFullScreen];
        }else{
            [self.delegate videoExitFullScreen];
        }
    };

    self.player.playerPlayTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration){
        @strongify(self)
        NSIndexPath *index = self.player.playingIndexPath;
        CTFFeedCellLayout *layout = [self.delegate modelForView:self index:index.row];
        layout.model.video.aleayPlayDuration = currentTime;
    };
    //播放状态改变
    self.player.playerPlayStateChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerPlaybackState playState) {
        @strongify(self)
        if (playState == ZFPlayerPlayStatePlaying) {
            [self stopCurrentAudio];
        }
        if (self.index==0) {
            if (playState== ZFPlayerPlayStatePaused) { //推荐列表项视频暂停
                [MobClick event:@"home_feeds_itempause"];
            }
        }
    };
}

- (UILabel *)refreshTipsLab {
    if (!_refreshTipsLab) {
        _refreshTipsLab = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width/2.0,13, 0, 0)];
        _refreshTipsLab.textAlignment = NSTextAlignmentCenter;
        _refreshTipsLab.font = [UIFont regularFontWithSize:12];
        _refreshTipsLab.backgroundColor = UIColorFromHEX(0xFFCCD6);
        _refreshTipsLab.textColor = [UIColor ctMainColor];
    }
    return _refreshTipsLab;
}

- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [ZFPlayerControlView new];
    }
    return _controlView;
}

-(void)dealloc{
    [self removeNotification];
    [self stopVideoIfNeed];
}

#pragma mark - 首页的学习引导

// 显示首页的学习引导
- (void)addSubviewMainPageLearningView {
    if (self.index == 0 && ![CTFSystemCache query_showedLearningGuideForFunctionView:CTFLearningGuideViewType_Main] && self.learningGuideView == nil) {
        
        [self pauseVideoIfNeed];
        
        [self handleApplicationDidEnterBackground];
        
        NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        CGRect rectInTableView = [self.mainTableView rectForRowAtIndexPath:cellIndexPath];
//        CGRect rect = [self.mainTableView convertRect:rectInTableView toView:kAPPDELEGATE.window];

//        CGRect cellRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height-10);
        CGRect cellRect2 = CGRectZero;
        
//        CGRect ignoreRect = CGRectMake(cellRect.origin.x+cellRect.size.width-176, cellRect.origin.y+cellRect.size.height-42, 142, 27);
        
        CGRect frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
        
//        CGRect imageFrame = CGRectMake(cellRect.origin.x+cellRect.size.width-215-12, cellRect.origin.y+cellRect.size.height-10, 215, 86);
        CGRect imageFrame2 = CGRectMake(0, kStatusBar_Height+95, kScreen_Width, 420);
        
        @weakify(self);
        CTFLearningGuideView *learningGuideView = [[CTFLearningGuideView alloc] initWithFrame:frame alpha:0.7 hollowFrame:cellRect2 hollowCornerRadius:0.f imageName:@"icon_main2_learningGuide_375x420" imageFrame:imageFrame2 ignoreRect:CGRectZero clickSelfBlcok:^{
            @strongify(self);
            [self removeMainPageLearningView];
        }];
        self.learningGuideView = learningGuideView;
        [kAPPDELEGATE.window addSubview:learningGuideView];
    }
}

// 隐藏首页的学习引导
- (void)removeMainPageLearningView {
    [self.learningGuideView removeFromSuperview];
    self.learningGuideView = nil;
    [CTFSystemCache revise_showedLearningGuide:YES ForFunctionView:CTFLearningGuideViewType_Main];
    
    [self fetchData];
}

//
- (void)forbidScrollWhenLearningGuideViewDisplay:(UIScrollView *)scrollView {
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeMainPageLearningView) name:kApplicationWillTerminateNotification object:nil];
}



@end
