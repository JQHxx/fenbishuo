//
//  UIImage+HTSize.h
//  HiTao
//
//  Created by hitao4 on 15/9/21.
//  Copyright (c) 2015年 hitao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Size)

- (CGFloat)returnWidthWithScreenHeight;

- (CGFloat)returnHeightWithScreenWidth;

- (CGFloat)returnWidthWithNeedHeight:(CGFloat) needHeight;

- (CGFloat)returnHeightWithNeedWidth:(CGFloat) needWidth;

- (UIImage*)compressImageToMaxWidth:(CGFloat)width;
- (UIImage*)compressImageQualityToByte:(NSInteger)maxLength;

/**
 *  根据给定的大小设置图片
 *
 *  @param imgName   图片名称
 *  @param itemSize  图片大小
 *
 *  @return  image
 */
+(UIImage *)drawImageWithName:(NSString *)imgName size:(CGSize)itemSize;



/*
 *压缩图片大小
 *1）宽高均大于1080，取较大值等于1080，较大值等比例压缩
 *2）宽或高一个大于1080，取较大的等于1080，较小的等比压缩
 * 3）宽高均小于1080，压缩比例不变
 */
+(UIImage *)zipScaleWithImage:(UIImage *)sourceImage;

@end
