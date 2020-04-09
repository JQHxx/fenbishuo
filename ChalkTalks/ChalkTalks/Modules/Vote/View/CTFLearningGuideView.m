//
//  CTFLearningGuideView.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/3/30.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFLearningGuideView.h"

@interface CTFLearningGuideView ()

@property (nonatomic, assign) CGRect hollowFrame;
@property (nonatomic, assign) CGFloat hollowCornerRadius;
@property (nonatomic, copy) ClickSelfBlock clickSelfBlock;
@property (nonatomic, assign) CGFloat coverAlpha;
@property (nonatomic, assign) CGRect ignoreRect;

@end

@implementation CTFLearningGuideView

- (instancetype)init {
    self = [super init];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                  hollowFrame:(CGRect)hollowFrame
           hollowCornerRadius:(CGFloat)cornerRadius
               clickSelfBlcok:(ClickSelfBlock)block {
    
    if (self = [super init]) {
        self.frame = frame;
        self.coverAlpha = 0.7;
        self.backgroundColor = [UIColor clearColor];
        self.hollowFrame = hollowFrame;
        self.hollowCornerRadius = cornerRadius;
        self.ignoreRect = CGRectZero;
        self.clickSelfBlock = block;
        [self addTapPressed:@selector(clickSelfAction) target:self];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                  hollowFrame:(CGRect)hollowFrame
           hollowCornerRadius:(CGFloat)cornerRadius
                    imageName:(NSString *)imageName
                   imageFrame:(CGRect)imageFrame
               clickSelfBlcok:(ClickSelfBlock)block {
    
    if (self = [super init]) {
        self.frame = frame;
        self.coverAlpha = 0.7;
        self.backgroundColor = [UIColor clearColor];
        self.hollowFrame = hollowFrame;
        self.hollowCornerRadius = cornerRadius;
        self.ignoreRect = CGRectZero;
        self.clickSelfBlock = block;
        [self addTapPressed:@selector(clickSelfAction) target:self];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        imageView.frame = imageFrame;
        [self addSubview:imageView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                        alpha:(CGFloat)alpha
                  hollowFrame:(CGRect)hollowFrame
           hollowCornerRadius:(CGFloat)cornerRadius
                    imageName:(NSString *)imageName
                   imageFrame:(CGRect)imageFrame
               clickSelfBlcok:(ClickSelfBlock)block {
    
    if (self = [super init]) {
        self.frame = frame;
        self.coverAlpha = alpha;
        self.backgroundColor = [UIColor clearColor];
        self.hollowFrame = hollowFrame;
        self.hollowCornerRadius = cornerRadius;
        self.ignoreRect = CGRectZero;
        self.clickSelfBlock = block;
        [self addTapPressed:@selector(clickSelfAction) target:self];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        imageView.frame = imageFrame;
        [self addSubview:imageView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                        alpha:(CGFloat)alpha
                  hollowFrame:(CGRect)hollowFrame
           hollowCornerRadius:(CGFloat)cornerRadius
                    imageName:(NSString *)imageName
                   imageFrame:(CGRect)imageFrame
                   ignoreRect:(CGRect)ignoreRect
               clickSelfBlcok:(ClickSelfBlock)block {
    
    if (self = [super init]) {
        self.frame = frame;
        self.coverAlpha = alpha;
        self.backgroundColor = [UIColor clearColor];
        self.hollowFrame = hollowFrame;
        self.hollowCornerRadius = cornerRadius;
        self.ignoreRect = ignoreRect;
        self.clickSelfBlock = block;
        [self addTapPressed:@selector(clickSelfAction) target:self];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        imageView.frame = imageFrame;
        [self addSubview:imageView];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == nil) {
        return;
    }
    [[[UIColor blackColor] colorWithAlphaComponent:self.coverAlpha] setFill];
    UIRectFill(rect);
    
    [[UIColor clearColor] setFill];
    
    //设置透明部分位置和圆角
    CGRect alphaRect = self.hollowFrame;
    CGFloat cornerRadius = self.hollowCornerRadius;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:alphaRect
                                                        cornerRadius:cornerRadius];
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), [[UIColor clearColor] CGColor]);
   
    CGContextAddPath(context, bezierPath.CGPath);
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGContextFillPath(context);
}

- (void)clickSelfAction {
    self.clickSelfBlock();
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!CGRectContainsPoint(self.frame, point)) {
        return nil;
    }
    
    if (!self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01) {
        return nil;
    }
    if (CGRectContainsPoint(self.hollowFrame, point)) {
        if (CGRectContainsPoint(self.ignoreRect, point)) {
            return nil;
        } else {
            [self clickSelfAction];
            return nil;
        }
    }
    if (self.coverAlpha == 0.f) {
        [self clickSelfAction];
        return nil;
    }
    if ([self pointInside:point withEvent:event]) {
        for (UIView *subview in [self.subviews reverseObjectEnumerator]) {
            CGPoint convertedPoint = [subview convertPoint:point fromView:self];
            UIView *hitTestView = [subview hitTest:convertedPoint withEvent:event];
            if (hitTestView) {
                return hitTestView;
            }
        }
        return self;
    }
    return nil;
}

@end
