//
//  CTRequest.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/4.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "CTRequest.h"
#import "EncryptUtils.h"
#import "NSDictionary+Safety.h"
#import "AppInfo.h"
#import "UserCache.h"
#import "AppDelegate.h"
@import AFNetworking;
#import "LoginViewController.h"
#import <AFNetworking/AFURLSessionManager.h>

@interface CTQueryStringPair : NSObject

@property (readwrite, nonatomic, strong) id field;
@property (readwrite, nonatomic, strong) id value;

- (instancetype)initWithField:(id)field value:(id)value;
- (NSString *)URLEncodedStringValue;

@end

@implementation CTQueryStringPair
- (instancetype)initWithField:(id)field value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.field = field;
    self.value = value;

    return self;
}

- (NSString *)URLEncodedStringValue {
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return AFPercentEscapedStringFromString([self.field description]);
    } else {
        NSString *valueStr = [self.value description];
        NSCharacterSet  *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        valueStr = [valueStr stringByTrimmingCharactersInSet:set];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)valueStr, NULL, CFSTR("?!@#$^&%*+,:;='\"`<>()[]{}/\\|"), kCFStringEncodingUTF8));
#pragma clang diagnostic pop
        return [NSString stringWithFormat:@"%@=%@", AFPercentEscapedStringFromString([self.field description]),encodedString];
    }
}

@end


@implementation CTRequest
{
    NSString *appVersion;
}

+ (void)load {
    YTKNetworkConfig *config = [YTKNetworkConfig sharedConfig];
#ifdef DEBUG
    config.debugLogEnabled = NO;
#endif
}

- (instancetype)initWithRequestUrl:(NSString *)url
                          argument:(nullable NSDictionary *)argument
                            method:(YTKRequestMethod)method {
    self = [super init];
    if (self) {
        YTKNetworkConfig *config = [YTKNetworkConfig sharedConfig];
        config.baseUrl = [[CTENVConfig share] baseUrl];
        self.verifyJSONFormat = YES;
        appVersion = [AppInfo appVersion];
        self.api = url;
        self.apiParameters = argument;
        self.apiMethod = method;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.apiCacheTime = -1;
        self.verifyJSONFormat = YES;
        appVersion = [AppInfo appVersion];
    }
    return self;
}

// overrider：网络请求的超时时间
- (NSTimeInterval)requestTimeoutInterval {
    return 20;
}
 
// overrider：JSON数据格式校验
- (id)jsonValidator {
    if (self.verifyJSONFormat) {
        return @{
                 @"data" : [NSObject class],
                 @"code" : [NSNumber class],
                 @"message" : [NSString class]
                 };
    } else {
        return nil;
    }
}

// overrider：网络请求方式
- (YTKRequestMethod)requestMethod {
    return self.apiMethod;
}

// overrider：网络请求URL
- (NSString *)requestUrl {
    return self.api;
}

// overrider：网络请求params
- (id)requestArgument {
    return self.apiParameters;
}

// overrider：网络请求方式（HTTP、JSON）
- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeJSON;
}

// overrider：网络响应方式（HTTP、JSON）
- (YTKResponseSerializerType)responseSerializerType {
    return YTKResponseSerializerTypeJSON;
}

// overrider：网络请求缓存时间
- (NSInteger)cacheTimeInSeconds {
    return self.apiCacheTime > 0 ? self.apiCacheTime : -1;
}

// 网络请求方法1
- (void)requstApiSuccess:(ApiRequstSuccessBlock)success
                 failure:(ApiRequstFailureBlock)failure {
    @weakify(self);
    [super startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        @strongify(self);
        NSDictionary *result = [request responseJSONObject];
        BOOL isSuccess = [result safe_integerForKey:@"code"] == 200;;
        if (isSuccess) {
            ZLLog(@"%@", self.description);
            success([result safe_objectForKey:@"data"]);
        } else {
            NSError *err = [NSError errorWithDomain:@"api_error_code" code:[result safe_integerForKey:@"code"] userInfo:@{ NSLocalizedDescriptionKey:[result safe_stringForKey:@"message"]}];
            LogError(self.description);
            failure(err);
        }
        
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        @strongify(self);
        LogError(self.description);
        NSDictionary *result = [request responseJSONObject];
        //api_token失效或者错误
        if ([result safe_integerForKey:@"code"] == 4011) {
            ZLLog(@"~~~~~~~~~~api_token失效或者错误~~~~~~~~~~");
            if ([UserCache isUserLogined] != UserLoginStatus_NotLogin) {
                [self showApiTokenError];
            }
        }

        //用户被拉黑
        if ([result safe_integerForKey:@"code"] == 4017) {
            ZLLog(@"~~~~~~~~~~用户被拉黑~~~~~~~~~~");
            if ([UserCache isUserLogined] != UserLoginStatus_NotLogin) {
                [self clearUserInfoToLogin];
            }
        }
              
        if (result && [result isKindOfClass:[NSDictionary class]]){
            NSError *err = [NSError errorWithDomain:@"api_error_code" code:[result safe_integerForKey:@"code"] userInfo:@{ NSLocalizedDescriptionKey:[result safe_stringForKey:@"message"]}];
            failure(err);
        } else {
            failure(request.error);
        }
    }];
}

