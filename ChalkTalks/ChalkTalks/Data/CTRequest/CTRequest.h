//
//  CTRequest.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/4.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YTKNetwork/YTKNetwork.h>
#import "NSDictionary+Safety.h"

@class CTRequest;

// data可能是NSDictionary/NSArray
typedef void (^ApiRequstSuccessBlock)(id _Nullable data);
typedef void (^ApiRequstFailureBlock)(NSError* _Nullable error);
typedef void (^ApiRequstCompleteBlock)(BOOL isSuccess,id _Nullable data, NSError* _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface CTRequest : YTKRequest

- (instancetype)initWithRequestUrl:(NSString *)url
                argument:(nullable NSDictionary *)argument
                  method:(YTKRequestMethod)method;

/// 请求URL地址
@property (nonatomic, strong) NSString *api;

/// 请求方法
@property (nonatomic, assign) YTKRequestMethod apiMethod;

/// 请求参数
@property (nonatomic, strong) NSDictionary *apiParameters;
 
/// 错误提示
@property (nonatomic, strong) NSString *errorInfo;
 
/// 是否校验json数据格式，默认yes
@property (nonatomic, assign) BOOL verifyJSONFormat;
 
/// apiCacheTime > 0 为接口加入缓存的时长 单位秒， 默认为-1，代码不需要缓存
@property (nonatomic, assign) NSTimeInterval apiCacheTime;

/// 开始请求数据
/// @param success 成功回调
/// @param failure 失败回调，返回error信息
- (void)requstApiSuccess:(ApiRequstSuccessBlock)success
                 failure:(ApiRequstFailureBlock)failure;

/// 请求API
/// @param complete 完成回调
- (void)requstApiComplete:(ApiRequstCompleteBlock)complete;

/// apiCacheTime > 0 有效。请求API, 先加载缓存里面的数据，再请求网络
/// @param complete 完成回调
- (void)requstApiWithCacheComplete:(ApiRequstCompleteBlock)complete;

@end

NS_ASSUME_NONNULL_END
