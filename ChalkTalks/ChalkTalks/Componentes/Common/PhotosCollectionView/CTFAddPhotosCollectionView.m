//
//  CTFAddPhotosCollectionView.m
//  ChalkTalks
//
//  Created by vision on 2020/1/13.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFAddPhotosCollectionView.h"
#import "CTFPublishImageItemCCell.h"
#import "UploadImageFileModel.h"
#import "CTFAliOSSManager.h"
#import "YBImageBrowser.h"
#import "CTFPublishTopicViewModel.h"
#import "UIImage+Size.h"

@interface CTFAddPhotosCollectionView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) CTFPublishTopicViewModel *adpater;
@property (nonatomic,strong) CTFAliOSSManager         *oSSManager;

@end

@implementation CTFAddPhotosCollectionView

-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.minimumInteritemSpacing = kMutiImagesSpace;
        flowLayout.minimumLineSpacing = kMutiImagesSpace;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0); //设置其边界
        self.collectionViewLayout = layout;
        
        self.dataSource = self;
        self.delegate = self;
        self.scrollEnabled = NO;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self registerClass:[CTFPublishImageItemCCell class] forCellWithReuseIdentifier:[CTFPublishImageItemCCell identifier]];
    }
    return self;
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if ([self.adpater numberOfImage]<9) {
        return [self.adpater numberOfImage]+1;
    }else{
        return [self.adpater numberOfImage];
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CTFPublishImageItemCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CTFPublishImageItemCCell identifier] forIndexPath:indexPath];
    cell.isFeedback = self.showText;
    UploadImageFileModel *model = nil;
    if([self.adpater numberOfImage] > indexPath.row){
        model = [self.adpater modelIndex:indexPath.row];
    }
    BOOL showAdd = indexPath.row==[self.adpater numberOfImage] && [self.adpater numberOfImage]<9;
    [cell fillCellContent:model showadd:showAdd];
    @weakify(self);
    cell.deleteSeletedImage = ^(UploadImageFileModel *item){
        @strongify(self);
        [self deleteImage:item];
    };
    cell.reUoloadImage = ^(UploadImageFileModel * _Nonnull item) {
        @strongify(self);
        [self checkUploadImage:item];
    };
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.adpater numberOfImage]==indexPath.row) {
        [self addPhoto];
    }else{
        UploadImageFileModel *citem = [self.adpater modelIndex:indexPath.row];
        if(citem.uploadError) return;

        NSInteger count = [self.adpater numberOfImage];
        NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:count];
        for(NSInteger i = 0; i < count; i++){
            UploadImageFileModel *item = [self.adpater modelIndex:i];
            YBIBImageData *data1 = [YBIBImageData new];
            if (item.imageUrl != nil) {
                data1.imageURL = [NSURL URLWithString:item.imageUrl];
            } else {
                data1.imageData = ^NSData * _Nullable{
                    return item.localImgData;
                };
            }
            [arr addObject:data1];
        }
        YBImageBrowser *browser = [YBImageBrowser new];
        browser.dataSourceArray = arr;
        browser.currentPage = indexPath.row;
        [browser show];   
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.autoZoom) {
        return [CTFPublishImageItemCCell itemSizeWidthPading:10];
    }else{
        return [CTFPublishImageItemCCell itemSize];
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return kMutiImagesSpace;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return kMutiImagesSpace;
}

#pragma mark -- Event response
#pragma mark 删除图片
-(void)deleteImage:(UploadImageFileModel *)model{
    [self.oSSManager cancelUploadByImageId:model.imageId];
    [self.adpater deleteModel:model];
    [self reloadData];
    if (self.autoZoom) {
        NSInteger row = (self.adpater.numberOfImage) / 3 + 1;
        row = MIN(3, row);
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
           make.height.mas_equalTo(row*([CTFPublishImageItemCCell itemSizeWidthPading:10].height+kMutiImagesSpace));
        }];
    }
    if ([self.viewDelegate respondsToSelector:@selector(addPhotosCollectionView:didUploadState:)]) {
        [self.viewDelegate addPhotosCollectionView:self didUploadState:PhotoUploadStateDelete];
    }
}

#pragma mark 上传图片
-(void)addPhoto{
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
           return;
       }

    @weakify(self);
    CTImagePickerController *imgPicker = [[CTImagePickerController alloc]
                                         initWithSelectedCount:[self.adpater numberOfImage]
                                         didSelectImages:^(NSArray<UIImage *> * _Nonnull images) {
        if ([self.viewDelegate respondsToSelector:@selector(addPhotosCollectionView:didUploadState:)]) {
            [self.viewDelegate addPhotosCollectionView:self didUploadState:PhotoUploadStateSelected];
        }
        @strongify(self);
        for (UIImage *image in images) {
            //图片尺寸压缩
            ZLLog(@"image--- w:%.f,h:%.f",image.size.width,image.size.height);
//            UIImage *zipImage = [UIImage zipScaleWithImage:image];
//            ZLLog(@"zipImage--- w:%.f,h:%.f",zipImage.size.width,zipImage.size.height);
            @weakify(self);
            UploadImageFileModel *insertModel = [self.adpater insertPrepareImage:[image fixOrientation]];
            [self.adpater md5ImageComplete:insertModel complete:^{
                @strongify(self);
                [self checkUploadImage:insertModel];
            }];
            [self reloadData];
            if (self.autoZoom) {
                if(images.count > 0){
                    NSInteger row = (self.adpater.numberOfImage) / 3 + 1;
                    row = MIN(3, row);
                    [self mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(row*([CTFPublishImageItemCCell itemSizeWidthPading:10].height+kMutiImagesSpace));
                    }];
                }
            }
        }
     }];
     if (self.nonFullScreen) {
         imgPicker.modalPresentationStyle = UIModalPresentationCustom;
     } else {
         imgPicker.modalPresentationStyle = UIModalPresentationFullScreen;
     }
     [self.findViewController presentViewController:imgPicker animated:YES completion:nil];
}

