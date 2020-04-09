//
//  CTFAliOSSManager.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/23.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AliyunOSSiOS/AliyunOSSiOS.h>
#import "AliOSSTokenCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFAliOSSManager : NSObject


/// 更新阿里云的密钥和token  因为token存在有效期，最好每次更新token的时候，都调用一次
-(void)configAliOSSToken;



/// 上传图片
/// @param objectKey objectKey
/// @param imageId  imageId
/// @param imgData  图片data
/// @param progress 进度回调
/// @param success 成功回调
/// @param failure 失败回调
-(void)asyncUploadImageByObjectKey:(NSString*)objectKey
                           imageId:(NSString*)imageId
                        uploadData:(NSData*)imgData
                          progress:(void (^)(CGFloat progress))progress
                           success:(void (^)(void))success
                           failure:(void (^)(NSError * _Nonnull))failure;



/// 取消还未上传完成的图片
/// @param imageId imageId
-(void)cancelUploadByImageId:(NSString*)imageId;


//-(void)asyncUploadImageByObjectKey:(NSString*)objectKey
//                           imageId:(NSString*)imageId
//                       uploadImage:(UIImage*)image
//                          progress:(void (^)(CGFloat progress))progress
//                           success:(void (^)(void))success
//                           failure:(void (^)(NSError * _Nonnull))failure;
@end

NS_ASSUME_NONNULL_END
