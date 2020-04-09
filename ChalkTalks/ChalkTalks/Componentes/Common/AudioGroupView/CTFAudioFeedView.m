//
//  CTFAudioFeedView.m
//  ChalkTalks
//
//  Created by vision on 2020/1/13.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFAudioFeedView.h"
#import "CTFAudioCollectionViewFlowLayout.h"
#import "CTFAudioCollectionViewCell.h"
#import "CTFAudioPlayerManager.h"
#import "CTFAudioBrowseView.h"
#import "CTFStatusErrorView.h"
#import "AnswersModel.h"
#import "YBImageBrowser.h"
#import "UIResponder+Event.h"
#import "NSURL+Ext.h"
#import "YBIBDataMediator.h"

@interface CTFAudioFeedView ()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,YBImageBrowserDelegate,CTFAudioBrowseViewDelegate>{
    BOOL  isClick;
    BOOL  isTimering;
}

@property (nonatomic,strong) UICollectionView    *imagesScrollView;
@property (nonatomic,strong) CTFAudioCollectionViewFlowLayout *flowLayout;
@property (nonatomic,assign) NSInteger           totalItems;// item 的数量
@property (nonatomic,strong) UILabel             *countLab;
@property (nonatomic,strong) UILabel             *largeCountLab;
@property (nonatomic,strong) CTFAudioBrowseView *browseView;          //预览界面
@property (nonatomic,strong) CTFAudioPlayView   *currentPlayView;     //当前播放动画
@property (nonatomic,strong) CTFStatusErrorView *statusView;

@property (nonatomic,assign) NSInteger           currentIndex;
@property (nonatomic, copy ) NSArray<AudioImageModel *>*audioImages;
@property (nonatomic,strong) NSIndexPath        *myIndexPath;
@property (nonatomic,strong) NSIndexPath        *playingIndexPath;    //正在播放的位置

@property (nonatomic,strong) dispatch_source_t  timer;                //计时器
@property (nonatomic,assign) BOOL               isBrowsing;           //浏览模式

@end

@implementation CTFAudioFeedView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlayerDidPlayFinished) name:kAudioPlayFinishedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAudioPlayAndAutoScroll) name:kAudioStopPlayNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioPlayStartTimer) name:kAudioPlayStartTimerNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAudioPlayAndAutoScroll) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAudioPlayAndAutoScroll) name:AVAudioSessionInterruptionNotification object:nil];
    }
    return self;
}

#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.totalItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CTFAudioCollectionViewCell *myCell = [collectionView dequeueReusableCellWithReuseIdentifier:[CTFAudioCollectionViewCell identifier] forIndexPath:indexPath];
    // 利用取余运算，使得图片数组里面的图片，是一组一组的排列的。
    NSInteger itemIndex = [self pageControlIndexWithCurrentCellIndex:indexPath.item];
    AudioImageModel *model = [self.audioImages safe_objectAtIndex:itemIndex];
    [myCell displayCellWithModel:model];
    
    myCell.playView.tag = itemIndex;
    [myCell.playView addTapPressed:@selector(playAudioAction:) target:self];
    return myCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger itemIndex = [self pageControlIndexWithCurrentCellIndex:indexPath.item];
    ZLLog(@"didSelectItemAtIndex--index:%ld",itemIndex);
    isClick = YES;
    
    self.browseView.audioImages = self.audioImages;
    self.browseView.itemIndex = itemIndex;
    [kKeyWindow addSubview:self.browseView];
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for(AudioImageModel *item in self.audioImages){
        YBIBImageData *data = [YBIBImageData new];
        data.imageURL = [NSURL safe_URLWithString:[AppUtils imgUrlForBrowse:item.url]];
        //图片缩放回调
        data.imageDidZoomBlock = ^(YBIBImageData * _Nonnull imageData, YBIBImageScrollView * _Nonnull scrollView) {
            if ([CTFAudioPlayerManager sharedCTFAudioPlayerManager].isPlaying) {
                if (scrollView.zoomScale == 1.00) { //缩放回到初始位置
                    self.autoScroll = YES;
                } else {
                    self.autoScroll = NO;
                }
            }
        };
        [arr addObject:data];
    }
    
    YBImageBrowser *browser = [YBImageBrowser new];
    browser.dataSourceArray = arr;
    browser.showAnimation = NO;
    browser.currentPage = itemIndex;
    browser.delegate = self;
    browser.distanceBetweenPages = 0;
    [browser showToView:self.browseView];
    
    [self routerEventWithName:kEnterBrowseImageEvent userInfo:@{kCellIndexPathKey:self.myIndexPath}];
    
    //是否显示播放动画
    BOOL isPlaying = [CTFAudioPlayerManager sharedCTFAudioPlayerManager].isPlaying;
    [self.browseView playAudioWithShowAnimation:isPlaying];
    
    self.isBrowsing = YES;
    
    //更新当前播放视图
    self.currentIndex = itemIndex;
    [self updateCurrentPlayView];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.audioImages.count==0) {
        return;
    }
    NSInteger itemIndex = [self pageIndex];
    NSInteger index = [self pageControlIndexWithCurrentCellIndex:itemIndex];
    if (index==self.currentIndex) {
        return;
    }
    self.currentIndex = index;
    if (self.audioImages.count>9) {
        self.largeCountLab.text = [NSString stringWithFormat:@"%ld/%ld",self.currentIndex+1,self.audioImages.count];
    } else {
        self.countLab.text = [NSString stringWithFormat:@"%ld/%ld",self.currentIndex+1,self.audioImages.count];
    }
    ZLLog(@"scrollViewDidScroll---index:%ld",self.currentIndex);
}

