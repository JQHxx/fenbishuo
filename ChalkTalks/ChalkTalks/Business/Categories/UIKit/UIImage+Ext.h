#import <UIKit/UIKit.h>

@interface UIImage (Ext)


/// 绘制有边框的纯色图片
/// @param fillColor 填充颜色
/// @param borderColor 边框颜色
/// @param borderWidth 边框宽度
/// @param cornerRadius 圆角
+ (UIImage *)ctRoundRectImageWithFillColor:(UIColor *)fillColor
                               borderColor:(UIColor *)borderColor
                               borderWidth:(CGFloat)borderWidth
                              cornerRadius:(CGFloat)cornerRadius;


/// 绘制没有边框的纯色图片
/// @param fillColor 填充颜色
/// @param cornerRadius 圆角
+ (UIImage *)ctRoundRectImageWithFillColor:(UIColor *)fillColor
                              cornerRadius:(CGFloat)cornerRadius;


/// app默认填充图
+ (UIImage *)ctPlaceholderImage;


/// 用户头像默认图
+( UIImage*)ctUserPlaceholderImage;


/// 保证图片拉伸不变形
- (UIImage *)ctfResizingImageState;

+ (void)ctfBoxblurImage:(UIImage *)image withBlurNumber:(CGFloat)blur completeBlock:(void(^)(UIImage *handledImage))completeBlock;

/**
 *   图片模糊
 *
 *   @param  image 要模糊的图片
 *   @param  blur  模糊程度
 *   @return 模糊后的图片
 *
 */
+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;



/// 图片自动旋转到 UIImageOrientationUp
- (UIImage *)fixOrientation;

//变成圆形图片
- (UIImage *)circleImage;
@end
