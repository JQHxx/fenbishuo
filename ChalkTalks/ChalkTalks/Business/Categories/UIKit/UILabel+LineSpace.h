//
//  UILabel+LineSpace.h
//  StarryNight
//
//  Created by zingwin on 2017/5/9.
//  Copyright © 2017年 zwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (LineSpace)
/**
 *  改变行间距
 */
- (void)changeLineSpaceWithSpace:(float)space;

/**
 *  改变字间距
 */
- (void)changeWordSpaceWithSpace:(float)space;

/**
 *  改变行间距和字间距
 */
- (void)changeSpacewithLineSpace:(float)lineSpace WordSpace:(float)wordSpace;

@end