#pragma mark 开始滑动
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self didBeginScroll];
}

#pragma mark 监听滚动停止
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
    if (scrollToScrollStop) {
        [self didStopScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        BOOL dragToDragStop = scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
        if (dragToDragStop) {
            [self didStopScroll];
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if (self.autoScroll) {
        [self startPlayAudio];
    }
}

#pragma mark YBImageBrowserDelegate
#pragma mark 页码变化
- (void)yb_imageBrowser:(YBImageBrowser *)imageBrowser pageChanged:(NSInteger)page data:(id<YBIBDataProtocol>)data{
    ZLLog(@"yb_imageBrowser---pageChanged:%ld",page);
    if (!isClick) { //预览滑动时停止播放
        if (page==self.currentIndex) {
            return;
        }
        [self.browseView stopCurrentAudioPlay];
        [self stopPlayAudio];
    } else {
        isClick = NO;
    }
    self.currentIndex = page;
    self.browseView.itemIndex = page;
    
    //跟随预览滑动
    [self updateUI];
    [self updateCurrentPlayView];
}

#pragma mark 开始转场
-(void)yb_imageBrowser:(YBImageBrowser *)imageBrowser beginTransitioningWithIsShow:(BOOL)isShow{
    if (!isShow) {
        //同步播放
        [self updateUI];
        if ([CTFAudioPlayerManager sharedCTFAudioPlayerManager].isPlaying) {
            NSInteger tagetIndex = [self pageIndex];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tagetIndex inSection:0];
            CTFAudioCollectionViewCell *cell = (CTFAudioCollectionViewCell *)[self.imagesScrollView cellForItemAtIndexPath:indexPath];
            [cell.playView animationPlay];
            self.currentPlayView = cell.playView;
            [self startTimeCount];
            [self routerEventWithName:kExitBrowseImageEvent userInfo:@{kCellIndexPathKey:self.myIndexPath}];
            self.autoScroll = YES;
        }
        self.isBrowsing = NO;
        [self.browseView removeFromSuperview];
        self.browseView = nil;
    }
}

#pragma mark 开始拖动
- (void)yb_imageBrowserWillBeginDragging:(YBImageBrowser *)imageBrowser{
    [self didBeginScroll];
}

#pragma mark 停止滚动
- (void)yb_imageBrowserDidEndScroll:(YBImageBrowser *)imageBrowser{
    [self didStopScroll];
}

#pragma mark -- CTFAudioBrowseViewDelegate
#pragma mark 播放状态改变
-(void)audioBrowseView:(CTFAudioBrowseView *)browseView didPlayAudio:(BOOL)isPlaying{
    if (isPlaying) {
        [self.currentPlayView animationPlay];
        self.autoScroll = YES;
    } else {
        [self stopPlayAudio];
    }
}

#pragma mark -- Notification
#pragma mark 播放完成
- (void)audioPlayerDidPlayFinished{
    [self stopPlayAudio];
    if (self.browseView) {
        [self.browseView stopCurrentAudioPlay];
    }
    if (self.autoScroll) {
        [self scrollToNextPage];
    }
}

#pragma mark 开始计时
- (void)audioPlayStartTimer{
    [self.currentPlayView animationPlay];
    [self startTimeCount];
}

#pragma mark 停止播放并停止自动播放
- (void)stopAudioPlayAndAutoScroll{
    [self stopPlayAudio];
    if (self.browseView) {
        [self.browseView stopCurrentAudioPlay];
    }
    self.autoScroll = NO;
}

#pragma mark - Public methods
#pragma mark 填充数据
-(void)fillAudioImageData:(NSArray<AudioImageModel *> *)audioImages indexPath:(NSIndexPath *)indexPath currentIndex:(NSInteger)currentIndex status:(NSString *)status{
    if ([status isEqualToString:@"normal"]) {
        self.imagesScrollView.hidden = self.largeCountLab.hidden = self.countLab.hidden =  NO;
        self.statusView.hidden = YES;
        
        self.audioImages = audioImages;
        self.myIndexPath = indexPath;
        self.totalItems = audioImages.count*100;
        if (audioImages.count > 1) {
            self.imagesScrollView.scrollEnabled = YES;
        } else {
            self.imagesScrollView.scrollEnabled = NO;
        }
        self.currentIndex = currentIndex;
        if (self.audioImages.count>1) {
            if (self.audioImages.count>9) {
                self.largeCountLab.hidden = NO;
                self.countLab.hidden = YES;
            } else {
                self.countLab.hidden = NO;
                self.largeCountLab.hidden = YES;
            }
        } else {
            self.countLab.hidden = self.largeCountLab.hidden = YES;
        }
        
        [self updateUI];
        [self.imagesScrollView reloadData];
    } else {
        self.imagesScrollView.hidden = self.largeCountLab.hidden = self.countLab.hidden =  YES;
        self.statusView.hidden = NO;
        
        AudioImageModel *model = [self.audioImages safe_objectAtIndex:0];
        [self.statusView fillErrorViewWithCoverImage:model.url status:status];
    }
}

#pragma mark -- Event response
#pragma mark 播放音频
- (void)playAudioAction:(UITapGestureRecognizer *)sender {
    [self routerEventWithName:kAudioFeedPlayEvent userInfo:@{kCellIndexPathKey:self.myIndexPath}];
    AudioImageModel *model = [self.audioImages safe_objectAtIndex:sender.view.tag];
    CTFAudioPlayView *playView = (CTFAudioPlayView *)sender.view;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
    NSDictionary *audioDict = model.audio;
    if (self.currentPlayView&&playView == self.currentPlayView) { //当前音频
        if ([CTFAudioPlayerManager sharedCTFAudioPlayerManager].isPlaying) {
            [self stopPlayAudio];
        } else {
            [[CTFAudioPlayerManager sharedCTFAudioPlayerManager] playAudioWithUrl:[audioDict safe_stringForKey:@"url"]];
            [playView startLoading];
            self.playingIndexPath = indexPath;
            self.autoScroll = YES;
        }
    } else {
        [[CTFAudioPlayerManager sharedCTFAudioPlayerManager] playAudioWithUrl:[audioDict safe_stringForKey:@"url"]];
        [playView startLoading];
        self.playingIndexPath = indexPath;
        self.currentPlayView = playView;
        self.autoScroll = YES;
    }
}

#pragma mark -- Private methods
#pragma mark 获取当前页
- (NSInteger)pageControlIndexWithCurrentCellIndex:(NSInteger)index {
    return (NSInteger)index % self.audioImages.count;
}

#pragma mark
- (NSInteger)pageIndex{
    NSInteger index = (_imagesScrollView.contentOffset.x + _flowLayout.itemSize.width * 0.5) / _flowLayout.itemSize.width;
    return MAX(0, index);
}

#pragma mark 获取当前播放视图
- (void)updateCurrentPlayView {
    NSInteger tagetIndex = [self pageIndex];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tagetIndex inSection:0];
    CTFAudioCollectionViewCell *cell = (CTFAudioCollectionViewCell *)[self.imagesScrollView cellForItemAtIndexPath:indexPath];
    self.currentPlayView = cell.playView;
}

