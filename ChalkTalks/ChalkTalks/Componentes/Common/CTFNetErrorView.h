//
//  CTFNetErrorView.h
//  ChalkTalks
//
//  Created by vision on 2020/1/6.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFBaseBlankView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFNetErrorView : CTFBaseBlankView

- (instancetype)initWithFrame:(CGRect)frame errorType:(ERRORTYPE)errorType whetherLittleIconModel:(BOOL)isLittleIconModel;

@property (nonatomic,strong) UIButton  *refreshBtn;

@end

NS_ASSUME_NONNULL_END
