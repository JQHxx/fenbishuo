//
//  UploadImageFileModel.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/13.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface UploadImageFileModel : BaseModel

/* 服务器返回的 */
@property (nonatomic, copy) NSString *status;   //init, success
@property (nonatomic, copy) NSString *objectKey;
@property (nonatomic, copy) NSString *imageId;

/* 通过服务器返回的数据，推导出来 */
@property (nonatomic, assign) CGFloat uploadProgress;//图片上传的进度
@property (nonatomic, assign) BOOL uploadCompleted;  //图片完成上传的标识
@property (nonatomic, assign) BOOL uploadError;      //图片上传发生错误的标识

@property (nonatomic, copy) NSString *imageUrl;

/* 本地需要上传的 */
@property (nonatomic, strong) UIImage  *localImage;  //image
@property (nonatomic, strong) NSData   *localImgData;//data_image
@property (nonatomic, strong) NSString *imgMD5String;//MD5(data_image)

@end

NS_ASSUME_NONNULL_END
