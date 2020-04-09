//
//  CTFTopicDetailsVC.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/12.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFTopicDetailsVC.h"
#import "PublishTopicViewController.h"
#import "CTFPublishImageViewpointVC.h"
#import "CTFPublishImageViewpointVC.h"
#import "BaseNavigationController.h"
#import "CTFReportTypeOptionVC.h"
#import "CTFShareManagerViewController.h"

#import "CTFEmptyAnswerCell.h"
#import "CTFTopicInfoCell.h"
#import "CTFAnswerDetailCell.h"
#import "CTFShowAllAnswerCell.h"
#import "CTFPublishAnswerView.h"
#import "ZFPlayerControlView.h"
#import "CTFInvitedUserDisplayCell.h"
#import "CTFSkeletonCellThree.h"
#import "CTFSkeletonCellFour.h"
#import "CTFTopicDetailsViewModel.h"
#import "MainPageViewModel.h"
#import "CTFVideoMuteManager.h"
#import "CTFCommonManager.h"
#import "ZFPlayer.h"
#import "ZFAVPlayerManager.h"
#import "CTFAudioPlayerManager.h"
#import "NSURL+Ext.h"
#import "NSString+Size.h"
#import <UIScrollView+EmptyDataSet.h>
#import <UMShare/UMShare.h>
#import <AliyunOSSiOS.h>
#import <HWPanModal.h>


@interface CTFTopicDetailsVC ()<UITableViewDelegate,UITableViewDataSource,CTFAnswerDetailCellDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate,CTFSkeletonDelegate>{
    CGFloat   lastOffsetY;
    BOOL      publishViewHide;
}

@property (nonatomic,strong) UITableView              *mainTableView;
@property (nonatomic,strong) CTFPublishAnswerView     *publishView;  //我来回答、查看我的回答
@property (nonatomic,strong) ZFPlayerController       *player;
@property (nonatomic,strong) ZFPlayerControlView      *controlView;

@property (nonatomic,strong) CTFTopicDetailsViewModel *adpater;
@property (nonatomic,strong) MainPageViewModel        *mainAdpater;

@property (nonatomic,assign) BOOL           isFullScreen;
@property (nonatomic,assign) NSInteger      inAnswerId;//指定的回答ID
@property (nonatomic,assign) BOOL           isMyAnswer;
@property (nonatomic,strong) NSIndexPath    *currentAudioIndexPath;

@property (nonatomic,strong) MBProgressHUD  *HUB;

#pragma mark - skeleton : property
@property (nonatomic, assign) BOOL skeleton_isLoaded;

// 是否显示被邀请的用户列表（Tip：刚发布话题后需要展示设置为YES）
@property (nonatomic, assign) BOOL showInvitedUserDisplay;

// 是否显示过被邀请的用户列表（Tip：刚发布话题后需要展示设置为NO）
@property (nonatomic, assign) BOOL showedInvitedUserDisplay;

@property (nonatomic,assign) BOOL  answerSucceed; //回答成功

@end

@implementation CTFTopicDetailsVC

#pragma mark - skeleton : function
- (NSInteger)collectionSkeletonView:(UITableView *)skeletonView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)numSectionsIn:(UITableView *)collectionSkeletonView {
    return 2;
}

- (NSString *)collectionSkeletonView:(UITableView *)skeletonView cellIdentifierForRowAt:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return @"CTFSkeletonCellThree";
    } else {
        return @"CTFSkeletonCellFour";
    }
}

- (void)skeleton_show {
    self.skeleton_isLoaded = NO;
    [self.mainTableView registerClass:[CTFSkeletonCellThree class] forCellReuseIdentifier:@"CTFSkeletonCellThree"];
    [self.mainTableView registerClass:[CTFSkeletonCellFour class] forCellReuseIdentifier:@"CTFSkeletonCellFour"];
    [self.mainTableView ctf_showSkeleton];
    
}

- (void)skeleton_hide {
    self.skeleton_isLoaded = YES;
    [self.mainTableView ctf_hideSkeleton];
}

- (NSInteger)skeleton_height:(NSInteger)section {
    if (section == 0) {
        return [CTFSkeletonCellThree defaultHeight];
    } else {
        return [CTFSkeletonCellFour defaultHeight];
    }
}

