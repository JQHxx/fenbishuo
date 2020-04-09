//
//  UIImage+HTSize.m
//  HiTao
//
//  Created by hitao4 on 15/9/21.
//  Copyright (c) 2015年 hitao. All rights reserved.
//

#import "UIImage+Size.h"
#import "CTMacro.h"

@implementation UIImage (Size)


- (CGFloat)returnWidthWithScreenHeight{
    
    if (!self) return 0;
    
    return [self returnWidthWithNeedHeight:kScreen_Height];
}

- (CGFloat)returnHeightWithScreenWidth{
    if (!self) return 0;
    return [self returnHeightWithNeedWidth:kScreen_Width];
}

- (CGFloat)returnWidthWithNeedHeight:(CGFloat) needHeight{
    if (!self) return 0;
    
    return floorf([self returnImageSizeForWidth_Height_Proportion] * needHeight);
}

- (CGFloat)returnHeightWithNeedWidth:(CGFloat) needWidth{
    if (!self) return 0;
    
    return floorf([self returnImageSizeForHeight_Width_Proportion] * needWidth);
}

#pragma mark - private method

/**
 *  width / height
 *
 *  @return 宽高比例
 */
- (CGFloat)returnImageSizeForWidth_Height_Proportion{
    return self.size.width / self.size.height;
}

/**
 *  height / width
 *
 *  @return 高宽比例
 */
- (CGFloat)returnImageSizeForHeight_Width_Proportion{
    return self.size.height /  self.size.width;
}

-(UIImage *)compressImageQualityToByte:(NSInteger)maxLength {
    // Compress by quality
    CGFloat compression = 0.1f;
    NSData *data = UIImageJPEGRepresentation(self, compression);
    UIImage *resultImage = [UIImage imageWithData:data];
    if (data.length < maxLength) return resultImage;
    
     // Compress by size
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(self.size.width * sqrtf(ratio)),
                                 (NSUInteger)(self.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, 1.0);
    }
    
   return resultImage;
}

- (UIImage*)compressImageToMaxWidth:(CGFloat)width{
    // Create a graphics image context
    CGFloat scale = width / self.size.width;
    
    CGSize newSize = CGSizeMake(width, scale*self.size.height);
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

#pragma mark--根据给定的大小设置图片
+(UIImage *)drawImageWithName:(NSString *)imgName size:(CGSize)itemSize{
    UIImage *icon = [UIImage imageNamed:imgName];
    UIGraphicsBeginImageContextWithOptions(itemSize, NO,0.0);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [icon drawInRect:imageRect];
    
    icon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return icon;
}


#pragma mark 图片缩处理
+(UIImage *)zipScaleWithImage:(UIImage *)sourceImage{
    //进行图像尺寸的压缩
    CGSize imageSize = sourceImage.size;//取出要压缩的image尺寸
    CGFloat width = imageSize.width;    //图片宽度
    CGFloat height = imageSize.height;  //图片高度
    //1.宽高大于1080(宽高比不按照2来算，按照1来算)
    if (width > 1080 || height > 1080) {
        if (width > height) {
            CGFloat scale = height/width;
            width = 1080;
            height = width*scale;
        } else {
            CGFloat scale = width/height;
            height = 1080;
            width = height*scale;
        }
        //2.宽大于1080高小于1080
    } else if(width > 1080 || height < 1080){
        CGFloat scale = height/width;
        width = 1080;
        height = width*scale;
        //3.宽小于1080高大于1080
    } else if(width < 1080 || height > 1080){
        CGFloat scale = width/height;
        height = 1080;
        width = height*scale;
        //4.宽高都小于1080
    }else{
    }
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [sourceImage drawInRect:CGRectMake(0,0,width,height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
