//
//  UIView+ShowMessageView.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/5.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ShowMessageView)

/// 展示占位图（图片+说明文字+按钮中的文字+按钮响应Block）
/// @param showEmpty 是否显示
/// @param imageName 图片名字
/// @param message 说明文字
/// @param clickString 按钮中的文字
/// @param block 按钮响应Block
/// @param topOffset 调用该方法的view的Top与该占位图的Top的距离
- (void)ctfEmptyViewWhetherShow:(BOOL)showEmpty imageName:(NSString *)imageName message:(nullable NSString *)message clickString:(nullable NSString *)clickString clickBlock:(nullable void(^)(void))block topOffset:(NSInteger)topOffset;

- (void)ctfEmptyViewWhetherShow:(BOOL)showEmpty imageName:(NSString *)imageName message:(nullable NSString *)message clickString:(nullable NSString *)clickString clickBlock:(nullable void(^)(void))block whetherNavigationBar:(BOOL)whetherNavigationBar topOffset:(NSInteger)topOffset;

/// 展示占位图之没有网络情景
/// @param callerView 需要展示到的界面
/// @param topOffset 调用该方法的view的Top与该占位图的Top的距离
+ (void)ctfEmptyViewWithNetLossToView:(UIView *)callerView topOffset:(NSInteger)topOffset;

@end

NS_ASSUME_NONNULL_END