#pragma mark - 控制器生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSInteger quesionId = [self.schemaArgu safe_integerForKey:@"questionId"];
    self.inAnswerId =  [self.schemaArgu safe_integerForKey:@"answerId"];
    self.showInvitedUserDisplay = [self.schemaArgu safe_integerForKey:@"showInvitedUserDisplay"];
    if(self.inAnswerId){
        self.baseTitle = @"回答详情";
    }else{
        self.baseTitle = @"话题详情";
    }
    self.rightImageName = @"answer_icon_share";
    
    BOOL showAll = [self.schemaArgu safe_integerForKey:@"showAll"];//话题描述展示所有全部
    self.adpater = [[CTFTopicDetailsViewModel alloc] initWithTopicId:quesionId showAll:showAll];
    self.adpater.inAnswerId = self.inAnswerId;
    
    //是否显示我的观点
    self.isMyAnswer = [self.schemaArgu safe_integerForKey:@"showMyAnswer"];
    if (self.isMyAnswer) {
        [self.adpater setSectionTwoShowType:SectionTwoShowType_MyAnswer];
    }
    self.mainAdpater = [[MainPageViewModel alloc] init];
    
    [self setupUI];
    [self skeleton_show];
    [self setupAVVideoPlayer];
    [self.mainTableView.mj_header beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([CTFCommonManager sharedCTFCommonManager].topicReLoad) {
        [self.mainTableView.mj_header beginRefreshing];
        [CTFCommonManager sharedCTFCommonManager].topicReLoad = NO;
    }
    [self registNotification];
    [self continuePalyVideoIfNeed];
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

- (BOOL)prefersStatusBarHidden {
    return self.isFullScreen;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.adpater numberTopic];
    } else if (self.showInvitedUserDisplay) {
        return 1;
    } else {
        return [self.adpater numberOfAnswerList];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0) {
        CTFTopicInfoCell *card = [tableView dequeueReusableCellWithIdentifier:[CTFTopicInfoCell identifier] forIndexPath:indexPath];
        card.cardIndexPath = indexPath;
        [card fillContentWithData:[self.adpater currentTopicDetailModel]];
        @weakify(self);
        card.switchShowAllTopicContent = ^{
            @strongify(self);
            [self.mainTableView reloadData];
        };
        return card;
    } else if (self.showInvitedUserDisplay) {
        CTFInvitedUserDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CTFInvitedUserDisplayCell"];
        [cell fillContentWithData:[self.adpater query_invitedUserList]];
        return cell;
    } else {
        CTFAnswerDetailCellLayout *layout = [self.adpater answerModelForIndex:indexPath.row
        ];
        CTFTopicInfoCellLayout *topicLayout = [self.adpater currentTopicDetailModel];
        if ([layout.model.type isEqualToString:@"showall"]&&topicLayout.model.answerCount>1) {
            CTFShowAllAnswerCell *card = [tableView dequeueReusableCellWithIdentifier:[CTFShowAllAnswerCell identifier] forIndexPath:indexPath];
            @weakify(self);
            card.didClickShowAllAnswer = ^(){
               @strongify(self);
               [MobClick event:@"answerlist_viewall"];
               [self showAllAnswers];
            };
            return card;
        } else if([layout.model.type isEqualToString:@"images"] || [layout.model.type isEqualToString:@"video"]||[layout.model.type isEqualToString:@"audioImage"]) {
            CTFAnswerDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:[CTFAnswerDetailCell identifier]];
            [cell setDelegate:self withIndexPath:indexPath];
            [cell fillContentWithData:layout];
            return cell;
        } else {
            CTFEmptyAnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:[CTFEmptyAnswerCell identifier]];
            return cell;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.skeleton_isLoaded) {
            if (self.adpater.currentTopicDetailModel.model.showAll) {
                return self.adpater.currentTopicDetailModel.allHeight;
            } else {
                return self.adpater.currentTopicDetailModel.height;
            }
        } else {
            return [self skeleton_height:0];
        }
    } else if(indexPath.section == 1) {
        if (self.showInvitedUserDisplay) {
            NSInteger userCount = [self.adpater query_invitedUserList].count;
            NSInteger lineCount = userCount % 4 == 0 ? userCount / 4 : (userCount / 4) +1;
            return lineCount * 70 + 52 + 15 + kTabBar_Height;
        } else {
            if (self.skeleton_isLoaded) {
                CTFAnswerDetailCellLayout *layout = [self.adpater answerModelForIndex:indexPath.row];
                if (layout) {
                    return layout.height;
                }
                return 340;
            } else {
                return [self skeleton_height:1];
            }
        }
    }
    return 0;
}

#pragma mark - UIScrollViewDelegate   列表播放必须实现
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidEndDecelerating];
    BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
    if (scrollToScrollStop) {
        [self didStopScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [scrollView zf_scrollViewDidEndDraggingWillDecelerate:decelerate];
    if (!decelerate) {
        BOOL dragToDragStop = scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
        if (dragToDragStop) {
            [self didStopScroll];
        }
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScrollToTop];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScroll];
    [self didScrolling:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewWillBeginDragging];
    lastOffsetY = scrollView.contentOffset.y;
}

#pragma mark  DZNEmptyDataSetSource and DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    if ([self.adpater isRefreshing]) {
        return NO;
    }
    if (([self.adpater isReviewingTopic] && ![self.adpater isMyTopic])||(self.inAnswerId > 0 && [self.adpater isReviewingAnswer])) {
        return YES;
    }
    if (self.adpater.errorType == ERROR_NET || self.adpater.errorType == ERROR_SERVER) {
        [self skeleton_hide];
        return YES;
    }
    if ([self.adpater isEmpty]) {//
        [self skeleton_hide];
        return YES;
    }
    return NO;
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    if (([self.adpater isReviewingTopic] && ![self.adpater isMyTopic])||(self.inAnswerId > 0 && [self.adpater isReviewingAnswer])) {
         return ImageNamed(@"detils_topic_reviewing");
    }
    if (self.adpater.serverErrorCode == 4002) {
         return [UIImage imageNamed:@"empty_NoDB_120x120"];
    }
    if (self.adpater.errorType == ERROR_NET || self.adpater.errorType == ERROR_SERVER) {
        return [UIImage imageNamed:@"empty_NoNetwork_154x154"];
    }
    if ([self.adpater isEmpty]) {
         return [UIImage imageNamed:@"empty_NoContent_160x160"];
    }
    return nil;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:14.0f],
    NSForegroundColorAttributeName: UIColorFromHEX(0x909090)};
    NSString *text = @"";
    if ([self.adpater isReviewingTopic] && ![self.adpater isMyTopic]) {
        self.rightImageName = @"";
        text = @"话题正在审核中";
        return [[NSAttributedString alloc] initWithString:text attributes:attributes];
    }
    if (self.inAnswerId > 0 && [self.adpater isReviewingAnswer]) {
        self.rightImageName = @"";
        text = @"回答正在审核中";
        return [[NSAttributedString alloc] initWithString:text attributes:attributes];
    }
    
    if (self.adpater.serverErrorCode == 4002) {
        self.rightImageName = @"";
        if (self.inAnswerId) {
             text = @"这个回答飞走了~";
         } else {
             text = @"这个话题飞走了~";
         }
        [self.publishView setHidden:YES];
        return [[NSAttributedString alloc] initWithString:text attributes:attributes];
    }
    if (self.adpater.errorType == ERROR_NET || self.adpater.errorType == ERROR_SERVER) {
        text = @"网络出了一点小意外~";
        return [[NSAttributedString alloc] initWithString:text attributes:attributes];
    }
    if ([self.adpater isEmpty]) {
        text = @"内容还在努力生产中~";
        return [[NSAttributedString alloc] initWithString:text attributes:attributes];
    }
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return -60;
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView {
    return 20;
}

