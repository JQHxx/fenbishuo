//
//  UIView+Frame.h
//  HiTao
//
//  Created by hitao on 16/4/14.
//  Copyright © 2016年 hitao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    UIViewCornerTypeLeft,     //左边
    UIViewCornerTypeRight,     //右边
    UIViewCornerTypeTop,      //上边
    UIViewCornerTypeBottom,   //底部
    UIViewCornerTypeAll,      //
} UIViewCornerType;

@interface UIView (Frame)
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;

/*
 * 绘制圆角
 *@param cornerRadius 圆半径
 *@param type
 */
-(void)setBorderWithCornerRadius:(CGFloat)cornerRadius type:(UIViewCornerType)type;

- (void)setBorderWithCornerRadius:(CGFloat)cornerRadius corners:(UIRectCorner)corners;

@end
