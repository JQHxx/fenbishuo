//
//  PagingModel.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/6.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface PagingModel : BaseModel

//接口返回的数据
@property (nonatomic, assign) NSInteger total; //是指整个查询结果的总条数
@property (nonatomic, assign) NSInteger count; //前页的数据条数

//请求用
@property (nonatomic, assign) NSInteger page; //当前页码
@property (nonatomic, assign) NSInteger pageSize; //每页放回的数量

@end

NS_ASSUME_NONNULL_END