#pragma mark - CTFAnswerDetailCellDelegate
#pragma mark 视频播放
- (void)answerDetailCell:(CTFAnswerDetailCell *)answerDetailCell playTheVideoAtIndexPath:(NSIndexPath *)indexPath{
    [MobClick event:@"answerlist_listitemplay"];
    [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
}

#pragma mark -- Event response
#pragma mark 分享话题
-(void)rightNavigationItemAction{
    if (![self ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded]) {
        return;
    }
    
    if ([self.adpater currentTopicDetailModel] == nil) return;
    CTFQuestionsModel *model = [self.adpater currentTopicDetailModel].model;
    [MobClick event:@"answerlist_listitemmore"];
    CTFShareType type = model.isAuthor ? CTFShareTypeQuestionMine: CTFShareTypeQuestionOthers;
    [self shareTopicForAnswerWithType:type];
}

#pragma mark - routerEventWithName
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo{
    NSIndexPath *indexPath = [userInfo safe_objectForKey:kCellIndexPathKey];
    if (self.player.playingIndexPath && self.player.playingIndexPath == indexPath) {
        [CTFCommonManager sharedCTFCommonManager].needVideoStop = NO;
    } else {
        [CTFCommonManager sharedCTFCommonManager].needVideoStop = YES;
    }
    if ([eventName isEqualToString:kViewpointUserInfoEvent]) {
        [CTFCommonManager sharedCTFCommonManager].needVideoStop = YES;
        AnswerModel *model = [userInfo safe_objectForKey:kViewpointDataModelKey];
        [ROUTER routeByCls:kCTFHomePageVC withParam:@{@"userId": @(model.author.authorId)}];
    } else if ([eventName isEqualToString:kFollowUserEvent]) {
        AnswerModel *model = [userInfo safe_objectForKey:kViewpointDataModelKey];
        [MobClick event:@"answerlist_focus"];
         @weakify(self);
        [self.adpater followActionToUser:model.author.authorId needFollow:!model.author.isFollowing complete:^(BOOL isSuccess) {
            @strongify(self);
            if(isSuccess){
                model.author.isFollowing = !model.author.isFollowing;
                [self.mainTableView reloadData];
            }else{
               [self.view makeToast:self.adpater.errorString];
            }
        }];
    } else if ([eventName isEqualToString:kAnswerDeleteEvent] || [eventName isEqualToString:kAnswerNotInterestedEvent]) { //删除回答或不感兴趣
        AnswerModel *model = [userInfo safe_objectForKey:kViewpointDataModelKey];
        if (self.adpater.showAnswerType == SectionTwoShowType_MyAnswer){
            //如果当前显示的自己的回答，删除回答之后，自动切换到 AnwserList
            [self.adpater setSectionTwoShowType: SectionTwoShowType_AnswerList];
        }
        [self stopCurrentAudio];
        [self stopVideoIfNeed];
        BOOL isMine = [eventName isEqualToString:kAnswerDeleteEvent];
        [self.adpater deleteAnswerWithAnswerId:model.answerId isMine:isMine];
        [self.mainTableView reloadData];
        [self updateUIContent];
    } else if ([eventName isEqualToString:kTopicTitleEvent]) {
        [MobClick event:@"answerlist_viewall"];
        [self showAllAnswers];
    } else if ([eventName isEqualToString:kTopicLikeEvent] || [eventName isEqualToString:kTopicUnlikeEvent]) {
        NSString *eventStr = [eventName isEqualToString:kTopicLikeEvent] ? @"answerlist_care" : @"answerlist_nocare";
        [MobClick event:eventStr];
        CTFQuestionsModel *model = [userInfo safe_objectForKey:kTopicDataModelKey];
        [self.adpater votersToQuestion:model.questionId attitude:model.attitude complete:^(BOOL isSuccess) {
            
        }];
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
        CTFAnswerDetailCellLayout *layout = [self.adpater answerModelForIndex:indexPath.row];
        if ([layout.model.type isEqualToString:@"audioImage"]) {
            layout.model.currentIndex = [userInfo safe_integerForKey:@"currentIndex"];
        }
        [self stopVideoIfNeed];
    } else if ([eventName isEqualToString:kReloadAnswerCommentEvent]) {
        NSIndexPath *indexPath = [userInfo safe_objectForKey:kCellIndexPathKey];
        [self.mainTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        if (self.player.playingIndexPath == indexPath) {
            [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
        }
    } else if ([eventName isEqualToString:kAnswerReportEvent]) {
        [self pauseVideoIfNeed];
        [self stopCurrentAudio];
    } else if ([eventName isEqualToString:kAnswerReportDismissEvent]) {
        [self continuePalyVideoIfNeed];
    }
}

#pragma mark -- NSNotification
#pragma mark 保存草稿成功
- (void)saveToDraftNotication:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        [kKeyWindow makeToast:@"内容保存到草稿箱"];
    });
}

