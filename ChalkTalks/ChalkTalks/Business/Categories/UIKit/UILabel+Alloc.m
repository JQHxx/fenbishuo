//
//  UILabel+UILabel_Alloc.m
//  StarryNight
//
//  Created by zingwin on 2017/2/13.
//  Copyright © 2017年 zwin. All rights reserved.
//

#import "UILabel+Alloc.h"

@implementation UILabel (Alloc)
+(instancetype)createLabel:(CGFloat)fontSize
                 textColor:(UIColor*)color{
    UILabel *lbl = [[UILabel alloc] init];
    lbl.font = [UIFont systemFontOfSize:fontSize];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textColor = color;
    return lbl;
}
@end
