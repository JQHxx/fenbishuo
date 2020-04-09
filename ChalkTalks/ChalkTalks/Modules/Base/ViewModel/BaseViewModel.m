//
//  BaseViewModel.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "BaseViewModel.h"
@interface BaseViewModel()
@property(nonatomic,assign) BOOL apiLoaded;
@end

@implementation BaseViewModel
+(NSInteger)pageSize{
    return 15;
}

-(BOOL)hasMoreData{
    return NO;
}

-(BOOL)isEmpty{
    return YES;
}

-(BOOL)hasError{
    return self.apiErrorType != UNERROR;
}

-(NSString*)errorString{
    if (self.apiErrorString && self.apiErrorString.length) {
        return self.apiErrorString;
    }
    return nil;
}

-(ERRORTYPE)errorType{
    return self.apiErrorType;
}

-(void)handlerError:(NSError*)error{
    if(error){
        if(error.code == NSURLErrorNotConnectedToInternet){
            self.apiErrorString = @"操作失败，请检查网络连接";
            self.apiErrorType = ERROR_NET;
        }else if(error.code == NSURLErrorTimedOut){
            self.apiErrorString = @"网络错误，请检查网络后重试";
            self.apiErrorType = ERROR_NET;
        }else if (error.code == 401 || error.code == 403 || error.code == 404) {
            self.apiErrorString = @"404";
             self.apiErrorType = ERROR_NET;
        }else if (error.code == 500) {
            self.apiErrorType = ERROR_SERVER;
            self.apiErrorString = kServerErrorTips;
        }else if(error.code == 4011 ||
                 error.code == 4012 ||
                 error.code == 4013 ){
            self.serverErrorCode = error.code;
            self.apiErrorType = ERROR_Auth;
            self.apiErrorString = [error.userInfo safe_stringForKey:NSLocalizedDescriptionKey];
        }else{
            self.serverErrorCode = error.code;
            self.apiErrorType = ERROR_COMMON;
            self.apiErrorString = [error.userInfo safe_stringForKey:NSLocalizedDescriptionKey];
        }
    }else{
        self.apiErrorString = @"";
        self.apiErrorType = UNERROR;
        self.serverErrorCode = 0;
    }
    self.apiLoaded = YES;
}

-(BOOL)isRefreshing{
    return !self.apiLoaded;
}
@end
