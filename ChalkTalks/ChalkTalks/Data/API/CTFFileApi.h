//
//  CTFFileApi.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/13.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFFileApi : NSObject

/// 上传文件之前先检查文件
/// @param hash file md5
+ (CTRequest *)checkUploadImage:(NSString*)hash;

/// 上传文件之前先检查文件
/// @param hash file md5
+ (CTRequest *)checkUploadAudio:(NSString*)hash;

/// 获取图片的详细信息
/// @param imageId 图片详细信息  包含 url
+ (CTRequest *)obtainImage:(NSString*)imageId;

/// 获取七牛云视频上传token
/// @param hash 源视频HASH
+ (CTRequest *)getVideoToken:(NSString *)hash width:(NSInteger)width height:(NSInteger)height rotate:(NSInteger)rotate;

@end

NS_ASSUME_NONNULL_END