// 网络请求方法2
- (void)requstApiComplete:(ApiRequstCompleteBlock)complete {
    @weakify(self);
    [super startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        NSDictionary *result = [request responseJSONObject];

        NSInteger code = [result safe_integerForKey:@"code"];
        BOOL isSuccess = code == 200 || (code == 0 && request.responseStatusCode == 200);
        NSError *err;
        if (isSuccess == NO && [result safe_stringForKey:@"message"] != nil) {
            err = [NSError errorWithDomain:@"api_error_code" code:[result safe_integerForKey:@"code"] userInfo:@{ NSLocalizedDescriptionKey:[result safe_stringForKey:@"message"]}];
            LogError(self.description);
        }
         ZLLog(@"%@", self.description);
        complete(isSuccess, [result safe_objectForKey:@"data"], err);
       } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
           @strongify(self);
           LogError(self.description);
           NSDictionary *result = [request responseJSONObject];
           
           //api_token失效或者错误
           if ([result safe_integerForKey:@"code"] == 4011) {
               NSLog(@"~~~~~~~~~~api_token失效或者错误~~~~~~~~~~");
               if ([UserCache isUserLogined] != UserLoginStatus_NotLogin) {
                   [self showApiTokenError];
               }
           }
           
           //用户被拉黑
           if ([result safe_integerForKey:@"code"] == 4017) {
               NSLog(@"~~~~~~~~~~用户被拉黑~~~~~~~~~~");
               if ([UserCache isUserLogined] != UserLoginStatus_NotLogin) {
                   [self clearUserInfoToLogin];
               }
           }
           
           if (result && [result isKindOfClass:[NSDictionary class]] && [result safe_stringForKey:@"message"] != nil) {
               NSError *err = [NSError errorWithDomain:@"api_error_code" code:[result safe_integerForKey:@"code"] userInfo:@{ NSLocalizedDescriptionKey:[result safe_stringForKey:@"message"]}];
                complete(NO, nil, err);
           } else {
                complete(NO, nil, request.error);
           }
       }];
}

#pragma mark -- cache
- (void)requstApiWithCacheComplete:(ApiRequstCompleteBlock)complete {
    if ([self loadCacheWithError:nil]) {
        NSDictionary *json = [self responseJSONObject];
        BOOL isSuccess = [json safe_integerForKey:@"code"] == 200;
        complete(isSuccess, [json safe_objectForKey:@"data"], nil);
    }
    if ([AFNetworkReachabilityManager.sharedManager isReachable]) {

    }
    //[self setIgnoreCache:YES];
    [self requstApiComplete:complete];
}
 
- (NSString *)description {
    //打印自己认为重要的信息
    return [NSString stringWithFormat:@"%@ \nstatusCode:%ld\nresponseJSONObject:\n%@",super.description,self.responseStatusCode,self.responseJSONObject];
}
 
- (NSString *)errorInfo:(YTKBaseRequest*)request {
    NSString * info = @"";
    if (request && request.error) {
        if (request.error.code==NSURLErrorNotConnectedToInternet) {
            info = @"操作失败，请检查网络连接";
        } else if (request.error.code==NSURLErrorTimedOut) {
            info = @"网络错误，请检查网络后重试";
        } else if (request.responseStatusCode == 401) {
            info = @"401";
        } else if (request.responseStatusCode == 403) {
            info = @"403";
        } else if (request.responseStatusCode == 404) {
            info = @"404";
        } else if (request.responseStatusCode == 500) {
            info = @"服务器报错,请稍后再试!";
        } else {
            info = @"获取数据失败,请重试!";
        }
    }
    return info;
}

