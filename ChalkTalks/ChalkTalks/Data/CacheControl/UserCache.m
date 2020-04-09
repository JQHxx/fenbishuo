//
//  UserCache.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "UserCache.h"
#import "CTFCommonManager.h"

static NSString * const cttokenkey = @"ct_authtokenkey";
static NSString * const ctUserIsNew = @"ct_userIsNewKey";
static NSString * const ctuserinfokey = @"ct_userinfokey";
static NSString * const ctInputPhoneNumberKey = @"ct_inputPhoneNumber";

@implementation UserCache

+ (void)insertObjectInUserDefaults:(NSObject *)obj key:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:obj forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)obtainObjectFromUserDefaultsWith:(NSString *)key {
   return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (UserLoginStatus)isUserLogined {
    UserModel *user = [UserCache getUserInfo];
    if (user) {
        if (user.isBindMobile) {
            return UserLoginStatus_BindPhone;
        }
        return UserLoginStatus_UnBindPhone;
    }
    return UserLoginStatus_NotLogin;
}

+ (NSString *)getCurrentUserID {
    UserModel *user = [UserCache getUserInfo];
    if (user) {
        return [NSString stringWithFormat:@"%ld", user.userId];
    }
    return @"tourist";
}

+ (void)saveUserInfo:(UserModel *)userinfo {
    if (userinfo) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userinfo];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:ctuserinfokey];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ctuserinfokey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (UserModel *)getUserInfo {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:ctuserinfokey];
    if (data == nil) return nil;
    UserModel *userinfo = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return userinfo;
}

+ (void)saveUserAuthtoken:(NSString *)token {
    [UserCache insertObjectInUserDefaults:token key:cttokenkey];
}

+ (NSString *)getUserAuthtoken {
    return [UserCache obtainObjectFromUserDefaultsWith:cttokenkey];
}

+ (void)saveUserIsNew:(NSNumber *)isNew {
    [UserCache insertObjectInUserDefaults:isNew key:ctUserIsNew];
}

+ (BOOL)getUserIsNew {
    return [[UserCache obtainObjectFromUserDefaultsWith:ctUserIsNew] boolValue];
}

+ (void)clearUserCache {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:cttokenkey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:ctuserinfokey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [CTFCommonManager sharedCTFCommonManager].questionTitleSuffix = [[NSArray alloc] init];
}


#pragma mark 上传设备信息
+ (void)uploadUserDeviceInfoWithAppLaunching:(BOOL)appLauching {
    CTRequest *request = [CTFUtilsApi uploadUserDeviceInfoWithAppLaunching:appLauching];
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
         
    }];
}

@end