#pragma mark 开始计时
- (void)startTimeCount {
    if (self.currentPlayView&&!isTimering) {
        NSInteger aDuration = [self.currentPlayView.audio safe_integerForKey:@"duration"]/1000.0+0.5;
        NSInteger currentTime = [CTFAudioPlayerManager sharedCTFAudioPlayerManager].playTime;
        if (_timer == nil) {
            __block NSInteger timeout = (aDuration-currentTime)>0?(aDuration-currentTime):aDuration; // 倒计时时间
            if (timeout!=0) {
                kSelfWeak;
                isTimering = YES;
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
                dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC,  0); //每秒执行
                dispatch_source_set_event_handler(_timer, ^{
                    if (timeout < 0) { //  当倒计时结束时做需要的操作:
                        dispatch_source_cancel(weakSelf.timer);
                        weakSelf.timer = nil;
                        self->isTimering = NO;
                    } else {
                        NSInteger seconds = timeout % (aDuration+1);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.currentPlayView.timeCount = seconds;
                        });
                        timeout--;
                    }
                });
                dispatch_resume(_timer);
            }
        }
    }
}

#pragma mark 停止计时
- (void)endTimeCount {
    if (self.currentPlayView) {
        if(self.timer){
            dispatch_source_cancel(_timer);
            _timer = nil;
        }
        isTimering = NO;
        NSInteger timeCount = [self.currentPlayView.audio safe_integerForKey:@"duration"]/1000.0+0.5;
        self.currentPlayView.timeCount = timeCount;
    }
}