#pragma mark - sign
// overrider：网络请求头的配置
- (NSDictionary *)requestHeaderFieldValueDictionary {
    NSString *requestID = [[NSUUID UUID] UUIDString];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSString *apiKey = [[CTENVConfig share] apiKey];
    NSMutableDictionary *signHeadersDic = [[NSMutableDictionary alloc] init];
    /* 后端颁发给客户端的AppKey */
    [signHeadersDic safe_setValue:apiKey forKey:@"X-FBS-AppKey"];
    /* 当前请求的唯一标识，UUID */
    [signHeadersDic safe_setValue:requestID forKey:@"X-FBS-RequestId"];
    /* 当前请求时的时间戳，时间戳有效时间为15分钟 */
    [signHeadersDic safe_setValue:timeSp forKey:@"X-FBS-Timestamp"];
    /* 当前App的版本号，如1.0.1 */
    [signHeadersDic safe_setValue:self->appVersion forKey:@"X-FBS-AppVersion"];
    
    /* 公共请求headers */
    NSMutableDictionary *httpHeader = [[NSMutableDictionary alloc] initWithDictionary:signHeadersDic];
    
    /* 请求签名，sign生成 */
    NSString *sign= [self apiSign:signHeadersDic];
    [httpHeader safe_setValue:sign forKey:@"X-FBS-Signature"];
    
    /* 参与签名的Header的key，按照英文逗号分隔 */
    NSArray *keyArray = [signHeadersDic allKeys];
    NSArray *sortKeyArray = [keyArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSString *signHeader = [sortKeyArray componentsJoinedByString:@","];
    [httpHeader safe_setValue:signHeader forKey:@"X-FBS-Signature-Headers"];
    
    /* 部分接口需要认证登录才能进行访问，这类接口在请求头中添加Authorization header，格式为Authorization:Bearer <token> */
    NSString *token = [UserCache getUserAuthtoken];
    if (token) {
         [httpHeader safe_setValue:[NSString stringWithFormat:@"Bearer %@", token] forKey:@"Authorization"];
    }
    return httpHeader;
}

// HTTPMethod为全大写，如POST
- (NSString *)HTTPMethodString {
    switch ([self requestMethod]) {
        case YTKRequestMethodGET:
            return @"GET";
        case YTKRequestMethodPOST:
            return @"POST";
        case YTKRequestMethodPUT:
            return @"PUT";
        case YTKRequestMethodDELETE:
            return @"DELETE";
        default:
            return @"";
    }
}

// 参与签名计算的api参数的key、value拼接的字符串。拼接方法：将查询参数按照key进行字典升序排序，然后按照&进行拼接，如b=c&a=d,组织后为a=d,b=c
- (NSString *)ascendingJoinDicKeyValue:(NSDictionary *)dic {
    if (dic == nil) return @"";
    NSString *asc = [self ctQueryStringFromParameters:dic];
    return asc;
}

// sign生成，将sign值放到Request的Header中，Key为@"X-FBS-Signature"
- (NSString *)apiSign:(NSDictionary *)headerDic {
    /*
    stringToSign =
    HTTPMethod + "\n" +
    PATH       + "\n" +
    Query      + "\n" +
    Body       + "\n" +
    Headers
     */
    // HTTPMethod
    NSMutableString *stringToSign = [NSMutableString stringWithFormat:@"%@\n",[self HTTPMethodString]];
    // PATH
    if ([self.requestUrl hasPrefix:@"/"]) {
        [stringToSign appendFormat:@"%@\n",self.requestUrl];
    } else {
        [stringToSign appendFormat:@"/%@\n",self.requestUrl];
    }
    // Query
    if ([self requestMethod] == YTKRequestMethodGET) {
        [stringToSign appendFormat:@"%@\n",[self ascendingJoinDicKeyValue:[self requestArgument]]];
    } else {
        [stringToSign appendString:@"\n"];
    }
    
    // Body
    if ([self requestMethod] == YTKRequestMethodPOST || [self requestMethod] == YTKRequestMethodPUT) {
        [stringToSign appendFormat:@"%@\n", [self ascendingJoinDicKeyValue:[self requestArgument]]];
    } else {
        [stringToSign appendString:@"\n"];
    }

    //Headers
    [stringToSign appendFormat:@"%@",[self ascendingJoinDicKeyValue:headerDic]];
    //计算签名：sign = base64_encode(hmac_sha256(stringToSign, serectKey))
    NSString *secret = [[CTENVConfig share] apiSecret];
    NSString *hmacSHA256 = [EncryptUtils hmacSHA256WithSecret:secret content:stringToSign];
    NSString *sign = [EncryptUtils base64EncodeString:hmacSHA256];
    
    return sign;
}

- (void)showApiTokenError {
    NSString *title = @"账号已在其他设备登录请注意账号安全";
    NSString *message = @"";
    NSString *otherButtonTitle = @"我知道了";

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //清空账户缓存数据
        [UserCache clearUserCache];
        [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutedNotification object:nil];
        
        //控制器栈重置到首页
        UITabBarController *rootTabVC = (UITabBarController *)kAPPDELEGATE.window.rootViewController;
        UINavigationController *nav0 = rootTabVC.viewControllers[0];
        [nav0 popToRootViewControllerAnimated:NO];
        
        UINavigationController *nav1 = rootTabVC.viewControllers[1];
        [nav1 popToRootViewControllerAnimated:NO];
        
        UINavigationController *nav3 = rootTabVC.viewControllers[3];
        [nav3 popToRootViewControllerAnimated:NO];
        
        UINavigationController *nav4 = rootTabVC.viewControllers[4];
        [nav4 popToRootViewControllerAnimated:NO];
        
        [rootTabVC setSelectedIndex:0];
        
        //弹出登录界面
        [[UIViewController getWindowsCurrentVC] ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Logined];
    }];
    
    [otherAction setValue:UIColorFromHEX(0xFF6885) forKey:@"titleTextColor"];
    [alertController addAction:otherAction];
    
    UITabBarController *rootTabVC = (UITabBarController *)kAPPDELEGATE.window.rootViewController;
    UINavigationController *nav_current = (UINavigationController *)rootTabVC.selectedViewController;
    UIViewController *currentVC = nav_current.topViewController;
    
    if ([UIViewController getWindowsCurrentVC].presentingViewController && ![[UIViewController getWindowsCurrentVC] isKindOfClass:[LoginViewController class]]) {
        [[UIViewController getWindowsCurrentVC] dismissViewControllerAnimated:YES completion:^{
            [currentVC presentViewController:alertController animated:YES completion:nil];
        }];
    } else {
        [currentVC presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)clearUserInfoToLogin {
    //清空账户缓存数据
    [UserCache clearUserCache];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutedNotification object:nil];
    
    //控制器栈重置到首页
    UITabBarController *rootTabVC = (UITabBarController *)kAPPDELEGATE.window.rootViewController;
    UINavigationController *nav0 = rootTabVC.viewControllers[0];
    [nav0 popToRootViewControllerAnimated:NO];
    
    UINavigationController *nav1 = rootTabVC.viewControllers[1];
    [nav1 popToRootViewControllerAnimated:NO];
    
    UINavigationController *nav3 = rootTabVC.viewControllers[3];
    [nav3 popToRootViewControllerAnimated:NO];
    
    UINavigationController *nav4 = rootTabVC.viewControllers[4];
    [nav4 popToRootViewControllerAnimated:NO];
    
    [rootTabVC setSelectedIndex:0];
    
    // 弹出登录界面
    [[UIViewController getWindowsCurrentVC] ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Logined];
}

