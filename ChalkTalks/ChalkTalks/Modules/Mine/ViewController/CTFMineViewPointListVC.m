//
//  CTFMineViewPointListVC.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/18.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFMineViewPointListVC.h"
#import "CTFMyAnswerCell.h"
#import "CTFBaseBlankView.h"
#import "CTFNetErrorView.h"
#import "CTFSkeletonCellFive.h"
#import "ZFPlayerControlView.h"
#import "MainPageViewModel.h"
#import "CTFMyAnswerViewModel.h"
#import "ZFPlayer.h"
#import "ZFAVPlayerManager.h"
#import "CTFVideoMuteManager.h"
#import "CTFAudioPlayerManager.h"
#import "CTFCommonManager.h"
#import "NSString+Size.h"

@interface CTFMineViewPointListVC ()<UITableViewDelegate,UITableViewDataSource,CTFMyAnswerCellDelegate,CTFSkeletonDelegate>

@property (nonatomic,strong) UIButton              *draftBtn;
@property (nonatomic,strong) UITableView           *myAnswersTableView;
@property (nonatomic,strong) CTFMyAnswerViewModel  *myViewModel;
@property (nonatomic,strong) PagingModel           *pageModel;
@property (nonatomic,strong) MainPageViewModel     *mainViewModel;

@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) ZFPlayerControlView *controlView;
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, strong) CTFBaseBlankView    *blankView;
@property (nonatomic, strong) NSIndexPath          *currentAudioIndexPath;

#pragma mark - skeleton : property
@property (nonatomic, assign) BOOL skeleton_isLoaded;

@end

@implementation CTFMineViewPointListVC

#pragma mark - skeleton - function
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
    [self.myAnswersTableView registerClass:[CTFSkeletonCellFive class] forCellReuseIdentifier:@"CTFSkeletonCellFive"];
    [self.myAnswersTableView ctf_showSkeleton];
}

- (void)skeleton_hide {
    self.skeleton_isLoaded = YES;
    [self.myAnswersTableView ctf_hideSkeleton];
    self.myAnswersTableView.rowHeight = UITableViewAutomaticDimension;
    [self.myAnswersTableView reloadData];
    [self.myAnswersTableView ctf_hideSkeleton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle = @"我的回答";
    
    self.myViewModel = [[CTFMyAnswerViewModel alloc] init];
    self.mainViewModel = [[MainPageViewModel alloc] init];
    
    [self initMyAnswersView];
    [self skeleton_show];
    [self setupAVVideoPlayer];
    [self.myAnswersTableView.mj_header beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSInteger draftsCount = [[CTDrafts share] draftsCount];
    NSString *btnTitle = [NSString stringWithFormat:@"草稿箱(%ld)", draftsCount];
    [self.draftBtn setTitle:btnTitle forState:UIControlStateNormal];
    
    [self.myAnswersTableView reloadData];
    [self playVideoIfNeed];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([CTFCommonManager sharedCTFCommonManager].needVideoStop) {
        [self stopVideoIfNeed];
        [CTFCommonManager sharedCTFCommonManager].needVideoStop = NO;
    } else {
        [self pauseVideoIfNeed];
    }
    [self stopCurrentAudio];
}

#pragma mark 状态栏是否隐藏
- (BOOL)prefersStatusBarHidden {
    return self.isFullScreen;
}

#pragma mark  UITableViewDataSource and UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.myViewModel numberOfMyAnswersData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CTFMyAnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:[CTFMyAnswerCell identifier]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CTFMyAnswerCellLayout *layout = [self.myViewModel getMyAnswerModelWithIndex:indexPath.row];
    [cell setDelegate:self withIndexPath:indexPath];
    [cell fillContentWithData:layout];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.skeleton_isLoaded) {
        CTFMyAnswerCellLayout *layout = [self.myViewModel getMyAnswerModelWithIndex:indexPath.row];
        return layout.height;
    } else {
        return [CTFSkeletonCellFive defaultHeight];
    }
}

