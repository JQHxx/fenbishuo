//
//  NSString+RegularExpressionUtil.h
//  StarryNight
//
//  Created by zingwin on 2017/3/9.
//  Copyright © 2017年 zwin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ValidateType) {
    ValidateTypeForMobile = 0,
    ValidateTypeForRealName,
    ValidateTypeForId,
    ValidateTypeForEmail,
    ValidateTypeForPassword,
    ValidateTypeForUsername,
    ValidateTypeForZipCode, // 邮政编码
    ValidateTypeForVerify,
    ValidateTypeForNone
};

@interface NSString (RegularExpressionUtil)
- (BOOL)validateWithValidateType:(ValidateType) type;

- (BOOL)isEmpty;
@end
