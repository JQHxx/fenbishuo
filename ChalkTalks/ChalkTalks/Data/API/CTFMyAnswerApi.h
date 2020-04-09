//
//  CTFMyAnswerApi.h
//  ChalkTalks
//
//  Created by vision on 2019/12/27.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFMyAnswerApi : NSObject

/*
 * 获取我的观点
 * @param sort 排序方式 【createdAt：该观点创建时间】、【questionVoted：所属话题的投票关心量】
 * @param page 页码
 * @param pageSize 每页个数
 */
+ (CTRequest *)requestMyAnswersDataWithSort:(NSString *)sort page:(NSInteger)page pageSize:(NSInteger)pageSize;


@end

NS_ASSUME_NONNULL_END