#pragma mark 回答成功
-(void)publishAnswerSuccessNotification:(id)sender{
    [self stopVideoIfNeed];
    self.answerSucceed = YES;
    [self.adpater setSectionTwoShowType:SectionTwoShowType_MyAnswer];
    [self.mainTableView reloadData];
    [self.mainTableView.mj_header beginRefreshing];
}

#pragma mark -- Private methods
#pragma mark 获取话题详情数据
- (void)refreshData {
    [self stopCurrentAudio];
    [self stopVideoIfNeed];
    @weakify(self);
    [self.adpater obtianTopicDetailComplete:^(BOOL isSuccess) {
        @strongify(self);
        if (isSuccess) {
            if (self.adpater.showAnswerType == SectionTwoShowType_MyAnswer) {
                // 只显示我的回答
                [self showViewpointDetail:[self.adpater myAnswerId]];
            } else if (self.adpater.showAnswerType == SectionTwoShowType_InAnswer) {
                // 显示指定回答ID的回答
                [self showViewpointDetail:self.inAnswerId];
            } else if (self.adpater.showAnswerType == SectionTwoShowType_AnswerList) {
                // 显示所有回答
                [self refreshAnswerList];
            } else { // 即 (self.adpater.showAnswerType == SectionTwoShowType_Unknown)
                     // SectionTwoShowType_Unknown 认为是首次进入
                if (self.inAnswerId) {
                    // 显示指定回答ID的回答（Tip：从首页点击Cell进入的是这里）
                    [self.adpater setSectionTwoShowType:SectionTwoShowType_InAnswer];
                    [self showViewpointDetail:self.inAnswerId];
                } else {
                    // 显示所有回答(Tip：发布话题后进入的是这里)
                    [self.adpater setSectionTwoShowType:SectionTwoShowType_AnswerList];
                    [self refreshAnswerList];
                }
            }
        } else {
            if (self.adpater.serverErrorCode != 4002) {
                 [self.view makeToast:self.adpater.errorString];
            }
            [self.mainTableView.mj_header endRefreshing];
            [self.mainTableView reloadData];
        }
    }];
}

#pragma mark 获取话题下的所有观点并且刷新列表
- (void)refreshAnswerList {
    self.adpater.page.page = 1;
    self.adpater.page.pageSize = 16;
    
    @weakify(self);
    [self.adpater fetchQuestionAnswersComplete:^(BOOL isSuccess) {
        @strongify(self);
        [self skeleton_hide];
        [self.HUB hideAnimated:NO];
        self.HUB = nil;
        [self.mainTableView.mj_header endRefreshing];
        if (isSuccess) {
            /* 如果有回答列表数据就不用显示邀请的用户列表 */
            if ([self.adpater numberOfAnswer] > 0) {
                self.showInvitedUserDisplay = NO;
            }
            if ([self.adpater isReviewingTopic]) {
                self.showInvitedUserDisplay = NO;
            }
            [self didStopScroll];
            [self.mainTableView reloadData];// 刷新列表
            [self updateUIContent];// 导航栏title 和 publishView控件 的配置
            [self createLoadMoreView];// CTRefreshFooter的设置
            if (self.showInvitedUserDisplay && !self.showedInvitedUserDisplay && ![self.adpater isReviewingTopic]) {
                UIView *invitingHUD = [[UIView alloc] initWithFrame:self.view.frame];
                invitingHUD.backgroundColor = UIColorFromHEXWithAlpha(0x000000, 0.8);
                [self.view addSubview:invitingHUD];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
                AnimationView *animation_inviting = [invitingHUD showInviteLoadingAnimation:CTLottieAnimationTypeInvite_loading completion:nil];
#pragma clang diagnostic pop
                UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 412, self.view.width, 30)];
                messageLabel.text = @"发布成功，正在邀请回答者";
                messageLabel.textAlignment = NSTextAlignmentCenter;
                messageLabel.font = [UIFont systemFontOfSize:14.4];
                messageLabel.textColor = UIColorFromHEX(0xFFFFFF);
                [invitingHUD addSubview:messageLabel];
                dispatch_queue_t queue = dispatch_get_main_queue();
                @weakify(self);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), queue, ^{
                    @strongify(self);
                    [invitingHUD removeFromSuperview];
                    [self refreshInvitedUserList];
                    self.showedInvitedUserDisplay = YES;
                });
            }
        } else {
            [self.view makeToast:self.adpater.errorString];
        }
    }];
}

#pragma mark 获取邀请用户列表
- (void)refreshInvitedUserList {
    @weakify(self);
    [self.adpater fetchAll_invitedUserListComplete:^(BOOL isSuccess) {
        @strongify(self);
        [self skeleton_hide];
        [self.HUB hideAnimated:NO];
        self.HUB = nil;
        [self.mainTableView.mj_header endRefreshing];
        if (isSuccess) {
            [self.mainTableView reloadData];// 刷新列表
            [self updateUIContent];// 导航栏title 和 publishView控件 的配置
            [self createLoadMoreView];// CTRefreshFooter的设置
            [[CTPushManager share] showAuthReqAlertIfNeed];
        } else {
            [self.view makeToast:@"邀请失败：似乎出了点问题"];
        }
    }];
}

#pragma mark 加载更多回答列表
-(void)loadmoreAnswerList{
    self.adpater.page.page++;
    @weakify(self);
    [self.adpater fetchQuestionAnswersComplete:^(BOOL isSuccess) {
         [self.mainTableView.mj_footer endRefreshing];
         @strongify(self);
         if (isSuccess) {
            [self.mainTableView reloadData];
            [self createLoadMoreView];
         } else {
            [self.view makeToast:self.adpater.errorString];
         }
    }];
}

