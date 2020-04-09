//
//  PhoneLoginViewController.h
//  ChalkTalks
//
//  Created by 何雨晴 on 2019/12/5.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "BaseViewController.h"


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CTFFunctionType) {
    CTFFunctionType_Login = 0,
    CTFFunctionType_Bind
};

/// 手机验证码登录、手机验证码绑定
@interface PhoneLoginViewController : BaseViewController

- (instancetype)initWithFunctionType:(CTFFunctionType)functionType;

@end

NS_ASSUME_NONNULL_END
