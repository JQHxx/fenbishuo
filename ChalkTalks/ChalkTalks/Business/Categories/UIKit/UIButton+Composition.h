//
//  UIButton+Composition.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/13.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CTFButtonEdgeInsetsType){
    CTFButtonEdgeInsetsType_ImageTop,       // image在上，label在下
    CTFButtonEdgeInsetsType_ImageLeft,      // image在左，label在右
    CTFButtonEdgeInsetsType_ImageBottom,    // image在下，label在上
    CTFButtonEdgeInsetsType_ImageRight      // image在右，label在左
};

@interface UIButton (Composition)

/**
 * 根据按钮中的现有内容，设置button的titleLabel和imageView的布局样式，及间距
 * @param style titleLabel和imageView的布局样式
 * @param space titleLabel和imageView的间距
 * ⚠️如果对图片或者文字进行更换后，必须再次调用此方法。
 */
- (void)ctfLayoutButtonWithEdgeInsetsStyle:(CTFButtonEdgeInsetsType)style imageTitleSpace:(CGFloat)space;

@end

NS_ASSUME_NONNULL_END
