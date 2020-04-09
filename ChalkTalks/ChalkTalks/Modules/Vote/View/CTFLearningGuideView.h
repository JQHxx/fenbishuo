//
//  CTFLearningGuideView.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/3/30.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ClickSelfBlock)(void);

@interface CTFLearningGuideView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                  hollowFrame:(CGRect)hollowFrame
           hollowCornerRadius:(CGFloat)cornerRadius
               clickSelfBlcok:(ClickSelfBlock)block;

- (instancetype)initWithFrame:(CGRect)frame
                  hollowFrame:(CGRect)hollowFrame
           hollowCornerRadius:(CGFloat)cornerRadius
                    imageName:(NSString *)imageName
                   imageFrame:(CGRect)imageFrame
               clickSelfBlcok:(ClickSelfBlock)block;

- (instancetype)initWithFrame:(CGRect)frame
                        alpha:(CGFloat)alpha
                  hollowFrame:(CGRect)hollowFrame
           hollowCornerRadius:(CGFloat)cornerRadius
                    imageName:(NSString *)imageName
                   imageFrame:(CGRect)imageFrame
               clickSelfBlcok:(ClickSelfBlock)block;

- (instancetype)initWithFrame:(CGRect)frame
                        alpha:(CGFloat)alpha
                  hollowFrame:(CGRect)hollowFrame
           hollowCornerRadius:(CGFloat)cornerRadius
                    imageName:(NSString *)imageName
                   imageFrame:(CGRect)imageFrame
                   ignoreRect:(CGRect)ignoreRect
               clickSelfBlcok:(ClickSelfBlock)block;

@end

NS_ASSUME_NONNULL_END