#pragma mark 加载回答详情
-(void)showViewpointDetail:(NSInteger)answerId{
    @weakify(self);
    [self.adpater obtainViewpointDetail:answerId complete:^(BOOL isSuccess) {
        @strongify(self);
        [self skeleton_hide];
        [self.HUB hideAnimated:NO];
        self.HUB = nil;
        [self.mainTableView.mj_header endRefreshing];
        if (isSuccess) {
            if (self.answerSucceed) {
                [[CTPushManager share] showAuthReqAlertIfNeed];
                self.answerSucceed = NO;
                CTFAnswerDetailCellLayout *layout = [self.adpater answerModelForIndex:0];
                [self publishSucceedForShareAnswer:layout.model];
            }
            /* 如果有回答列表数据就不用显示邀请的用户列表 */
            if ([self.adpater numberOfAnswer] > 0) {
                self.showInvitedUserDisplay = NO;
            }
            [self didStopScroll];
            [self.mainTableView reloadData];
            [self updateUIContent];
            [self createLoadMoreView];
        } else {
            if (self.adpater.serverErrorCode != 4002) {
                [self.view makeToast:self.adpater.errorString];
            }
        }
    }];
}

#pragma mark  举报话题
- (void)reportTopic:(NSInteger)questionId {
    [self stopVideoIfNeed];
    CTFReportTypeOptionVC *reportTypeOptionVC = [[CTFReportTypeOptionVC alloc] initWithFeedBackType:FeedBackType_Question resourceTypeId:questionId];
    reportTypeOptionVC.dismissBlock = ^{
        
    };
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:reportTypeOptionVC];
    nav.modalPresentationStyle = UIModalPresentationCustom;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

#pragma mark 删除话题
-(void)deleteMyTopic:(NSInteger)questionId{
    [self.adpater deleteTopic:questionId complete:^(BOOL isSuccess) {
        if (isSuccess) {
            [self stopCurrentAudio];
            [kKeyWindow makeToast:@"删除成功"];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self.view makeToast:self.adpater.errorString];
            NSError *error = nil;
            [self.adpater handlerError:error];
        }
    }];
}

#pragma mark 停止滚动
- (void)didStopScroll {
    NSArray *visiableCells = [self.mainTableView visibleCells];
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    for (UITableViewCell *cell in visiableCells) {
        if ([cell isKindOfClass:[CTFAnswerDetailCell class]]) {
            [tempArr addObject:cell];
        }
    }
    if (tempArr.count > 0) {
        for (CTFAnswerDetailCell *cell in tempArr) {
            NSIndexPath *indexPath = [self.mainTableView indexPathForCell:cell];
            CTFAnswerDetailCellLayout *layout = [self.adpater answerModelForIndex:indexPath.row];
            [self.mainAdpater uploadAnswerHasReadWithAnswerId:layout.model.answerId];
        }
    }
}

#pragma mark 监听正在滚动
-(void)didScrolling:(UIScrollView *)scrollView{
    CGFloat curOffy = scrollView.contentOffset.y;
    if (curOffy - lastOffsetY > 0) {
        if (fabs(curOffy - lastOffsetY) > 70) {
             [self animationHidePublishButton];
        }
    } else {
        if (fabs(curOffy - lastOffsetY) > 70) {
             [self animationShowPublishButton];
        }
    }
    
    //音频滚动停止
    if (self.currentAudioIndexPath) {
        //标记的cell  在tableView中的坐标值
        CGRect  recttIntableview = [self.mainTableView rectForRowAtIndexPath:self.currentAudioIndexPath];
        //当前cell在屏幕中的坐标值
        CGRect rectInSuperView = [self.mainTableView convertRect:recttIntableview toView:[self.mainTableView superview]];
        // 对已经移出屏幕的 Cell 做相应的处理
        CTFAnswerDetailCellLayout *layout = [self.adpater answerModelForIndex:self.currentAudioIndexPath.row];
        //图片上高度
        CGFloat headHeight = 64;
        //图片下面高度
        CGFloat contentH = kIsEmptyString(layout.model.content)?0:[layout.model.content boundingRectWithSize:CGSizeMake(kScreen_Width-2*kMarginLeft, CGFLOAT_MAX) withTextFont:[UIFont regularFontWithSize:16]].height;;
        CGFloat bottomHeight = contentH + 64;
        
        if (rectInSuperView.origin.y + rectInSuperView.size.height - bottomHeight - 110 < 0 || rectInSuperView.origin.y - headHeight - bottomHeight - 60 > rectInSuperView.size.height) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kAudioStopPlayNotification object:nil];
            [self stopCurrentAudio];
        }
    }
}

#pragma mark 续播
- (void)continuePalyVideoIfNeed {
    if (self.player.playingIndexPath && self.player.currentPlayerManager.playState == ZFPlayerPlayStatePaused) {
        [self.player.currentPlayerManager play];
    }
}

#pragma mark 暂停播放
- (void)pauseVideoIfNeed {
    if (self.player.playingIndexPath && self.player.currentPlayerManager.playState == ZFPlayerPlayStatePlaying) {
        [self.player.currentPlayerManager pause];
    }
}

#pragma mark 停止播放
- (void)stopVideoIfNeed {
    if (self.player.playingIndexPath) {
        NSIndexPath *indexPath = self.player.playingIndexPath;
        CTFAnswerDetailCellLayout *layout = [self.adpater answerModelForIndex:indexPath.row];
        layout.model.video.aleayPlayDuration = 0;
    }
    [self.player stopCurrentPlayingCell];
}

#pragma mark 停止当前音频播放
-(void)stopCurrentAudio{
    if (self.currentAudioIndexPath) {
        UITableViewCell *cell = [self.mainTableView cellForRowAtIndexPath:self.currentAudioIndexPath];
        if ([cell isKindOfClass:[CTFAnswerDetailCell class]]) {
            CTFAnswerDetailCell *myCell = (CTFAnswerDetailCell *)cell;
            [myCell stopAuido];
        }
        self.currentAudioIndexPath = nil;
    }
}

