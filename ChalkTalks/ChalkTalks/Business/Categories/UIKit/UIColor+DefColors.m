#import "UIColor+DefColors.h"
#import "CTMacro.h"

@implementation UIColor (DefColors)
+ (UIColor *)ctMainColor{
    return UIColorFromHEX(0xFF6885);
}

+ (UIColor *)ctBackgroundColor{
    return UIColorFromHEX(0xf0f0f0);
};
+ (UIColor *)ctColor220{
    return UIColorFromHEX(0xdcdcdc);
}

+ (UIColor *)ctColor230{
    return UIColorFromHEX(0xe6e6e6);
};

+ (UIColor *)ctColor33{
    return UIColorFromHEX(0x333333);
};

+ (UIColor *)ctColor66{
    return UIColorFromHEX(0x666666);
};

+ (UIColor *)ctColor99{
    return UIColorFromHEX(0x999999);
};

+ (UIColor *)ctColorB0{
    return UIColorFromHEX(0xb0b0b0);
};

+ (UIColor *)ctColorBB{
    return UIColorFromHEX(0xbbbbbb);
}

+ (UIColor *)ctColorC2{
    return UIColorFromHEX(0xc2c2c2);
};
+ (UIColor *)ctColorCC{
    return UIColorFromHEX(0xCCCCCC);
};

+ (UIColor *)ctColorEE{
    return UIColorFromHEX(0xeeeeee);
}

+ (UIColor *)ctColorF8{
    return UIColorFromHEX(0xf8f8f8);
}

+ (UIColor *)ctYelloColor{
    return UIColorFromHEX(0xFFD624);
}

+ (UIColor *)ctGreenColor{
    return UIColorFromHEX(0x559F00);
}

+ (UIColor *)ctRedColor{
    return UIColorFromHEX(0xFF3600);
}

+ (UIColor *)ctOrangeColor{
    return UIColorFromHEX(0xFF6E0D);
}

+ (UIColor *)ctSeparatorColor{
    return [UIColor ctColorEE];
}

+ (UIColor *)ctColor4C{
    return UIColorFromHEX(0x4c4c4c);
}

+ (UIColor *)ctColor80{
    return UIColorFromHEX(0x808080);
}

+ (UIColor *)ctColor9B{
    return UIColorFromHEX(0x9B9B9B);
}

+ (UIColor *)ctRecommendColor {
    return UIColorFromHEX(0xFFC028);
}

+ (UIColor *)ctColorF2 {
    return UIColorFromHEX(0xF2F2F2);
}

#pragma 创建渐变颜色
+ (UIColor *)bm_colorGradientChangeWithSize:(CGSize)size
                                     direction:(IHGradientChangeDirection)direction
                                    startColor:(UIColor *)startcolor
                                      endColor:(UIColor *)endColor {
    
    if (CGSizeEqualToSize(size, CGSizeZero) || !startcolor || !endColor) {
        return nil;
    }
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    CGPoint startPoint = CGPointZero;
    if (direction == IHGradientChangeDirectionDownDiagonalLine) {
        startPoint = CGPointMake(0.0, 1.0);
    }
    gradientLayer.startPoint = startPoint;
    
    CGPoint endPoint = CGPointZero;
    switch (direction) {
        case IHGradientChangeDirectionLevel:
            endPoint = CGPointMake(1.0, 0.0);
            break;
        case IHGradientChangeDirectionVertical:
            endPoint = CGPointMake(0.0, 1.0);
            break;
        case IHGradientChangeDirectionUpwardDiagonalLine:
            endPoint = CGPointMake(1.0, 1.0);
            break;
        case IHGradientChangeDirectionDownDiagonalLine:
            endPoint = CGPointMake(1.0, 0.0);
            break;
        default:
            break;
    }
    gradientLayer.endPoint = endPoint;
    
    gradientLayer.colors = @[(__bridge id)startcolor.CGColor, (__bridge id)endColor.CGColor];
    UIGraphicsBeginImageContext(size);
    [gradientLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [UIColor colorWithPatternImage:image];
}

@end
