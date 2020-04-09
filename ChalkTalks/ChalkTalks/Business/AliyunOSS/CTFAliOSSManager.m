//
//  CTFAliOSSManager.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/23.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFAliOSSManager.h"
#import "NSDictionary+Safety.h"
#import <ReactiveObjC/ReactiveObjC.h>

#import "ChalkTalks-Swift.h"

@interface CTFAliOSSManager ()
@property(nonatomic,strong) OSSClient *ossClient;
@property(nonatomic,strong) NSMutableDictionary *uploadTaskDic;
@end

@implementation CTFAliOSSManager

-(instancetype)init{
    self = [super init];
    if (self) {
        [self setupClient];
        self.uploadTaskDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)dealloc{
    [self.uploadTaskDic removeAllObjects];
    self.uploadTaskDic = nil;
}

-(void)setupClient{
    NSString *endpoint = @"http://oss-cn-shenzhen.aliyuncs.com";

    OSSClientConfiguration * conf = [OSSClientConfiguration new];
    conf.maxRetryCount = 1; // 网络请求遇到异常失败后的重试次数
    conf.timeoutIntervalForRequest = 30; // 网络请求的超时时间
    conf.timeoutIntervalForResource = 24 * 60 * 60; // 允许资源传输的最长时间

    id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] init];
    
    self.ossClient = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential clientConfiguration:conf];
    [self configAliOSSToken];
    
    [OSSLog disableLog];
}

-(void)configAliOSSToken{
    AliUploadTokenModel *tokenModel = [AliOSSTokenCache getAliUploadToken];
    
    if(!tokenModel) return;
    
    id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:tokenModel.accessKeyId secretKeyId:tokenModel.accessKeySecret securityToken:tokenModel.accessToken];
    
    self.ossClient.credentialProvider = credential;
}

-(void)cancelUploadByImageId:(NSString*)imageId{
   OSSPutObjectRequest *put = [self.uploadTaskDic safe_objectForKey:imageId];
    if(put){
        [put cancel];
        [self.uploadTaskDic removeObjectForKey:imageId];
    }
}

-(void)asyncUploadImageByObjectKey:(NSString*)objectKey
                           imageId:(NSString*)imageId
                        uploadData:(NSData*)imgData
                          progress:(void (^)(CGFloat progress))progress
                           success:(void (^)(void))success
                           failure:(void (^)(NSError * _Nonnull))failure{
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        
        OSSPutObjectRequest *put = [OSSPutObjectRequest new];
        put.bucketName = [[CTENVConfig share] aliBucketName];
        put.objectKey = objectKey;
        put.uploadingData = imgData;  // 直接上传NSData
        NSString *businessId = imageId; //imageID
               
        static NSString *callbackBody = @"{\"bucket\":${bucket},\"object\":${object},\"etag\":${etag},\"size\":${size},\"mimeType\":${mimeType},\"imageHeight\":\"${imageInfo.height}\",\"imageWidth\":\"${imageInfo.width}\",\"imageFormat\":${imageInfo.format},\"businessId\":${x:id}}";
               
        // 设置回调参数
        NSString *baseUrl = [[CTENVConfig share] baseUrl];
        put.callbackParam = @{
                                @"callbackUrl": [NSString stringWithFormat: @"%@/api/v1/images/callback", baseUrl],
                                @"callbackBody" : callbackBody,
                                @"callbackBodyType" : @"application/json",
                                };
        // 设置自定义变量
        put.callbackVar = @{@"x:id":businessId};
               
        put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
               CGFloat p =  totalByteSent * 1.0f / totalBytesExpectedToSend;
               dispatch_async(dispatch_get_main_queue(), ^{
                   if(progress) progress(p);
               });
        };
        
        OSSTask * putTask = [self.ossClient putObject:put];
        [putTask continueWithBlock:^id(OSSTask *task) {
            if (!task.error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(success) success();
                });
            } else {
                if(task.error.code == OSSClientErrorCodeTaskCancelled){
                    ZLLog(@"用户取消");
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(failure) failure(task.error);
                    });
                }
                ZLLog(@"upload object failed, error: %@" , task.error);
            }
            return nil;
        }];
        [self.uploadTaskDic safe_setObject:put forKey:imageId];
    });
}



-(void)asyncUploadImageByObjectKey:(NSString*)objectKey
                           imageId:(NSString*)imageId
                        uploadImage:(UIImage*)image
                          progress:(void (^)(CGFloat progress))progress
                           success:(void (^)(void))success
                           failure:(void (^)(NSError * _Nonnull))failure{
    [self asyncUploadImageByObjectKey:objectKey imageId:imageId uploadData:UIImageJPEGRepresentation(image, 1.0f) progress:progress success:success failure:failure];
}
@end
