//
//  CTFPhotosColletionView.m
//  ChalkTalks
//
//  Created by vision on 2020/1/2.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFPhotosColletionView.h"
#import "CTFFeedImageItemCCell.h"
#import "YBImageBrowser.h"
#import "UIResponder+Event.h"

@interface CTFPhotosColletionView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, copy ) NSArray  *photosArray;
@property (nonatomic, copy ) NSString *status;

@end

@implementation CTFPhotosColletionView

-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.minimumInteritemSpacing = kMutiImagesSpace;
        flowLayout.minimumLineSpacing = kMutiImagesSpace;
        self.collectionViewLayout = layout;
        
        self.dataSource = self;
        self.delegate = self;
        self.scrollEnabled = NO;
        self.backgroundColor = [UIColor whiteColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self registerClass:[CTFFeedImageItemCCell class] forCellWithReuseIdentifier:[CTFFeedImageItemCCell identifier]];
    }
    return self;
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.photosArray.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    [collectionView.collectionViewLayout invalidateLayout];
    return 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CTFFeedImageItemCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CTFFeedImageItemCCell identifier] forIndexPath:indexPath];
    ImageItemModel *item = [self.photosArray objectAtIndex:indexPath.row];
    [cell fillCellContent:item w400:self.photosArray.count==1 status:self.status];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isLocal || ![self.status isEqualToString:@"normal"]) {
        return ;
    }
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for(ImageItemModel *item in self.photosArray){
        YBIBImageData *data = [YBIBImageData new];
        data.imageURL = [NSURL safe_URLWithString:[AppUtils imgUrlForBrowse:item.url]];
        [arr addObject:data];
    }
    
    YBImageBrowser *browser = [YBImageBrowser new];
    browser.dataSourceArray = arr;
    browser.currentPage = indexPath.row;
    [browser show];
    
    [self routerEventWithName:kEnterBrowseImageEvent userInfo:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    FeedImageSize imagesSize =  [AppMargin feedImageDimensions:self.photosArray viewWidith:self.isLocal?kScreen_Width-66:kScreen_Width-2*kMarginLeft];
    return CGSizeMake(imagesSize.imgItemWidth, imagesSize.imgItemHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return kMutiImagesSpace;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return kMutiImagesSpace;
}

- (void)fillImagesData:(NSArray *)images status:(NSString *)status{
    self.photosArray = images;
    self.status = status;
    [self reloadData];
}

-(void)setIsLocal:(BOOL)isLocal{
    _isLocal = isLocal;
}


@end
