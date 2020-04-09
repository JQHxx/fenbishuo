//
//  CTFBlockButton.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/5.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    FSCustomButtonImagePositionLeft,//图片在左
    FSCustomButtonImagePositionRight,//图片在右
    FSCustomButtonImagePositionTop,//图片在上
    FSCustomButtonImagePositionBottom,//图片在下
} FSCustomButtonImagePosition;

typedef void (^ButtonBlock)(UIButton *button);

@interface CTFBlockButton : UIButton

@property(nonatomic, copy) ButtonBlock block;

/*UIControlEventTouchUpInside*/
- (void)addTouchUpInsideBlock:(ButtonBlock)block;

/**
 图片位置
 */
@property (nonatomic, assign) FSCustomButtonImagePosition buttonImagePosition;

@end

NS_ASSUME_NONNULL_END
