//
//  UIFont+DefFonts.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/12.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (DefFonts)

/// feed流标题字体
+ (UIFont *)ctfFeedTitleFont;


/// feed流描述字体
+ (UIFont *)ctfFeedIntrFont;


/// feed里面用户昵称字体
+ (UIFont *)ctfFeedNickFont;

///详情页面观点字体
+(UIFont*)ctfAnswertDetailFont;
@end

NS_ASSUME_NONNULL_END