#pragma mark -- UIResponse
#pragma mark 事件传递
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    AnswerModel *model = [userInfo safe_objectForKey:kViewpointDataModelKey];
    NSIndexPath *indexPath = [userInfo safe_objectForKey:kCellIndexPathKey];
    if (self.player.playingIndexPath && self.player.playingIndexPath == indexPath) {
        [CTFCommonManager sharedCTFCommonManager].needVideoStop = NO;
    } else {
        [CTFCommonManager sharedCTFCommonManager].needVideoStop = YES;
    }
    if ([eventName isEqualToString:kTopicTitleEvent] || [eventName isEqualToString:kViewpointIntroEvent]){
        [CTFCommonManager sharedCTFCommonManager].needVideoStop = YES;
        NSString *sid = [NSString stringWithFormat:@"%@?answerId=%zd&questionId=%zd&showMyAnswer=1", kCTFTopicDetailsVC,model.answerId,model.question.questionId];
        APPROUTE(sid);
    } else if ([eventName isEqualToString:kReloadAnswerCommentEvent]) {
        [self pauseVideoIfNeed];
        NSIndexPath *indexPath = [userInfo safe_objectForKey:kCellIndexPathKey];
        [self.myAnswersTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        if (self.player.playingIndexPath && self.player.playingIndexPath == indexPath) {
            [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
        }
    }  else if ([eventName isEqualToString:kAnswerDeleteEvent]){ //删除回答
        [self stopCurrentAudio];
        [self stopVideoIfNeed];
        [self.myViewModel deleteMyAnswerWithAnswerId:model.answerId];
        [self.myAnswersTableView reloadData];
        if ([self.myViewModel isEmpty]) {
            self.blankView.hidden = NO;
            self.myAnswersTableView.mj_footer = nil;
        }
    } else if ([eventName isEqualToString:kEnterBrowseImageEvent]||[eventName isEqualToString:kAudioFeedPlayEvent]){
        NSIndexPath *indexPath = [userInfo safe_objectForKey:kCellIndexPathKey];
        if (self.currentAudioIndexPath&&self.currentAudioIndexPath!=indexPath) {
           [self stopCurrentAudio];
        }
        self.currentAudioIndexPath = indexPath;
        [self stopVideoIfNeed];
    } else if ([eventName isEqualToString:kExitBrowseImageEvent]){
        NSIndexPath *indexPath = [userInfo safe_objectForKey:kCellIndexPathKey];
        self.currentAudioIndexPath = indexPath;
    } else if ([eventName isEqualToString:kAudioImageScrollEvent]){ //记录语图图片滚动位置
        NSIndexPath *indexPath = [userInfo safe_objectForKey:kCellIndexPathKey];
        CTFMyAnswerCellLayout *layout= [self.myViewModel getMyAnswerModelWithIndex:indexPath.row];
        if ([layout.model.type isEqualToString:@"audioImage"]) {
            layout.model.currentIndex = [userInfo safe_integerForKey:@"currentIndex"];
        }
    }
}

#pragma mark CTFMyAnswerCellDelegate
- (void)myAnswerCell:(CTFMyAnswerCell *)cell avcellPlayVideoAtIndexPath:(NSIndexPath *)indexPath {
    if([[CTFNetReachabilityManager sharedInstance] currentNetStatus] == AFNetworkReachabilityStatusNotReachable){
            CTFMyAnswerCell *cell = [self.myAnswersTableView cellForRowAtIndexPath:indexPath];
        [cell showLoadingFailView];
        [self.view makeToast:@"暂无网络，无法播放"];
    }else{
        [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
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
    //音频播放监听
    [self scrollingForAudioStop];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewWillBeginDragging];
}

#pragma mark -- Event response
#pragma mark 进入草稿箱
- (void)rightNavigationItemAction {
    [CTFCommonManager sharedCTFCommonManager].needVideoStop = YES;
    APPROUTE(kCTFDraftBoxVC)
}

#pragma mark -- Private methods
#pragma mark  加载数据
- (void)loadMyAnswersData {
    [self stopCurrentAudio];
    [self stopVideoIfNeed];
    @weakify(self);
    [self skeleton_hide];
    [self.myViewModel loadMyAnswersDataByPage:self.pageModel complete:^(BOOL isSuccess) {
        @strongify(self);
        self.myAnswersTableView.hidden = NO;
        [self.myAnswersTableView.mj_header endRefreshing];
        [self.myAnswersTableView.mj_footer endRefreshing];
        if (isSuccess) {
            [self hideNetErrorView];
            [self.myAnswersTableView reloadData];
            [self createLoadMoreView];
            self.blankView.hidden = ![self.myViewModel isEmpty];
        } else {
            if (self.pageModel.page>1) {
                self.pageModel.page -- ;
            }
            [self.view makeToast:self.myViewModel.errorString];
            [self showNetErrorViewWithType:self.myViewModel.errorType whetherLittleIconModel:NO frame:self.myAnswersTableView.frame];
        }
    }];
}

#pragma mark  加载更多
- (void)createLoadMoreView {
    if ([self.myViewModel hasMoreMyAnswersListData]) {
        @weakify(self);
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{
            @strongify(self);
            [self loadMoreMyAnswersListData];
        }];
        self.myAnswersTableView.mj_footer = foot;
    } else if (![self.myViewModel isEmpty]) {
        CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{
            
        }];
        self.myAnswersTableView.mj_footer = foot;
        [foot setState:MJRefreshStateNoMoreData];
    } else {
        self.myAnswersTableView.mj_footer = nil;
    }
}

