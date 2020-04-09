//
//  NSString+RegularExpressionUtil.m
//  StarryNight
//
//  Created by zingwin on 2017/3/9.
//  Copyright © 2017年 zwin. All rights reserved.
//

#import "NSString+RegularExpressionUtil.h"


static NSString * const  regular_mobileNum = @"^1\\d{10}$";

static NSString * const  regular_RealName = @"^([\u4e00-\u9fa5]{2,20})|([a-zA-Z]{6,20})$";

static NSString * const  regular_Id = @"^([1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}([0-9]|X|x))$";

static NSString * const  regular_Email = @"^([a-zA-Z0-9_\\.\\-])+\\@(([a-zA-Z0-9\\-])+\\.)+([a-zA-Z0-9]{2,4})+$";

static NSString * const  regular_Password = @"^[_0-9a-zA-Z-]{6,20}$";

static NSString * const  regular_Username = @"^(?i)[A-Za-z]{1}[_0-9a-zA-Z-]{5,19}$";

static NSString * const  regular_ZipCode = @"\\d{6}";

static NSString * const  regular_Verify  = @"\\d+";

static NSString * const  regular_Emoji = @"^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f";


@implementation NSString (RegularExpressionUtil)
- (BOOL)validateWithValidateType:(ValidateType)type{
    
    NSPredicate * regexTest;
    switch (type) {
        case ValidateTypeForMobile:
        {
            //regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular_mobileNum];
            if (self.length != 11) {
                return NO;
            }else{
                return YES;
            }
        }
            break;
        case ValidateTypeForId:
        {
            //regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular_Id];
            if (self.length == 15 || self.length == 18) {
                return YES;
            }else{
                return NO;
            }
        }
            break;
        case ValidateTypeForEmail:
        {
            regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular_Email];
        }
            break;
        case ValidateTypeForRealName:{
            regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular_RealName];
        }
            break;
        case ValidateTypeForUsername:{
            regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular_Username];
        }
            break;
        case ValidateTypeForPassword:{
            //regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular_Password];
            if (self.length >= 6 && self.length <= 20) {
                return YES;
            }else{
                return NO;
            }
        }
            break;
        case ValidateTypeForZipCode:{
            regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular_ZipCode];
        }
            break;
        case ValidateTypeForVerify:{
            regexTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular_Verify];
        }
            break;
        case ValidateTypeForNone:
        {
            return NO;
        }
            break;
    }
    return [regexTest evaluateWithObject:self];
}

- (BOOL)isEmpty{
    
    //A character set containing only the whitespace characters space (U+0020) and tab (U+0009) and the newline and nextline characters (U+000A–U+000D, U+0085).
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    //Returns a new string made by removing from both ends of the receiver characters contained in a given character set.
    NSString *trimedString = [self stringByTrimmingCharactersInSet:set];
    
    if ([trimedString length] == 0) {
        return YES;
    } else {
        return NO;
    }
    
}
@end
