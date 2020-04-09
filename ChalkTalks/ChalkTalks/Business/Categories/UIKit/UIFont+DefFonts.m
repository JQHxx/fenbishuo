//
//  UIFont+DefFonts.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/12.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "UIFont+DefFonts.h"

@implementation UIFont (DefFonts)
+ (UIFont *)ctfFeedTitleFont{
    return [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
}

+ (UIFont *)ctfFeedIntrFont{
    return [UIFont systemFontOfSize:14 weight:UIFontWeightLight];
}

+ (UIFont *)ctfFeedNickFont{
    return [UIFont systemFontOfSize:11];
}

+(UIFont*)ctfAnswertDetailFont{
    return  [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
}
@end