#pragma mark 注册通知
-(void)registNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveToDraftNotication:) name:[CTDrafts share].kStoredNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publishAnswerSuccessNotification:) name:kPublishAnswerSuccessNotification object:nil];
}

#pragma mark 移除通知
-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[CTDrafts share].kStoredNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPublishAnswerSuccessNotification object:nil];
}

#pragma mark - Action
#pragma mark 隐藏发布回答
-(void)animationHidePublishButton{
    if (!publishViewHide) {
        publishViewHide = YES;
        [UIView animateWithDuration:0.25 animations:^{
            self.publishView.y = kScreen_Height;
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark 显示发布回答
-(void)animationShowPublishButton{
    if (publishViewHide) {
        publishViewHide = NO;
        [UIView animateWithDuration:0.25 animations:^{
            self.publishView.y = kScreen_Height - kTabBar_Height;
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark 查看全部回答
-(void)showAllAnswers{
    [self.adpater setSectionTwoShowType:SectionTwoShowType_AnswerList];
    self.HUB = [MBProgressHUD ctfShowLoading:self.view title:nil];
    [self refreshAnswerList];
}

#pragma mark 我来回答或查看我的回答
- (void)publishAnswer {
    [self stopCurrentAudio];
    if (![self ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded]) {
        return;
    }
    if ([self.adpater isMyAnswered]) {// 查看我的观点
        [self stopVideoIfNeed];
        [MobClick event:@"answerlist_viewmyanswer"];
        [self.adpater setSectionTwoShowType:SectionTwoShowType_MyAnswer];
        self.HUB = [MBProgressHUD ctfShowLoading:self.view title:nil];
        [self showViewpointDetail:[self.adpater myAnswerId]];
        [self updateUIContent];
        return;
    }
    if ([self.publishView.title isEqualToString:@"邀请好友回答"]) {// 邀请好友
        [self shareTopicForAnswerWithType:CTFShareTypeDefault];
    } else {
        [MobClick event:@"answerlist_answer"];// 发布观点
        NSInteger qid = self.adpater.currentTopicDetailModel.model.questionId;
        CTDraftAnswer *draftAnswer = [[CTDrafts share] getDraftWithQuestionId:qid];
        if (draftAnswer == nil) {
            NSString *title = self.adpater.currentTopicDetailModel.model.title;
            CTPublishSelectViewController *vc = [[CTPublishSelectViewController alloc] initWithQuestionId: qid questionTitle:title];
            [self presentViewController:vc animated:YES completion:nil];
        } else {
            if (draftAnswer.type  == DraftAnswerTypePhoto) {
                CTFPublishImageViewpointVC *publishImageVC = [[CTFPublishImageViewpointVC alloc] init];
                publishImageVC.draftModel = draftAnswer;
                publishImageVC.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:publishImageVC animated:YES completion:nil];
            } else if (draftAnswer.type == DraftAnswerTypeVideo) {
                CTFPublishVideoViewpointVC *publishVideoVC = [[CTFPublishVideoViewpointVC alloc] init];
                publishVideoVC.draftModel = draftAnswer;
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:publishVideoVC];
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:nav animated:YES completion:nil];
            } else if (draftAnswer.type == DraftAnswerTypePhotoWithAudio) {
                CTPublishPhotoWithAudioController *vc = [[CTPublishPhotoWithAudioController alloc] initWithDraft:draftAnswer];
                [self.navigationController pushViewController:vc animated:true];
            }
        }
    }
}

#pragma mark - private method
#pragma mark 播放视频
- (void)playTheVideoAtIndexPath:(NSIndexPath *)indexPath scrollToTop:(BOOL)scrollToTop {
    [self stopCurrentAudio];
    [MobClick event:@"answerlist_listitemplay"];
    CTFAnswerDetailCellLayout *layout = [self.adpater answerModelForIndex:indexPath.row];
    NSURL *URL;
    BOOL shupin = YES;
    if (layout.model.video.rotation == 0||layout.model.video.rotation==180) {
        if(layout.model.video.width > layout.model.video.height) shupin = NO;
    }
    if (!kIsEmptyString(layout.model.video.url)) {
        URL = [NSURL safe_URLWithString:layout.model.video.url];
        BOOL isLarge = [AppMargin isLargeScaleIsWidth:layout.model.video.width height:layout.model.video.height rotation:layout.model.video.rotation];
        [self.controlView showTitle:nil coverURLString:layout.model.video.coverUrl fullScreenMode: shupin ? ZFFullScreenModePortrait : ZFFullScreenModeLandscape isLarge:isLarge];
        [self.player playTheIndexPath:indexPath assetURL:URL seek:layout.model.video.aleayPlayDuration scrollToTop:scrollToTop];
    } else {
        if (layout.model.isAuthor) {
            CTFTopicInfoCellLayout *topicLayout = [self.adpater currentTopicDetailModel];
            NSString *origUrl =  [[CTVideoCache share] getVideoWithQuestionId:topicLayout.model.questionId];
            if (!kIsEmptyString(origUrl)) {
                URL = [NSURL fileURLWithPath:origUrl];
                ZLLog(@"播放本地视频：%@",URL);
                self.player.orientationObserver.fullScreenMode = shupin ? ZFFullScreenModePortrait : ZFFullScreenModeLandscape;
                [self.player playTheIndexPath:indexPath assetURL:URL seek:layout.model.video.aleayPlayDuration scrollToTop:scrollToTop];
            }
        }
    }
}

#pragma mark 分享话题
- (void)shareTopicForAnswerWithType:(CTFShareType )type {
    CTFQuestionsModel *model = [self.adpater currentTopicDetailModel].model;
    NSString *title = nil;
    NSString *desc = nil;
    if (type == CTFShareTypeDefault) {
        NSString *name = [UserCache getUserInfo].name;
        title = [NSString stringWithFormat:@"%@ 邀请你回答：%@",name,model.title];
        desc = @"你的回答对我很重要哦～";
    } else {
        title = model.title;
        if (self.adpater.page.total > 0) {
            desc = [NSString stringWithFormat:@"%zd个回答，等你来围观",self.adpater.page.total];
        } else {
            desc = @"超多回答，等你来围观";
        }
    }
    
    //分享图片
    id shareImage = nil;
    if (model.images.count>0) {
        ImageItemModel *item = [model.images objectAtIndex:0];
        shareImage = [AppUtils imgUrlForGrid:item.url];
    } else {
        shareImage = ImageNamed(@"share_icon_logo");
    }
     
    NSString *shareUrl = [NSString stringWithFormat:kQuestionDetailsUrl,model.idString];
    NSDictionary *info = @{@"title":title,@"desc":desc,@"image":shareImage, @"url":shareUrl,@"status":model.status,@"resourceType":@"question",@"resourceId":@(model.questionId)};
    
    CTFQuestionsModel *question = [self.adpater currentTopicDetailModel].model;
    CTFShareManagerViewController *shareVC = [[CTFShareManagerViewController alloc] init];
    shareVC.info = info;
    shareVC.type = type;
    @weakify(self);
    shareVC.myBlock = ^(NSInteger tag) {
        @strongify(self);
        if (question.isAuthor) {
            if (tag==0) { //删除话题
                [self deleteMyTopic:[self.adpater currentTopicDetailModel].model.questionId];
            } else { //修改话题
                PublishTopicViewController *topicVC = [[PublishTopicViewController alloc] init];
                topicVC.questionsModel = question;
                BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:topicVC];
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:nav animated:YES completion:nil];
            }
        } else {
            [self reportTopic:[self.adpater currentTopicDetailModel].model.questionId];
        }
    };
    [self presentPanModal:shareVC];
}

#pragma mark 分享回答
- (void)publishSucceedForShareAnswer:(AnswerModel *)answerModel {
    if (![[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_WechatSession] && ![[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_QQ]) {
        return;
    }
    
    NSString *desc = [NSString stringWithFormat:@"“%@”的回答很不错哦",answerModel.author.name];
    //分享图片
    id shareImage = nil;
    if ([answerModel.type isEqualToString:@"images"]) {
        if (answerModel.images.count>0) {
            ImageItemModel *item = [answerModel.images objectAtIndex:0];
            shareImage = [AppUtils imgUrlForGrid:item.url];
        } else {
            shareImage = ImageNamed(@"share_icon_logo");
        }
    } else if([answerModel.type isEqualToString:@"video"]) {
        if (!kIsEmptyString(answerModel.video.coverUrl)) {
            shareImage = answerModel.video.coverUrl;
        } else {
            shareImage = ImageNamed(@"share_icon_logo");
        }
    } else if ([answerModel.type isEqualToString:@"audioImage"]) {
        if (answerModel.audioImage.count>0) {
            AudioImageModel *item = [answerModel.audioImage objectAtIndex:0];
            shareImage = item.url;
        } else {
            shareImage = ImageNamed(@"share_icon_logo");
        }
    } else {
        shareImage = ImageNamed(@"share_icon_logo");
    }
    NSString *shareUrl = [NSString stringWithFormat:kAnswerDetailsUrl,answerModel.idString,answerModel.question.idString];
    NSDictionary *info = @{@"title":answerModel.question.title,@"desc":desc,@"image":shareImage,@"url":shareUrl,@"status":answerModel.status,@"resourceType":@"answer",@"resourceId":@(answerModel.answerId)};
    CTFShareManagerViewController *shareVC = [[CTFShareManagerViewController alloc] init];
    shareVC.info = info;
    shareVC.type = CTFShareTypeAnswerSucceed;
    [self presentPanModal:shareVC];
}

#pragma mark - 加载更多
-(void)createLoadMoreView{
    if (self.adpater.showAnswerType == SectionTwoShowType_AnswerList) {
        if ([self.adpater hasMoreData]) {
            @weakify(self);
            CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{
                @strongify(self);
                [MobClick event:@"answerlist_loadmore"];
                [self loadmoreAnswerList];
            }];
            self.mainTableView.mj_footer = foot;
        } else {
            CTRefreshFooter *foot = [[CTRefreshFooter alloc] initWithRefreshingBlock:^{
                
            }];
           self.mainTableView.mj_footer = foot;
           if (self.adpater.page.page>1) {
               if (self.adpater.page.count<self.adpater.page.pageSize) {
                   [foot setState:MJRefreshStateNoMoreData];
               }
           } else {
               if (self.isMyAnswer) {
                   self.mainTableView.mj_footer = nil;
               } else {
                   if (self.mainTableView.contentSize.height>self.mainTableView.height) {
                       [foot setState:MJRefreshStateNoMoreData];
                   } else {
                       if (self.adpater.page.count<self.adpater.page.pageSize) {
                           self.mainTableView.mj_footer = nil;
                       }
                   }
               }
           }
        }
    } else {
        self.mainTableView.mj_footer = nil;
    }
}

#pragma mark - UI
-(void)setupUI{
    [self.view addSubview:self.mainTableView];
    [self.view addSubview:self.publishView];
    self.publishView.hidden = YES;
}

#pragma mark 更新UI
- (void)updateUIContent {
    /* 导航栏title */
    if (self.adpater.showAnswerType == SectionTwoShowType_AnswerList) {
        self.baseTitle = @"话题详情";
    } else {
        self.baseTitle = @"回答详情";
    }
    
    /* 判断该话题下时候有我的回答观点 */
    if ([self.adpater isMyAnswered]) {
        self.publishView.title = @"查看我的回答";
        if ([self.adpater needShowFindMyAnswerBtn] && (self.adpater.showAnswerType != SectionTwoShowType_MyAnswer) && [self.adpater currentTopicDetailModel].model.answerCount > 1) {
            self.publishView.hidden = NO;
        } else {
            self.publishView.hidden = YES;
        }
    } else {
        CTFQuestionsModel * model = [self.adpater currentTopicDetailModel].model;
        if (model.isAuthor) {
            //是否安装微信和QQ
            if (![[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_WechatSession] && ![[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_QQ]) {
                self.publishView.hidden = YES;
            } else {
                self.publishView.hidden = NO;
                self.publishView.title = @"邀请好友回答";
            }
        } else {
            self.publishView.hidden = NO;
            self.publishView.title = @"我来回答";
        }
    }
    /* 判断该话题的状态，比如在审核中就不显示publishView控件 */
    if ([self.adpater isReviewingTopic] || self.adpater.serverErrorCode == 4002 || (self.inAnswerId > 0 && [self.adpater isReviewingAnswer])) {
        self.publishView.hidden = YES;
    }
}

#pragma mark -- Getters
#pragma mark 主界面
- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBar_Height, kScreen_Width, kScreen_Height-kNavBar_Height) style:UITableViewStylePlain];
        _mainTableView.dataSource = self;
        _mainTableView.delegate = self;
        _mainTableView.rowHeight = 0;
        _mainTableView.estimatedSectionFooterHeight = 0;
        _mainTableView.estimatedSectionHeaderHeight = 0;
        _mainTableView.estimatedRowHeight = 0;
        _mainTableView.emptyDataSetSource = self;
        _mainTableView.emptyDataSetDelegate = self;
        _mainTableView.backgroundColor = [UIColor clearColor];
        NSArray *tableCardsClsName = @[@"CTBaseCard",/* 继承UITableViewCell的基础cell */
                                       @"CTFTopicInfoCell",/* 话题内容cell */
                                       @"CTFAnswerDetailCell",/* 回答内容cell */
                                       @"CTFShowAllAnswerCell",/* 查看全部回答cell */
                                       @"CTFEmptyAnswerCell",/* 没有回答内容提示cell */
                                       @"CTFInvitedUserDisplayCell"
                                    ];
        for (NSString *cls in tableCardsClsName) {
            Class card = NSClassFromString(cls);
            [_mainTableView registerClass:[card class] forCellReuseIdentifier:cls];
        }
        [_mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_mainTableView setShowsVerticalScrollIndicator:NO];
        @weakify(self)
        _mainTableView.zf_scrollViewDidStopScrollCallback = ^(NSIndexPath * _Nonnull indexPath) {
            @strongify(self)
            if (!self.player.playingIndexPath) {
                if ([[CTFNetReachabilityManager sharedInstance] currentNetStatus] != AFNetworkReachabilityStatusNotReachable) {
                    [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
                }
            }
        };
        _mainTableView.mj_header = [[CTRefreshHeader alloc] initWithRefreshingBlock:^{
            @strongify(self)
            [MobClick event:@"answerlist_refresh"];
            [self refreshData];
        }];
    }
    return _mainTableView;
}

#pragma mark - setupAVVideoPlayer
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
    self.player.shouldAutoPlay = NO;
    self.player.exitFullScreenWhenStop = NO;
    self.player.umengEventPath = @"answerlist";
    
    @weakify(self)
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        @strongify(self)
        NSIndexPath *index = self.player.playingIndexPath;
        CTFAnswerDetailCellLayout *layout = [self.adpater answerModelForIndex:index.row];
        layout.model.video.aleayPlayDuration = 0;
        if(self.player.isFullScreen == NO){
//            [self.player stopCurrentPlayingCell];
        }
    };
    
    self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        @strongify(self)
        self.isFullScreen = isFullScreen;
        [self setNeedsStatusBarAppearanceUpdate];
        if(isFullScreen){
            [MobClick event:@"answerlist_listitemfull"];
        }
        [self stopCurrentAudio];
    };

    self.player.playerPlayTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration){
        @strongify(self)
        NSIndexPath *index = self.player.playingIndexPath;
        CTFAnswerDetailCellLayout *layout = [self.adpater answerModelForIndex:index.row];
        layout.model.video.aleayPlayDuration = currentTime;
    };
    
    //播放状态改变
    self.player.playerPlayStateChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerPlaybackState playState) {
        @strongify(self)
        if (playState == ZFPlayerPlayStatePlaying) {
            [self stopCurrentAudio];
        }
        if (playState== ZFPlayerPlayStatePaused) { //推荐列表项视频暂停
            [MobClick event:@"answerlist_listitempause"];
        }
    };
}

#pragma mark - 我来回答、查看我的回答
- (CTFPublishAnswerView *)publishView {
    if (!_publishView) {
        _publishView = [[CTFPublishAnswerView alloc] initWithFrame:CGRectMake(0, kScreen_Height - kTabBar_Height, kScreen_Width, kTabBar_Height)];
        [_publishView addTapPressed:@selector(publishAnswer) target:self];
    }
    return _publishView;
}

// 播放器的控制层View
- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [ZFPlayerControlView new];
    }
    return _controlView;
}

- (void)dealloc {
    [self stopVideoIfNeed];
    [self removeNotification];
}

@end
