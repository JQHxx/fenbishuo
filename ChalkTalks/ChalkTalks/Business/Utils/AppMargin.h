//
//  AppMargin.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTModels.h"

#define kResetDimension(f) [AppMargin resetForAspect:f]
#define kResetSize(f) [AppMargin resetSizeAspect:f]
#define kAspectHeight(f) [AppMargin resetHeightAspect:f]

//app 居左间距
#define kMarginLeft 16.0f

//app 居右间距
#define kMarginRight 16.0f

//app 居顶间距
#define kMarginTop 16.0f
#define kAspectMarginLeft [AppMargin aspectMarginLeft]

//app 圆角大小
#define kCornerRadius 5.0f

//app 九宫格图片间距,左右，上下
#define kMutiImagesSpace 2.0f

#define iPadCellLineSpace 15.0f

//feed中视频高度
//横屏
#define FeedVideoHeight (kScreen_Width - 2 * kMarginLeft)*(9.0/16.0) //16:9
//竖屏
#define kPortraitVideoHeight (kScreen_Width - 2 * kMarginLeft)*(4.0/3.5)

typedef struct {
    NSInteger row; //图片行数
    CGFloat imgItemWidth;
    CGFloat imgItemHeight;
    CGFloat imgContainerWidth;
    CGFloat imgContainerHeight;
} FeedImageSize;

CG_INLINE FeedImageSize
FeedImageSizeMake(NSInteger row, CGFloat imgItemWidth, CGFloat imgItemHeight, CGFloat imgContainerWidth, CGFloat imgContainerHeight) {
    FeedImageSize size;
    size.row = row;
    size.imgItemWidth = imgItemWidth;
    size.imgItemHeight = imgItemHeight;
    size.imgContainerWidth = imgContainerWidth;
    size.imgContainerHeight = imgContainerHeight;
    return size;
}

@interface AppMargin : NSObject
+ (CGFloat)resetHeightAspect:(CGFloat)f;
+ (CGFloat)resetForAspect:(CGFloat)f;
+ (CGSize)resetSizeAspect:(CGSize)f;
+ (CGRect)resetRectAspect:(CGRect)f;
+ (CGFloat)aspectMarginLeft;

/// 设备是否为刘海屏
+ (BOOL)isNotchScreen;
+ (CGFloat)notchScreenTop;
+ (CGFloat)notchScreenBottom;

/// 获取feed中图片的尺寸
/// @param imgs 图片数组
/// @param viewWidth 父视图宽
+ (FeedImageSize)feedImageDimensions:(NSArray<ImageItemModel *> *)imgs
                          viewWidith:(CGFloat)viewWidth;

/// 获取feed中视频的高度
/// @param width 视频宽度
/// @param height  视频高度
/// @param rotation 拍摄角度
+ (CGFloat)getAspectVideoHeightWithWidth:(CGFloat)width
                                  height:(CGFloat)height
                                rotation:(NSInteger)rotation;

+ (BOOL)isLargeScaleIsWidth:(CGFloat )width
                     height:(CGFloat)height
                   rotation:(NSInteger)rotation ;
@end
