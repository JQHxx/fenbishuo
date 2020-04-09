//
//  AliOSSTokenCache.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/13.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "AliOSSTokenCache.h"


static NSString* const ctaliuploadtokenkey = @"ctaliuploadtokenkey";


@implementation AliOSSTokenCache

+(void)saveAliUploadToken:(AliUploadTokenModel*)aliToken{
    if (aliToken && aliToken.accessToken && aliToken.accessToken.length){
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:aliToken];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:ctaliuploadtokenkey];
    }else{
//        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ctaliuploadtokenkey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(AliUploadTokenModel*)getAliUploadToken{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:ctaliuploadtokenkey];
    if (data == nil) return nil;
    AliUploadTokenModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return model;
}
@end
