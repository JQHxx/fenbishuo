//
//  CTFImageUpload.h
//  ChalkTalks
//
//  Created by zingwin on 2020/1/10.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CTFImageUploadDelegate <NSObject>

//上传OSS过程中
- (void)uploadImageProgress:(UploadImageFileModel *)fileModel progress:(CGFloat)progress;

//Error != nil：图片检测失败 或者 上传OSS失败
//Error == nil：图片已经存在 或者 上传OSS成功
- (void)didFinishedUploadImage:(UploadImageFileModel *)fileModel error:(NSError * __nullable)error;
@end

@interface CTFImageUpload : NSObject
@property (nonatomic, weak) id<CTFImageUploadDelegate> delegate;

- (instancetype)initWithImage:(UIImage *)image
                     delegate:(id<CTFImageUploadDelegate>)delegate;
- (void)uploadImage;
@end

NS_ASSUME_NONNULL_END