#pragma mark - private
- (NSArray *)ctQueryStringPairsFromKeyAndValue:(NSString *)key value:(id)value {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[sortDescriptor]]) {
            id nestedValue = dictionary[nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:[self ctQueryStringPairsFromKeyAndValue:(key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey) value:nestedValue]];
            }
        }
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        NSInteger count = 0;
        for (id nestedValue in array) {
            [mutableQueryStringComponents addObjectsFromArray:[self ctQueryStringPairsFromKeyAndValue:[NSString stringWithFormat:@"%@[%zd]", key, count] value:nestedValue]];
            count++;
        }
    } else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in [set sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            [mutableQueryStringComponents addObjectsFromArray:[self ctQueryStringPairsFromKeyAndValue:key value:obj]];
        }
    } else {
        [mutableQueryStringComponents addObject:[[CTQueryStringPair alloc] initWithField:key value:value]];
    }

    return mutableQueryStringComponents;
}

- (NSString *)ctQueryStringFromParameters:(NSDictionary *)parameters {
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (CTQueryStringPair *pair in [self ctQueryStringPairsFromKeyAndValue:nil value:parameters]) {
        [mutablePairs addObject:[pair URLEncodedStringValue]];
    }
    return [mutablePairs componentsJoinedByString:@"&"];
}

@end

