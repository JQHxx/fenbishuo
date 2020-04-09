//
//  CTFPickVideoCoverVC.m
//  ChalkTalks
//
//  Created by zingwin on 2020/1/9.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFPickVideoCoverVC.h"
#import "CTFVideoPickImageCCell.h"
#import "NSURL+Ext.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import "CTFVideoImagesSlice.h"
#import "NSArray+Safety.h"

@interface CTFPickVideoCoverVC ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic,strong) UIImageView *coverImageView;
@property(nonatomic,strong) UILabel *tipsLabel;
@property(nonatomic,strong) UICollectionView *waitImagesPickView;
@property(nonatomic,strong) NSURL *videoPathURL;

@property(nonatomic,strong) CTFVideoImagesSlice *videoSlice;
@property(nonatomic,strong) MBProgressHUD *HUB;
@property(nonatomic,strong) PagingModel *page;

@property(nonatomic,strong) NSMutableArray *allKeyTimes;
@end

@implementation CTFPickVideoCoverVC
{
    NSInteger selIndex;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"选择封面";
    self.rightImageName = @"pick_videocover_confrim";
    [self.rightBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(82, 32));
    }];
    
    NSString *videoPath = [self.schemaArgu safe_stringForKey:@"videoPath"];
    selIndex = [self.schemaArgu safe_integerForKey:@"index"];
    self.videoPathURL = [NSURL safe_URLWithString:videoPath];
    ZLLog(@"videoPathURL:%@",self.videoPathURL);

    [self setupUI];
    [self setupUILayout];
    [self initVideoPage];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)rightNavigationItemAction{
    CTFVideoImageModel *tar = nil;
    for(CTFVideoImageModel *item in self.allKeyTimes){
        if(item.isSelected){
            tar = item;
            break;
        }
    }
    if(self.pickedVideoCover){
        self.pickedVideoCover(tar);
    }
    
    [self leftNavigationItemAction];
}

-(void)dealloc{
    [self.videoSlice cancelImageGeneration];
    self.videoSlice = nil;
    self.HUB = nil;
}

#pragma mark - Data
-(void)initVideoPage{
    self.HUB = [MBProgressHUD ctfShowLoading:self.view title:@""];
    
    self.videoSlice = [[CTFVideoImagesSlice alloc] initWithVideoUrl:self.videoPathURL];
    NSArray *arr = [self.videoSlice curVideoSliceModes];
    if(!_allKeyTimes){
        _allKeyTimes = [[NSMutableArray alloc] init];
    }
    if(!_page){
        _page = [[PagingModel alloc] init];
    }
    [self.allKeyTimes safe_addObjectsFromArray:arr];
    CTFVideoImageModel *item =[self.allKeyTimes safe_objectAtIndex:selIndex];
    item.isSelected = YES;
    _page.total = self.allKeyTimes.count;
    [self.waitImagesPickView reloadData];
    
    @weakify(self);
    if(selIndex){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(!self)return;
            @strongify(self);
             [self.waitImagesPickView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self->selIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        });
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(!self)return;
        @strongify(self);
        [self.HUB hideAnimated:YES];
    });
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.allKeyTimes count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CTFVideoPickImageCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CTFVideoPickImageCCell identifier] forIndexPath:indexPath];
    
    CTFVideoImageModel *item = [self.allKeyTimes safe_objectAtIndex:indexPath.row];
    [cell fillContentView:item];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self curSelectIndex:indexPath.row];
    [self.waitImagesPickView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    CTFVideoImageModel *item = [self.allKeyTimes safe_objectAtIndex:indexPath.row];
    if(item.cropImage == nil){
        @weakify(self);
        @weakify(item);
        [self.videoSlice asyncRequestVideoImage:item complete:^{
            if(!self || !item)return;
            @strongify(self);
            @strongify(item);
            CTFVideoPickImageCCell *c = (CTFVideoPickImageCCell*)[self.waitImagesPickView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:item.index inSection:0]];
            [c fillContentView:item];
            if(item.isSelected){
                [self curSelectIndex:item.index];
            }
        }];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(nonnull UICollectionViewCell *)cell forItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
}

-(void)curSelectIndex:(NSInteger)index{
    for(int i = 0; i < self.allKeyTimes.count; i++){
        CTFVideoImageModel *item = [self.allKeyTimes safe_objectAtIndex:i];
        if(index == i){
            item.isSelected = YES;
            self.coverImageView.image = item.cropImage;
            self.tipsLabel.text = item.cropImage ? @"已选封面" : @"";
        }else{
            item.isSelected = NO;
        }
    }
}

#pragma mark - UI
-(void)setupUI{
    [self.view addSubview:self.coverImageView];
    [self.view addSubview:self.tipsLabel];
    [self.view addSubview:self.waitImagesPickView];
}

-(UIImageView*)coverImageView{
    if(!_coverImageView){
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.clipsToBounds = YES;
        _coverImageView.layer.cornerRadius = kCornerRadius;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _coverImageView;
}
-(UILabel*)tipsLabel{
    if(!_tipsLabel){
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.font = kSystemFont(14);
        _tipsLabel.textColor = [UIColor ctColor66];
    }
    return _tipsLabel;
}

-(UICollectionView*)waitImagesPickView{
    if(!_waitImagesPickView){
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0); //设置其边界
        flowLayout.itemSize = [CTFVideoPickImageCCell itemSize];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _waitImagesPickView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [_waitImagesPickView registerClass:[CTFVideoPickImageCCell class] forCellWithReuseIdentifier:[CTFVideoPickImageCCell identifier]];
        _waitImagesPickView.dataSource = self;
        _waitImagesPickView.delegate = self;
        [_waitImagesPickView setShowsHorizontalScrollIndicator:NO];
        _waitImagesPickView.backgroundColor = [UIColor whiteColor];
    }
    return _waitImagesPickView;
}

-(void)setupUILayout{
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(kMarginLeft);
        make.right.mas_offset(-kMarginRight);
        make.top.mas_equalTo(kNavBar_Height+30);
        make.height.mas_equalTo(kScreen_Height-kNavBar_Height-30-60-[CTFVideoPickImageCCell itemSize].height);
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.coverImageView.mas_bottom).offset(10);
    }];
    
    [self.waitImagesPickView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo([CTFVideoPickImageCCell itemSize].height);
        make.bottom.equalTo(self.view.mas_bottom).offset(-[AppMargin notchScreenBottom]);
    }];
}
@end
