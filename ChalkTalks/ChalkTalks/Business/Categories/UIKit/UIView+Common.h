//
//  UIView+Common.h
//  HiCalligraphy
//
//  Created by zingwin on 15/11/13.
//  Copyright © 2015年 zwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Common)
- (void)doCircleFrame;
- (void)doNotCircleFrame;
- (void)doBorderWidth:(CGFloat)width color:(UIColor *)color cornerRadius:(CGFloat)cornerRadius;
- (void)setY:(CGFloat)y;
- (void)setX:(CGFloat)x;
- (void)setOrigin:(CGPoint)origin;
- (void)setHeight:(CGFloat)height;
- (void)setWidth:(CGFloat)width;
- (void)setSize:(CGSize)size;
- (CGFloat)maxXOfFrame;
- (UIViewController *)findViewController;

-(void)addTapPressed:(SEL)tapViewPressed target:(id)target;
-(UIImage*)convertViewToImage;
@end