#pragma mark 加载最新
- (void)loadNewMyAnswersListData {
    self.pageModel.page = 1;
    [self loadMyAnswersData];
}

#pragma mark 加载更多
- (void)loadMoreMyAnswersListData {
    self.pageModel.page ++;
    [self loadMyAnswersData];
}

#pragma mark 刷新数据
- (void)baseRefreshData {
    [self loadNewMyAnswersListData];
}

#pragma mark 界面初始化
- (void)initMyAnswersView {
    [self.view addSubview:self.draftBtn];
    [self.draftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kStatusBar_Height+7);
        make.right.mas_equalTo(self.view.mas_right).offset(-16);
        make.height.mas_equalTo(30);
    }];

    [self.view addSubview:self.myAnswersTableView];
    [self.myAnswersTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kNavBar_Height);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(kScreen_Height-kNavBar_Height);
    }];
    
    [self.myAnswersTableView addSubview:self.blankView];
    [self.blankView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.myAnswersTableView);
    }];
    self.blankView.hidden = YES;
}

#pragma mark 滚动时音频播放监听
- (void)scrollingForAudioStop {
    if (self.currentAudioIndexPath) {
        //标记的cell  在tableView中的坐标值
        CGRect  recttIntableview = [self.myAnswersTableView rectForRowAtIndexPath:self.currentAudioIndexPath];
        //当前cell在屏幕中的坐标值
        CGRect rectInSuperView = [self.myAnswersTableView convertRect:recttIntableview toView:[self.myAnswersTableView superview]];
        // 对已经移出屏幕的 Cell 做相应的处理
        CTFMyAnswerCellLayout *layout= [self.myViewModel getMyAnswerModelWithIndex:self.currentAudioIndexPath.row];
        CGFloat titleHeight = [layout.model.question.title boundingRectWithSize:CGSizeMake(kScreen_Width-2*kMarginLeft, CGFLOAT_MAX) withTextFont:[UIFont mediumFontWithSize:18]].height;
        CGFloat headHeight = titleHeight + 56;
        CGFloat contentH = kIsEmptyString(layout.model.content)?50:[layout.model.content ctTextSizeWithFont:[UIFont regularFontWithSize:16] numberOfLines:2 constrainedWidth:kScreen_Width-2*kMarginLeft].height;
        CGFloat bottomHeight = contentH + 78;
        
        if (rectInSuperView.origin.y + rectInSuperView.size.height - bottomHeight -(kIsEmptyString(layout.model.content)?30:80) < 0 || rectInSuperView.origin.y - headHeight - bottomHeight - 20 > rectInSuperView.size.height) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kAudioStopPlayNotification object:nil];
            [self stopCurrentAudio];
        }
    }
}

