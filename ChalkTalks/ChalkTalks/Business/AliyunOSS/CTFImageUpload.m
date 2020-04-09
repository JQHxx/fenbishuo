//
//  CTFImageUpload.m
//  ChalkTalks
//
//  Created by zingwin on 2020/1/10.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFImageUpload.h"
#import "CTFAliOSSManager.h"
#import "APIs.h"

@interface CTFImageUpload()
@property (nonatomic, strong) CTFAliOSSManager *oSSManager;
@property (nonatomic, strong) UploadImageFileModel *fileModel;
@end

@implementation CTFImageUpload

- (instancetype)initWithImage:(UIImage *)image
                    delegate:(id<CTFImageUploadDelegate>)delegate {
    if (self = [super init]) {
        self.oSSManager = [[CTFAliOSSManager alloc] init];
        self.delegate = delegate;
        self.fileModel = [[UploadImageFileModel alloc] init];
        self.fileModel.localImage = image;
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.oSSManager = [[CTFAliOSSManager alloc] init];
    }
    return self;
}

- (void)uploadImage {
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        NSData *data = UIImageJPEGRepresentation(self.fileModel.localImage, 1.0);
        NSString *md5 = [OSSUtil dataMD5String:data];
        self.fileModel.localImgData = data;
        self.fileModel.imgMD5String = md5;
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self) return;
            @strongify(self);
            [self checkUploadImage];
        });
    });
}

- (void)checkUploadImage {
    CTRequest *request = [CTFFileApi checkUploadImage:self.fileModel.imgMD5String];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        if (!self) return;
        @strongify(self);
        if (isSuccess) {
            /* 阿里云上传图片的接口令牌Access */
            NSDictionary *uploadTokenDic = [data safe_objectForKey:@"uploadToken"];
            AliUploadTokenModel *aliOSSToken = [AliUploadTokenModel yy_modelWithJSON:uploadTokenDic];
            [AliOSSTokenCache saveAliUploadToken:aliOSSToken];
            
            /* 服务器关于该图片的信息 */
            NSDictionary *uploadFileDic = [data safe_objectForKey:@"uploadFile"];
            self.fileModel.status = [uploadFileDic safe_stringForKey:@"status"];
            self.fileModel.objectKey = [uploadFileDic safe_stringForKey:@"objectKey"];
            self.fileModel.imageId = [uploadFileDic safe_stringForKey:@"imageId"];
            
            self.fileModel.uploadCompleted = ![self.fileModel.status isEqualToString:@"init"];
            self.fileModel.uploadError = NO;
               
            if ([self.fileModel.status isEqualToString:@"init"]) {
                [self uploadImageToOSS];//未上传的图片上传到阿里云
            } else {
                //已上传的图片
                if ([self.delegate respondsToSelector:@selector(didFinishedUploadImage:error:)]) {
                    [self.delegate didFinishedUploadImage:self.fileModel error:nil];
                }
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(didFinishedUploadImage:error:)]) {
                [self.delegate didFinishedUploadImage:self.fileModel error:[self handlerError:error]];
            }
        }
       }];
}

- (void)uploadImageToOSS {
    [self.oSSManager configAliOSSToken];
    @weakify(self);
    [self.oSSManager asyncUploadImageByObjectKey:self.fileModel.objectKey
                                         imageId:self.fileModel.imageId
                                      uploadData:self.fileModel.localImgData
                                        progress:^(CGFloat progress) {
        if (!self) return;
        @strongify(self);
        self.fileModel.uploadProgress = progress;
        if ([self.delegate respondsToSelector:@selector(uploadImageProgress:progress:)]) {
            [self.delegate uploadImageProgress:self.fileModel progress:progress];
        }
    } success:^{
        if (!self) return;
        @strongify(self);
        self.fileModel.uploadCompleted = YES;
        self.fileModel.uploadProgress = 1.0f;
        if ([self.delegate respondsToSelector:@selector(didFinishedUploadImage:error:)]) {
            [self.delegate didFinishedUploadImage:self.fileModel error:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        if (!self) return;
        @strongify(self);
        self.fileModel.uploadError = YES;
        if ([self.delegate respondsToSelector:@selector(didFinishedUploadImage:error:)]) {
            [self.delegate didFinishedUploadImage:self.fileModel error:[self handlerError:error]];
        }
    }];
}

- (NSError *)handlerError:(NSError *)error {
    if (error) {
        if (error.code == NSURLErrorNotConnectedToInternet) {
            return [NSError errorWithDomain:@"" code:NSURLErrorNotConnectedToInternet userInfo:@{NSLocalizedDescriptionKey: @"请检查网络"}];
        } else if (error.code == NSURLErrorTimedOut) {
            return [NSError errorWithDomain:@"" code:NSURLErrorTimedOut userInfo:@{NSLocalizedDescriptionKey: @"网络错误，请检查网络后重试"}];
        } else if (error.code == 401 || error.code == 403 || error.code == 404) {
            return [NSError errorWithDomain:@"" code:error.code userInfo:@{NSLocalizedDescriptionKey: @"网络错误，请检查网络后重试"}];
        } else if (error.code == 500) {
             return [NSError errorWithDomain:@"" code:error.code userInfo:@{NSLocalizedDescriptionKey:kServerErrorTips}];
        } else if (error.code == 4011 || error.code == 4012 || error.code == 4013 ) {
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
            [userInfo safe_setObject:[error.userInfo safe_stringForKey:NSLocalizedDescriptionKey] forKey:NSLocalizedDescriptionKey];
            return [NSError errorWithDomain:@"" code:error.code userInfo:userInfo];
        } else {
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
            [userInfo safe_setObject:[error.userInfo safe_stringForKey:NSLocalizedDescriptionKey] forKey:NSLocalizedDescriptionKey];
            return [NSError errorWithDomain:@"" code:error.code userInfo:userInfo];
        }
    } else {
        return nil;
    }
}

@end
