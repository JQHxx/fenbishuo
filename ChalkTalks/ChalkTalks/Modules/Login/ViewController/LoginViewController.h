//
//  LoginViewController.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

/// 微信登录引导页
@interface LoginViewController : BaseViewController

@property (nonatomic, assign, readonly) BOOL isContinueBindPhone;// 登录成功后是否需要继续进行绑定手机号

@end

NS_ASSUME_NONNULL_END
