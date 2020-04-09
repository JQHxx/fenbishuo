//
//  CTFVersionViewModel.h
//  ChalkTalks
//
//  Created by vision on 2020/1/1.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "BaseViewModel.h"
#import "CTFVersionModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFVersionViewModel : BaseViewModel

/*
 * 检测版本
 */
-(void)checkVersioncomplete:(AdpaterComplete)complete;

//获取版本信息
-(CTFVersionModel *)getTargetVersion;

@end

NS_ASSUME_NONNULL_END