#pragma mark 停止当前音频播放
- (void)stopCurrentAudio {
    if (self.currentAudioIndexPath) {
        CTFMyAnswerCell *cell = [self.myAnswersTableView cellForRowAtIndexPath:self.currentAudioIndexPath];
        [cell stopAuido];
        self.currentAudioIndexPath = nil;
    }
}

#pragma mark  播放视频
- (void)playTheVideoAtIndexPath:(NSIndexPath *)indexPath scrollToTop:(BOOL)scrollToTop {
    NSInteger index = indexPath.row;
    if ([[CTFNetReachabilityManager sharedInstance] currentNetStatus] != AFNetworkReachabilityStatusNotReachable){
        [self stopCurrentAudio];
        CTFMyAnswerCellLayout *layout= [self.myViewModel getMyAnswerModelWithIndex:index];
        BOOL shupin = YES;
        if (layout.model.video.rotation == 0||layout.model.video.rotation==180) {
            if(layout.model.video.width > layout.model.video.height) shupin = NO;
        }
        if (!kIsEmptyString(layout.model.video.url)) {
            NSURL *URL = [NSURL safe_URLWithString:layout.model.video.url];
            BOOL isLarge = [AppMargin isLargeScaleIsWidth:layout.model.video.width height:layout.model.video.height rotation:layout.model.video.rotation];
            [self.controlView showTitle:nil coverURLString:layout.model.video.coverUrl fullScreenMode: shupin ? ZFFullScreenModePortrait : ZFFullScreenModeLandscape isLarge:isLarge];
            [self.player playTheIndexPath:indexPath assetURL:URL seek:layout.model.video.aleayPlayDuration scrollToTop:scrollToTop];
        } else {
            NSString *origUrl =  [[CTVideoCache share] getVideoWithQuestionId:layout.model.question.questionId];
            if (!kIsEmptyString(origUrl)) {
                NSURL *URL = [NSURL fileURLWithPath:origUrl];
                ZLLog(@"播放本地视频：%@",URL);
                [self.player playTheIndexPath:indexPath assetURL:URL seek:layout.model.video.aleayPlayDuration scrollToTop:scrollToTop];
            }
        }
    }
}

#pragma mark 停止播放视频
- (void)stopVideoIfNeed {
    if (self.player.playingIndexPath) {
        NSIndexPath *indexPath = self.player.playingIndexPath;
        CTFMyAnswerCellLayout *layout= [self.myViewModel getMyAnswerModelWithIndex:indexPath.row];
        layout.model.video.aleayPlayDuration = 0;
    }
    [self.player stopCurrentPlayingCell];
}

#pragma mark 暂停播放视频
- (void)pauseVideoIfNeed{
    if (self.player.playingIndexPath && self.player.currentPlayerManager.playState == ZFPlayerPlayStatePlaying) {
        [self.player.currentPlayerManager pause];
    }
}

#pragma mark 继续播放视频
- (void)playVideoIfNeed{
    if (self.player.playingIndexPath && self.player.currentPlayerManager.playState == ZFPlayerPlayStatePaused) {
        [self.player.currentPlayerManager play];
    }
}