#pragma mark 初始化界面
- (void)setupUI {
    [self addSubview:self.imagesScrollView];
    [self.imagesScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(self.mas_width);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(self.mas_width).multipliedBy(4.0/3.5);
    }];
    
    [self addSubview:self.countLab];
    [self.countLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.imagesScrollView.mas_top).offset(16);
        make.right.mas_equalTo(self.imagesScrollView.mas_right).offset(-15);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(28);
    }];
    
    [self addSubview:self.largeCountLab];
    [self.largeCountLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.imagesScrollView.mas_top).offset(16);
        make.right.mas_equalTo(self.imagesScrollView.mas_right).offset(-15);
        make.width.mas_equalTo(55);
        make.height.mas_equalTo(28);
    }];
    self.countLab.hidden = self.largeCountLab.hidden = YES;
    
    [self addSubview:self.statusView];
    [self.statusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    self.statusView.hidden = YES;
}

#pragma mark 更新UI
- (void)updateUI{
    NSInteger page = self.totalItems*0.5;
    if (self.currentIndex>0) {
        page += self.currentIndex;
    }
    if (self.imagesScrollView.width<0.01) {
        self.imagesScrollView.frame = CGRectMake(0, 0, kScreen_Width-kMarginLeft*2, (kScreen_Width-2*kMarginLeft)*(4.0/3.5));
    }
    [self.imagesScrollView setContentOffset:CGPointMake((kScreen_Width-2*kMarginLeft)*page, 0)];
    if (self.audioImages.count>9) {
        self.largeCountLab.text = [NSString stringWithFormat:@"%ld/%ld",self.currentIndex+1,self.audioImages.count];
    } else {
        self.countLab.text = [NSString stringWithFormat:@"%ld/%ld",self.currentIndex+1,self.audioImages.count];
    }
}

#pragma mark 开始播放
- (void)startPlayAudio{
    [self stopPlayAudio];
    AudioImageModel *model = [self.audioImages safe_objectAtIndex:self.currentIndex];
    NSInteger tagetIndex = [self pageIndex];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:tagetIndex inSection:0];
    self.playingIndexPath = indexPath;
    CTFAudioCollectionViewCell *cell = (CTFAudioCollectionViewCell *)[self.imagesScrollView cellForItemAtIndexPath:indexPath];
    if (!kIsEmptyObject(model.audio)&&model.audio.count>0) {
        NSDictionary *audioDict = model.audio;
        [[CTFAudioPlayerManager sharedCTFAudioPlayerManager] playAudioWithUrl:[audioDict safe_stringForKey:@"url"]];
        if (!self.isBrowsing) {
            [cell.playView startLoading];
        }
        self.currentPlayView = cell.playView;
    }else {
        [self performSelector:@selector(delayToScroll) withObject:nil afterDelay:2];
    }
    [self routerEventWithName:kAudioImageScrollEvent userInfo:@{@"currentIndex":[NSNumber numberWithInteger:self.currentIndex],kCellIndexPathKey:self.myIndexPath}];
}

#pragma mark 延时滚动
- (void)delayToScroll{
    if (self.autoScroll) {
        [self scrollToNextPage];
    }
}

#pragma mark 停止播放
- (void)stopPlayAudio {
    [[CTFAudioPlayerManager sharedCTFAudioPlayerManager] endPlay];
    [self endTimeCount];
    //停止播放
    if (self.currentPlayView) {
        [self.currentPlayView animationStop];
        self.currentPlayView = nil;
    }
    if (self.playingIndexPath) {
        self.playingIndexPath = nil;
    }
}

