//
//  UIImageView+SNWebImage.m
//  StarryNight
//
//  Created by zingwin on 2017/3/22.
//  Copyright © 2017年 zwin. All rights reserved.
//

#import "UIImageView+CTWebImage.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation UIImageView (CTWebImage)
- (void)ct_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    __block UIImageView *weakSelf = self;
    [self sd_setImageWithURL:url
            placeholderImage:placeholder
                     options:SDWebImageRetryFailed
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                       weakSelf.alpha = 1.f;
                   }];
}

- (void)ct_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder animated:(BOOL)animated {
    __block UIImageView *weakSelf = self;
    [self sd_setImageWithURL:url
            placeholderImage:placeholder
                     options:SDWebImageRetryFailed
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                       if (animated && cacheType == SDImageCacheTypeNone && image != nil) {
                           weakSelf.alpha = 0.0;
                           [UIView transitionWithView:weakSelf
                                             duration:0.5f
                                              options:UIViewAnimationOptionTransitionCrossDissolve
                                           animations:^{
                                               weakSelf.alpha = 1.f;
                                           } completion:NULL];
                       } else {
                           self.alpha = 1.f;
                       }
                   }];
}

//- (void)ct_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder radius:(CGFloat)radius {
//    __block UIImageView *weakSelf = self;
//    [self sd_setImageWithURL:url placeholderImage:placeholder completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//        self.image = image;
//    }];
//
//
//}

@end
