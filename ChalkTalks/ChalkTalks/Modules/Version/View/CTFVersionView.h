//
//  CTFVersionView.h
//  ChalkTalks
//
//  Created by vision on 2020/1/1.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTFVersionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFVersionView : UIView

+(void)showVersionViewWithFrame:(CGRect)frame version:(CTFVersionModel *)model;

@end

NS_ASSUME_NONNULL_END