#pragma mark 图片滚动
- (void)scrollToNextPage{
    if (self.audioImages&&self.audioImages.count>0) {
        NSInteger currentIndex = [self pageIndex];
        NSInteger itemIndex = [self pageControlIndexWithCurrentCellIndex:currentIndex];
        if (itemIndex+1 == self.audioImages.count) {
            self.autoScroll = NO;
            return;
        }
        NSInteger targetIndex = currentIndex + 1;
        self.currentIndex ++ ;
        [self.imagesScrollView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        
        if (self.browseView) {
            for (UIView *aView in self.browseView.subviews) {
                if ([aView isKindOfClass:[YBImageBrowser class]]) {
                    YBImageBrowser *browser = (YBImageBrowser *)aView;
                    browser.showAnimation = YES;
                    browser.currentPage = self.currentIndex;
                    break;
                }
            }
            self.browseView.itemIndex = self.currentIndex;
            [self.browseView startLoading];
        }
    }
}

#pragma mark 开始滑动
- (void)didBeginScroll{
    AudioImageModel *model = [self.audioImages safe_objectAtIndex:self.currentIndex];
    if (kIsEmptyObject(model.audio)) {
        if (self.autoScroll) {
            self.autoScroll = NO;
        }
    }
}

#pragma mark 停止滑动
- (void)didStopScroll{
    if (self.playingIndexPath) {
        NSInteger index = [self pageControlIndexWithCurrentCellIndex:self.playingIndexPath.row];
        if (self.currentIndex!=index) {
            [self stopPlayAudio];
            self.autoScroll = NO;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayToScroll) object:nil];
        }
        [self updateCurrentPlayView];
    }
    [self routerEventWithName:kAudioImageScrollEvent userInfo:@{@"currentIndex":[NSNumber numberWithInteger:self.currentIndex],kCellIndexPathKey:self.myIndexPath}];
}

#pragma mark -- Setters
#pragma mark 自动滚动
- (void)setAutoScroll:(BOOL)autoScroll{
    _autoScroll = autoScroll;
}

#pragma mark -- Getters
#pragma mark 滚动图片
- (UICollectionView *)imagesScrollView {
    if (!_imagesScrollView) {
        CTFAudioCollectionViewFlowLayout *flowLayout = [[CTFAudioCollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(kScreen_Width-32, (kScreen_Width-32)*(4.0/3.5));
        self.flowLayout = flowLayout;
        _imagesScrollView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _imagesScrollView.pagingEnabled = YES;
        _imagesScrollView.showsHorizontalScrollIndicator = NO;
        _imagesScrollView.delegate = self;
        _imagesScrollView.dataSource = self;
        _imagesScrollView.backgroundColor = [UIColor whiteColor];
        _imagesScrollView.scrollsToTop = NO;
        [_imagesScrollView registerClass:[CTFAudioCollectionViewCell class] forCellWithReuseIdentifier:[CTFAudioCollectionViewCell identifier]];
    }
    return _imagesScrollView;
}

#pragma mark 数字
- (UILabel *)countLab {
    if (!_countLab) {
        _countLab = [[UILabel alloc] init];
        _countLab.textAlignment = NSTextAlignmentCenter;
        _countLab.backgroundColor = UIColorFromHEXWithAlpha(0x000000,0.2);
        _countLab.textColor = [UIColor whiteColor];
        _countLab.layer.cornerRadius = 14;
        _countLab.clipsToBounds = YES;
        _countLab.font = [UIFont regularFontWithSize:14];
    }
    return _countLab;
}

#pragma mark 大数字
- (UILabel *)largeCountLab {
    if (!_largeCountLab) {
        _largeCountLab = [[UILabel alloc] init];
        _largeCountLab.textAlignment = NSTextAlignmentCenter;
        _largeCountLab.backgroundColor = UIColorFromHEXWithAlpha(0x000000,0.2);
        _largeCountLab.textColor = [UIColor whiteColor];
        _largeCountLab.layer.cornerRadius = 14;
        _largeCountLab.clipsToBounds = YES;
        _largeCountLab.font = [UIFont regularFontWithSize:14];
    }
    return _largeCountLab;
}

- (CTFAudioBrowseView *)browseView {
    if (!_browseView) {
        _browseView = [[CTFAudioBrowseView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _browseView.browseDelegate = self;
    }
    return _browseView;
}

- (CTFStatusErrorView *)statusView {
    if (!_statusView) {
        _statusView = [[CTFStatusErrorView alloc] init];
    }
    return _statusView;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAudioPlayFinishedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAudioStopPlayNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAudioPlayStartTimerNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
}

@end
