//
//  CTFVersionModel.h
//  ChalkTalks
//
//  Created by vision on 2020/1/1.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFVersionModel : BaseModel

@property (nonatomic , copy) NSString              * status;       //skip：不需要更新update：需要更新forceUpdate：需要强制更新
@property (nonatomic , copy) NSString              * downloadUrl;  //目标下载链接
@property (nonatomic , copy) NSString              * content;      //目标更新细节描述
@property (nonatomic , copy) NSString              * version;       //目标版本名称
@property (nonatomic , copy) NSString              * storageSize;  //目标版本对应的 app存储大小, 单位 Mb
@property (nonatomic , copy) NSString              * versionCode;  //目标版本号

@end

NS_ASSUME_NONNULL_END
