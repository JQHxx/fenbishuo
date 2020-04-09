//
//  CTFCustomAlertView.h
//  ChalkTalks
//
//  Created by vision on 2019/12/31.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///弹窗模式
typedef enum{
    ///默认 从窗口正中 弹出
    CTFCustomAlertViewStyleAlert = 0,
    ///下
    CTFCustomAlertViewStyleActionSheetDown,
    
}CTFCustomAlertViewStyle;


typedef void(^showBlock)(void);;
typedef void(^dismissBlock)(void);

@interface CTFCustomAlertView : NSObject
///弹出动画完成后的 回调
@property (nonatomic, copy) showBlock showBlock;
///关闭回调
@property (nonatomic, copy) dismissBlock dismissBlock;

@property (nonatomic,strong) UIColor * maskColor;

@property (nonatomic,assign) BOOL maskNoClick; //面板是否可点击(默认可点)

/**  创建弹出试图 */
+ (CTFCustomAlertView *)sharedMask;

/**
 * show:withType:     弹出视图
 * @param contentView 需要弹出的视图
 * @param style       弹出模式
 */
- (void)show:(UIView *)contentView withType:(CTFCustomAlertViewStyle)style;

/**
 *  show:withType:animationFinish:dismissHandle: 弹出视图
 *  @param contentView 需要弹出的视图
 *  @param style       弹出模式
 *  @param show        弹出回调
 *  @param dismiss     消失回调
 *
 */
- (void)show:(UIView *)contentView withType:(CTFCustomAlertViewStyle)style animationFinish:(showBlock)show dismissHandle:(dismissBlock)dismiss;

/**  移除弹出视图 */
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
