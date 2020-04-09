//
//  CTFConfigsViewModel.h
//  ChalkTalks
//
//  Created by vision on 2020/2/10.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "BaseViewModel.h"
#import "CTFConfigsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFConfigsViewModel : BaseViewModel

/*
 * 系统配置
 */
-(void)systemConfigsComplete:(AdpaterComplete)complete;

//系统配置
-(CTFConfigsModel *)getTSysConfigs;


@end

NS_ASSUME_NONNULL_END
