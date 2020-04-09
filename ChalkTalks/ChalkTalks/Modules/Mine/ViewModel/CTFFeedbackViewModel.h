//
//  CTFFeedbackViewModel.h
//  ChalkTalks
//
//  Created by vision on 2019/12/30.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseViewModel.h"


@interface CTFFeedbackViewModel : BaseViewModel

/// 提交反馈
/// @param content 反馈内容
/// @param imageIds 图片ids
/// @param email 邮箱
/// @param complete 回调
- (void)createFeedbackWithContent:(NSString *)content imageIds:(NSArray *)imageIds email:(NSString *)email complete:(AdpaterComplete)complete;

- (void)createComplainWithContent:(NSString *)content imageIds:(NSArray *)imageIds email:(NSString *)email complete:(AdpaterComplete)complete;

- (void)createReportsWithResourceId:(NSInteger)rescourceId resourceType:(NSString *)resourceType feedbackTitle:(NSString *)feedbackTitle Content:(NSString *)content imageIds:(NSArray *)imageIds email:(NSString *)email complete:(AdpaterComplete)complete;

@end

