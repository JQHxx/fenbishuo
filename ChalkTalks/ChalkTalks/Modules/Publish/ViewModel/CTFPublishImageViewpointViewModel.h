//
//  CTFPublishImageViewpointViewModel.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/25.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseViewModel.h"
#import <AliyunOSSiOS/OSSService.h>
#import "APIs.h"
#import "AliOSSTokenCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFPublishImageViewpointViewModel : BaseViewModel

@property(nonatomic, assign) NSInteger quesionId;

-(instancetype)initWithQuesionId:(NSInteger)quesionId;

/// 发布观点
- (void)publishAnswer:(NSString*)content
             oldAnswerModel:(AnswerModel *)oldModel
             imageIds:(NSArray*)imageIds
             complete:(AdpaterComplete)complete;

-(NSInteger)currentAnswerId;
@end

NS_ASSUME_NONNULL_END
