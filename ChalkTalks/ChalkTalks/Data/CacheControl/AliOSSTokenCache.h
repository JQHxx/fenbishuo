//
//  AliOSSTokenCache.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/13.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseModel.h"
#import "CTModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface AliOSSTokenCache : BaseModel

/// 缓存阿里OSS上传token
/// @param aliToken 接口返回的model
+(void)saveAliUploadToken:(AliUploadTokenModel*)aliToken;



/// token 存在有效期，过期返回nil
+(AliUploadTokenModel*)getAliUploadToken;
@end

NS_ASSUME_NONNULL_END
