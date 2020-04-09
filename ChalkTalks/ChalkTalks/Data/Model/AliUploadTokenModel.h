//
//  AliUploadTokenModel.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/13.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 阿里云上传图片的接口令牌Access
@interface AliUploadTokenModel : BaseModel
@property (nonatomic, copy) NSString *accessKeySecret;
@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *accessKeyId;
@property (nonatomic, assign) NSInteger accessExpiration;
@end

NS_ASSUME_NONNULL_END
