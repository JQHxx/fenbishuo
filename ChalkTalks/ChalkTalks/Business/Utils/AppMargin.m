//
//  AppMargin.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "AppMargin.h"

@implementation AppMargin

+ (CGFloat)aspectMarginLeft {
    if (kScreen_Width > 375) {
        return 22;
    }
    return 15.0f;
}

+ (CGFloat)resetHeightAspect:(CGFloat)f {
    if (kScreen_Width > 414) {
        return f * 1.655f;//ipad   w:768
    }
    if (kScreen_Width > 375) {
        return f * 1.104;//iphone 7p w:414
    }
    if (kScreen_Width > 320) {
        return f;//iphone 7  w:375
    }
    return f/1.172f;//iphone 5  w:320
}

+ (CGFloat)resetForAspect:(CGFloat)f {
    if (kScreen_Width >= 375) {
        return f;
    }
    return f/1.172f;
}

+ (CGSize)resetSizeAspect:(CGSize)f {
    if (kScreen_Width >= 375) {
        return f;
    }
    return CGSizeMake(f.width/1.172f, f.height/1.172f);
}

+ (CGRect)resetRectAspect:(CGRect)f {
    if (kScreen_Width >= 375) {
        return f;
    }
    return CGRectMake(f.origin.x/1.172f, f.origin.y/1.172f, f.size.width/1.172f, f.size.height/1.172f);
}

+ (CGSize)bookCoverBigSize {
    return CGSizeMake(105, 118);
}

+ (CGSize)bookCoverListSize {
    return CGSizeMake(74, 83);
}

+ (CGSize)specialCoverSize {
    return CGSizeMake(345, 121);
}

+ (NSInteger)rowCountWithMinSpace:(CGFloat)space width:(CGFloat)width {
    for (NSInteger i = 10; i >= 3; i--) {
        CGFloat gap = (kScreen_Width - 2 * kMarginLeft - i * width) * 1.0f / (i - 1);
        if (gap >= space) {
            return i;
        }
    }
    return 3;
}

+ (BOOL)isNotchScreen {
    if (@available(iOS 11.0, *)) {
        CGFloat a =  [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
        NSLog(@"%f",a);
        if(a > 0) return YES;
    }
    return NO;
}

+ (CGFloat)notchScreenBottom {
    if (@available(iOS 11.0, *)) {
        CGFloat a =  [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
        return a;
    }
    return 0;
}
+ (CGFloat)notchScreenTop {
    if (@available(iOS 11.0, *)) {
        CGFloat a =  [[UIApplication sharedApplication] delegate].window.safeAreaInsets.top;
        return a;
    }
    return 0;
}


+ (FeedImageSize)feedImageDimensions:(NSArray<ImageItemModel*>*)imgs
                          viewWidith:(CGFloat)viewWidth {
    if (imgs.count == 0) {
        return FeedImageSizeMake(0, 0, 0, 0, 0);
    } else if(imgs.count == 1) {
        ImageItemModel *img = imgs[0];
        CGFloat sWidth = img.width;
        CGFloat sHeight = img.height;
        CGFloat itemWidth;
        CGFloat itemHeight;
        if (sWidth == sHeight) {
           itemWidth = 210;
           itemHeight = 210;
        } else if (sWidth==0 || sHeight==0) {
            itemWidth = 0;
            itemHeight = 0;
        } else if (sWidth > sHeight) {
           //横图
            CGFloat scale = [UIScreen mainScreen].scale;
            CGFloat maxW = viewWidth;
            itemWidth = MIN(sWidth/scale, maxW);
            itemHeight = (sHeight / sWidth) * itemWidth;
            CGFloat maxH = 210.0f;
            if (itemHeight > maxH) {
                itemHeight = maxH;
                itemWidth = (sWidth / sHeight) * itemHeight;
            }
        } else {
           //竖图
           itemHeight = 210.0;
           itemWidth = (sWidth / sHeight) * itemHeight;
        }
        return FeedImageSizeMake(1, itemWidth, itemHeight, itemWidth, itemHeight);
    } else if (imgs.count == 2 || imgs.count == 4) {
        int row = 2;
        CGFloat itemWidth = 140.0f;
        CGFloat itemHeight = 140.0f;
        NSInteger col = (imgs.count - 1) / row + 1;
        CGFloat height = itemHeight * col + kMutiImagesSpace * (col-1);
        return FeedImageSizeMake(row, itemWidth, itemHeight, itemWidth*2+kMutiImagesSpace, height);
    } else {
        int row = 3;
        CGFloat itemWidth = floorf(((viewWidth - (row-1)*kMutiImagesSpace) )/3.0);
        CGFloat itemHeight = itemWidth;
        NSInteger col = (imgs.count - 1) / row + 1;
        CGFloat height = itemHeight * col + kMutiImagesSpace * (col-1);
        return FeedImageSizeMake(row, itemWidth, itemHeight, viewWidth, height);
    }
}

#pragma mark 获取feed中视频的高度
+ (CGFloat)getAspectVideoHeightWithWidth:(CGFloat)width height:(CGFloat)height rotation:(NSInteger)rotation {
    CGFloat videoHeight = 0.0;
    double scale1 = (double)width/height;
    double scale2 = (double)height/width;
    if (rotation == 0 || rotation == 180) {
        if (width > height) {
            if (scale1 > 16.0/9.0) {
                videoHeight = FeedVideoHeight;
            } else {
                videoHeight = (kScreen_Width - 2*kMarginLeft) * scale2;
            }
        } else {
            if (scale2 > 4.0/3.5) {
                videoHeight = kPortraitVideoHeight;
            } else {
                videoHeight = (kScreen_Width - 2*kMarginLeft) * scale2;
            }
        }
    } else {
        if (width > height) {
            if (scale1 > 4.0/3.5) {
                videoHeight = kPortraitVideoHeight;
            } else {
                videoHeight = (kScreen_Width - 2*kMarginLeft) * scale2;
            }
        } else {
            if (scale2 < 16.0/9.0) {
                videoHeight = (kScreen_Width - 2*kMarginLeft) * scale2;
            } else {
                videoHeight = FeedVideoHeight;
            }
        }
    }
    return videoHeight;
}

+ (BOOL)isLargeScaleIsWidth:(CGFloat )width height:(CGFloat)height rotation:(NSInteger)rotation {
    double scale1 = (double)width/height;
    double scale2 = (double)height/width;
    if (rotation == 0 || rotation == 180) {
        if (width > height && scale1 > 16.0/9.0) {
            return YES;
        } else {
            return NO;
        }
    } else {
        if (width < height && scale2 > 16.0/9.0) {
            return YES;
        } else {
            return NO;
        }
    }
}

@end