#pragma mark -- Private methods
#pragma mark 检查上传图片
-(void)checkUploadImage:(UploadImageFileModel*)fileModel{
    @weakify(self);
    fileModel.uploadError = NO;
    [self.adpater prepareUploadImage:fileModel complete:^(BOOL isSuccess) {
        @strongify(self);
        if(isSuccess){
            [self.oSSManager configAliOSSToken];
            if([fileModel.status isEqualToString:@"init"]){
                [self uploadImageToOSS:fileModel];
            }else{
                //这张图片已存在
                ZLLog(@"本张照片已上传 %@", fileModel.imageId);
                if ([self.viewDelegate respondsToSelector:@selector(addPhotosCollectionView:didUploadState:)]) {
                    [self.viewDelegate addPhotosCollectionView:self didUploadState:PhotoUploadStateUploaded];
                }
            }
            [self reloadData];
        }else{
            fileModel.uploadError = YES;
            [self reloadData];
            [kKeyWindow makeToast:self.adpater.errorString];
        }
    }];
}

#pragma mark 上传图片到服务器
-(void)uploadImageToOSS:(UploadImageFileModel*)fileModel{
    NSInteger index = [self.adpater indexOfModel:fileModel];
    if(index == NSNotFound) return;
    @weakify(self);
    [self.oSSManager asyncUploadImageByObjectKey:fileModel.objectKey imageId:fileModel.imageId uploadData:fileModel.localImgData progress:^(CGFloat progress) {
        CTFPublishImageItemCCell *cell = (CTFPublishImageItemCCell*)[self cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [cell uploadProgress:progress];
        if ([self.viewDelegate respondsToSelector:@selector(addPhotosCollectionView:didUploadState:)]) {
            [self.viewDelegate addPhotosCollectionView:self didUploadState:PhotoUploadStateUploading];
        }
    } success:^{
        @strongify(self);
        fileModel.uploadCompleted = YES;
        fileModel.uploadProgress = 1.0f;
        [self reloadData];
        if ([self.viewDelegate respondsToSelector:@selector(addPhotosCollectionView:didUploadState:)]) {
            [self.viewDelegate addPhotosCollectionView:self didUploadState:PhotoUploadStateUploaded];
        }
    } failure:^(NSError * _Nonnull error) {
        @strongify(self);
        fileModel.uploadError = YES;
        [self reloadData];
    }];
}

#pragma mark -- Public methods
#pragma mark 是否上传成功
-(BOOL)uploadAllSucceed{
    return [self.adpater isImageAllUpload];
}

#pragma mark 已上传图片id
-(NSArray *)uploadedImageIds{
    return [self.adpater uploadImageIds];
}

#pragma mark 图片数组
- (NSArray<ImageItemModel *> *)topicUploadedImages{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NSInteger count = [self.adpater numberOfImage];
    for (NSInteger i=0; i<count; i++) {
        UploadImageFileModel *model = [self.adpater modelIndex:i];
        ImageItemModel *item = [[ImageItemModel alloc] init];
        if (!kIsEmptyString(model.imageUrl)) {
            item.isLocal = NO;
            item.url = model.imageUrl;
        }else{
            item.isLocal = YES;
            item.image = model.localImage;
        }
        item.height = model.localImage.size.height;
        item.width = model.localImage.size.width;
        
        [tempArray addObject:item];
    }
    return tempArray;
}

#pragma mark 添加图片
-(void)addPickedPhotos:(NSArray *)pickedImages{
    for (UIImage *image in pickedImages) {
        @weakify(self);
        UploadImageFileModel *insertModel = [self.adpater insertPrepareImage:[image fixOrientation]];
        [self.adpater md5ImageComplete:insertModel complete:^{
            @strongify(self);
            [self checkUploadImage:insertModel];
        }];
        [self reloadData];
    }
}

- (void)addImageItems:(NSArray<ImageItemModel *> *)items {
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    NSMutableArray *uploadedImages = [[NSMutableArray alloc] init];
    for (ImageItemModel *item in items) {
        if (item.imgId == 0) {
            [tempArr addObject:item.image];
        } else {
            [uploadedImages addObject:item];
        }
    }
    [self.adpater addImageItems:uploadedImages];
    if (tempArr.count > 0) {
        [self addPickedPhotos:tempArr];
    }
}

#pragma mark -- Setters
#pragma mark 是否显示文字
-(void)setShowText:(BOOL)showText{
    _showText = showText;
    [self reloadData];
}

-(void)setAutoZoom:(BOOL)autoZoom{
    _autoZoom = autoZoom;
}

#pragma mark -- Getters
-(CTFPublishTopicViewModel *)adpater{
    if (!_adpater) {
        _adpater = [[CTFPublishTopicViewModel alloc] init];
    }
    return _adpater;
}

-(CTFAliOSSManager *)oSSManager{
    if (!_oSSManager) {
        _oSSManager = [[CTFAliOSSManager alloc] init];
    }
    return _oSSManager;
}

@end
