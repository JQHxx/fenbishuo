//
//  UIImageView+SNWebImage.h
//  StarryNight
//
//  Created by zingwin on 2017/3/22.
//  Copyright © 2017年 zwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (CTWebImage)
- (void)ct_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;


/// UIImageView显示图片加入一个透明度0 --》 1的动画
/// @param url 在线图片url
/// @param placeholder 默认占位图
/// @param animated 是否有动画效果
- (void)ct_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder animated:(BOOL)animated;

@end
