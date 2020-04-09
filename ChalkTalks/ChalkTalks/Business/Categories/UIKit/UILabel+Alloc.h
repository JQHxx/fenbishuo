//
//  UILabel+UILabel_Alloc.h
//  StarryNight
//
//  Created by zingwin on 2017/2/13.
//  Copyright © 2017年 zwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Alloc)
+(instancetype)createLabel:(CGFloat)fontSize
                 textColor:(UIColor*)color;
@end