#pragma mark 设置播放器
- (void)setupAVVideoPlayer {
    /// playerManager
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
    /// player,tag值必须在cell里设置
    self.player = [ZFPlayerController playerWithScrollView:self.myAnswersTableView playerManager:playerManager containerViewTag:1000];
    self.player.controlView = self.controlView;
    /// 1.0是消失100%时候
    self.player.playerDisapperaPercent = 0.5f;
    /// 播放器view露出一半时候开始播放
    self.player.playerApperaPercent = 1;
    self.player.currentPlayerManager.muted = [[CTFVideoMuteManager sharedInstance] getAudoMuteInFeed];
    self.player.WWANAutoPlay = NO;
    self.player.shouldAutoPlay = NO;
    self.player.exitFullScreenWhenStop = NO;
    
    @weakify(self);
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        @strongify(self);
        NSIndexPath *index = self.player.playingIndexPath;
        CTFMyAnswerCellLayout *layout= [self.myViewModel getMyAnswerModelWithIndex:index.row];
        layout.model.video.aleayPlayDuration = 0;
    };
    
    self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        @strongify(self);
        [self stopCurrentAudio];
        self.isFullScreen = isFullScreen;
        [self setNeedsStatusBarAppearanceUpdate];
    };

    self.player.playerPlayTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration){
        @strongify(self);
        NSIndexPath *index = self.player.playingIndexPath;
        CTFMyAnswerCellLayout *layout= [self.myViewModel getMyAnswerModelWithIndex:index.row];
        layout.model.video.aleayPlayDuration = currentTime;
    };
    self.player.playerPlayStateChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerPlaybackState playState) {
      @strongify(self);
        if (playState == ZFPlayerPlayStatePlaying) {
            [self stopCurrentAudio];
        }
    };
}

#pragma mark -- Getters
#pragma mark 草稿箱
- (UIButton *)draftBtn {
    if (!_draftBtn) {
        _draftBtn = [[UIButton alloc] init];
        [_draftBtn setTitleColor:[UIColor ctColor80] forState:UIControlStateNormal];
        _draftBtn.titleLabel.font = [UIFont regularFontWithSize:12];
        [_draftBtn addTarget:self action:@selector(rightNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _draftBtn;
}

#pragma mark 主页
- (UITableView *)myAnswersTableView {
    if (!_myAnswersTableView) {
        _myAnswersTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _myAnswersTableView.delegate = self;
        _myAnswersTableView.dataSource = self;
        _myAnswersTableView.tableFooterView = [[UIView alloc] init];
        _myAnswersTableView.estimatedRowHeight = 0;
        _myAnswersTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _myAnswersTableView.showsVerticalScrollIndicator = NO;
        [_myAnswersTableView registerClass:[CTFMyAnswerCell class] forCellReuseIdentifier:@"CTFMyAnswerCell"];
        
        @weakify(self);
        _myAnswersTableView.mj_header = [[CTRefreshHeader alloc] initWithRefreshingBlock:^{
            @strongify(self);
            [self loadNewMyAnswersListData];
        }];
        _myAnswersTableView.zf_scrollViewDidStopScrollCallback = ^(NSIndexPath * _Nonnull indexPath) {
            @strongify(self)
            if (!self.player.playingIndexPath) {
                [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
            }
        };
    }
    return _myAnswersTableView;
}

#pragma mark 播放器显示
- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [ZFPlayerControlView new];
    }
    return _controlView;
}

#pragma mark 空白页
- (CTFBaseBlankView *)blankView {
    if (!_blankView) {
        _blankView = [[CTFBaseBlankView alloc] initWithFrame:self.myAnswersTableView.bounds blankType:CTFBlankType_MineViewPoint imageOffY:120];
    }
    return _blankView;
}

- (PagingModel *)pageModel {
    if (!_pageModel) {
        _pageModel = [[PagingModel alloc] init];
        _pageModel.page = 1;
        _pageModel.pageSize = 8;
    }
    return _pageModel;
}

- (void)dealloc {
    [self stopVideoIfNeed];
    [self stopCurrentAudio];
}

@end
