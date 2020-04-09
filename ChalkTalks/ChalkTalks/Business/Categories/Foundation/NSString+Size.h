//
//  NSString+Size.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/19.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Size)
/**
 根据字体、行数、行间距和指定的宽度constrainedWidth计算文本占据的size
 @param font 字体
 @param numberOfLines 显示文本行数，值为0不限制行数
 @param lineSpacing 行间距
 @param constrainedWidth 文本指定的宽度
  @return 返回文本占据的size
 */
- (CGSize)ctTextSizeWithFont:(UIFont*)font
             numberOfLines:(NSInteger)numberOfLines
               lineSpacing:(CGFloat)lineSpacing
          constrainedWidth:(CGFloat)constrainedWidth;

/**
 根据字体、行数、行间距和指定的宽度constrainedWidth计算文本占据的size
 @param font 字体
 @param numberOfLines 显示文本行数，值为0不限制行数
 @param constrainedWidth 文本指定的宽度
 @return 返回文本占据的size
 */
- (CGSize)ctTextSizeWithFont:(UIFont*)font
             numberOfLines:(NSInteger)numberOfLines
          constrainedWidth:(CGFloat)constrainedWidth;

/// 计算字符串长度（一行时候）
- (CGSize)ctTextSizeWithFont:(UIFont*)font
                limitWidth:(CGFloat)maxWidth;

- (CGSize)ctTextSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;



/**
 *  动态确定文本的宽高
 *
 *  @param size 宽高限制，用于计算文本绘制时占据的矩形块。
 *  @param font 字体
 *
 *  @return 文本绘制所占据的矩形空间
 */
- (CGSize)boundingRectWithSize:(CGSize)size withTextFont:(UIFont *)font;

- (CGSize)boundingRectWithSize:(CGSize)size lineSpacing:(CGFloat)lineSpacing textFont:(UIFont *)font;


@end

NS_ASSUME_NONNULL_END
