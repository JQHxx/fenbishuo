//
//  CTFAddPhotosCollectionView.h
//  ChalkTalks
//
//  Created by vision on 2020/1/13.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    PhotoUploadStateSelected,
    PhotoUploadStateUploading,
    PhotoUploadStateUploaded,
    PhotoUploadStateDelete,
} PhotoUploadState;

NS_ASSUME_NONNULL_BEGIN

@class CTFAddPhotosCollectionView, CTFPublishTopicViewModel;
@protocol CTFAddPhotosCollectionViewDelegate <NSObject>

@optional
- (void)addPhotosCollectionView:(CTFAddPhotosCollectionView *)collectionView didUploadState:(PhotoUploadState )state;

@end

@interface CTFAddPhotosCollectionView : UICollectionView

@property (nonatomic,assign) BOOL    showText;     //是否显示“最多上传9张”
@property (nonatomic,assign) BOOL    autoZoom;
@property (nonatomic,assign) BOOL    nonFullScreen;
@property (nonatomic, weak ) id<CTFAddPhotosCollectionViewDelegate>viewDelegate;

//添加图片
-(void)addPickedPhotos:(NSArray *)pickedImages;

/// 修改图文
/// @param items 服务端images
- (void)addImageItems:(NSArray<ImageItemModel *> *)items;

//是否上传完成
-(BOOL)uploadAllSucceed;

//已上传图片id
-(NSArray *)uploadedImageIds;

//图片数组
- (NSArray <ImageItemModel *> *)topicUploadedImages;

- (CTFPublishTopicViewModel *)adpater;

@end

NS_ASSUME_NONNULL_END
