//
//  CTFFileApi.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/13.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFFileApi.h"

//阿里云文件上传e文档
//https://help.aliyun.com/document_detail/32058.html?spm=a2c4g.11186623.6.1164.43d56affIMnaf3


static NSString *const api_v1_imagess = @"/api/v1/images";
static NSString * const api_v1_audio = @"/api/v1/audios";
static NSString * const api_v2_video_token = @"/api/v2/videos/token";

@implementation CTFFileApi
+ (CTRequest *)checkUploadImage:(NSString *)hash {
    NSDictionary *arg = @{
        @"hash": hash,
    };
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_v1_imagess argument:arg method:YTKRequestMethodPOST];
    return request;
}

+ (CTRequest *)checkUploadAudio:(NSString *)hash {
    return [[CTRequest alloc] initWithRequestUrl:api_v1_audio
                                        argument:@{ @"hash": hash }
                                          method:YTKRequestMethodPOST];
}

+ (CTRequest *)obtainImage:(NSString *)imageId {
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"%@/%@",api_v1_imagess,imageId] argument:nil method:YTKRequestMethodGET];
    return request;
}

+ (CTRequest *)getVideoToken:(NSString *)hash width:(NSInteger)width height:(NSInteger)height rotate:(NSInteger)rotate {
    NSDictionary *arg = @{
        @"hash": hash,
        @"width": @(width),
        @"height": @(height),
        @"rotate": @(rotate)
    };
    return [[CTRequest alloc] initWithRequestUrl:api_v2_video_token
                                        argument:arg
                                          method:YTKRequestMethodPOST];
}

@end
