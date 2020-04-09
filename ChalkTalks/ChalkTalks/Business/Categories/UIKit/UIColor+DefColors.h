#import <UIKit/UIKit.h>

/**
 渐变方式
 
 - IHGradientChangeDirectionLevel:              水平渐变
 - IHGradientChangeDirectionVertical:           竖直渐变
 - IHGradientChangeDirectionUpwardDiagonalLine: 向下对角线渐变
 - IHGradientChangeDirectionDownDiagonalLine:   向上对角线渐变
 */
typedef NS_ENUM(NSInteger, IHGradientChangeDirection) {
    IHGradientChangeDirectionLevel,
    IHGradientChangeDirectionVertical,
    IHGradientChangeDirectionUpwardDiagonalLine,
    IHGradientChangeDirectionDownDiagonalLine,
};


@interface UIColor (DefColors)
+ (UIColor *)ctMainColor; //2de2ba
+ (UIColor *)ctBackgroundColor; //0xf0f0f0
+ (UIColor *)ctColor220; //0xdcdcdc
+ (UIColor *)ctColor230; //0xe6e6e6
+ (UIColor *)ctColor33; //333333
+ (UIColor *)ctColor66; //66666
+ (UIColor *)ctColor99; //999
+ (UIColor *)ctColorB0; //B0B0B0
+ (UIColor *)ctColorBB; //BBB
+ (UIColor *)ctColorC2; //C2C2C2
+ (UIColor *)ctColorEE; //EEE
+ (UIColor *)ctYelloColor; //FFD624
+ (UIColor *)ctGreenColor; //559F00
+ (UIColor *)ctRedColor; //FF3600
+ (UIColor *)ctOrangeColor; //FF6E0D
+ (UIColor *)ctColorCC; //cc
+ (UIColor *)ctColorF8; //f8
+ (UIColor *)ctSeparatorColor;
+ (UIColor *)ctColor4C;
+ (UIColor *)ctColor80;
+ (UIColor *)ctColor9B;
+ (UIColor *)ctRecommendColor;
+ (UIColor *)ctColorF2;

/**
 创建渐变颜色
 
 @param size       渐变的size
 @param direction  渐变方式
 @param startcolor 开始颜色
 @param endColor   结束颜色
 
 @return 创建的渐变颜色
 */
+ (UIColor *)bm_colorGradientChangeWithSize:(CGSize)size
                                     direction:(IHGradientChangeDirection)direction
                                    startColor:(UIColor *)startcolor
                                      endColor:(UIColor *)endColor;


@end
