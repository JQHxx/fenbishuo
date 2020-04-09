//
//  BaseViewModel.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTModels.h"
#import "NSDictionary+Safety.h"
#import "NSArray+Safety.h"
#import <ReactiveObjC/ReactiveObjC.h>

typedef NS_ENUM(NSInteger, ERRORTYPE) {
    UNERROR = 0x00,         //没有报错
    ERROR_SERVER = 0x01,    //500  正常提示用户 toast
    ERROR_NET = 0x10,       //网络测试404 超时  400/401  正常提示用户 toast
    ERROR_PARAM = 0x11,     //接口参数验证报错  正常提示用户 toast
    ERROR_Auth = 0x100,     //用户使用权限错误，需要重新登录
    ERROR_COMMON = 0x110,   //普通错误，正常提示用户 toast
};

typedef void (^AdpaterComplete)(BOOL isSuccess);

#define kNetErrorTips @"网络错误，稍后重试"
#define kServerErrorTips @"服务器偷懒啦，稍后重试"

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewModel : NSObject
@property(nonatomic,strong) NSString *apiErrorString;
@property(nonatomic,assign) ERRORTYPE apiErrorType;
@property(nonatomic,assign) NSInteger serverErrorCode;
+(NSInteger)pageSize;
-(BOOL)isRefreshing;
-(BOOL)hasMoreData;
-(BOOL)isEmpty;
-(BOOL)hasError;
-(ERRORTYPE)errorType;
-(NSString*)errorString;

-(void)handlerError:(NSError*)error;
@end

NS_ASSUME_NONNULL_END
