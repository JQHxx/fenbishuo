//
//  CTFTopicApi.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/13.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CTRequest.h"

NS_ASSUME_NONNULL_BEGIN

/// 话题、观点相关的接口API
@interface CTFTopicApi : NSObject

/* =================【话题】=================== */
///获取话题标题的后缀
+ (CTRequest *)requestTopicSuffixTitles;

/// 创建话题
/// @param type 话题类型 求推荐：recommend，提要求：demand
/// @param title 话题标题
/// @param suffixId 标题后缀Id type=demand时必填
/// @param content 话题说明
/// @param imageIds 话题图片ids
+ (CTRequest *)creatQuestionWithType:(NSString *)type
                               title:(NSString *)title
                              suffix:(NSInteger )suffixId
                             content:(NSString *)content
                            imageIds:(NSArray *)imageIds;


/// 修改话题
/// @param questionId 话题id
/// @param type 话题类型
/// @param title 话题标题
/// @param suffixId 标题后缀id
/// @param content 话题说明
/// @param imageIds 话题图片ids
+ (CTRequest *)modifyQuestionWithId:(NSInteger)questionId
                              type:(NSString *)type
                             title:(NSString *)title
                            suffix:(NSInteger )suffixId
                           content:(NSString *)content
                          imageIds:(NSArray *)imageIds;


/// 删除话题
/// @param questionId 话题id
+ (CTRequest *)deleteQuestion:(NSInteger)questionId;


/// 获取话题详情
/// @param questionId 话题ID
+ (CTRequest *)questionDetail:(NSInteger)questionId;


/// 发布话题后邀请到的用户列表
/// @param questionId 话题ID
+ (CTRequest *)inviteUserForQuestionId:(NSInteger)questionId;

/* =================【观点】=================== */

/// 创建观点
/// @param quesionId 话题ID
/// @param content 内容
/// @param videoId 视频ID
/// @param imageIds 图片ID数组
/// @param type 观点类别 images:图片 video:视频
/// @param coverImageId 视频封面图片ID
+ (CTRequest *)creatAnswers:(NSInteger)quesionId
                    content:(NSString *)content
                    videoId:(nullable NSString *)videoId
                   imageIds:(nullable NSArray *)imageIds
                       type:(NSString *)type
          videoCoverImageId:(nullable NSString *)coverImageId;


/// 创建观点（回复话题）
/// @param questionId 话题ID
/// @param param 创建观点所需要的参数
+ (CTRequest *)createAnswer:(NSInteger)questionId
             withParameters:(NSDictionary *)param;


/// 修改观点
/// @param answerId 观点ID
/// @param content 观点文本内容
/// @param imageIds 图片ID列表
+ (CTRequest *)changeAnswer:(NSInteger)answerId
                    content:(NSString *)content
                   imageIds:(nullable NSArray *)imageIds;


/// 获取话题下面的所有观点（回答）
/// @param questionId 话题id
/// @param page 当前页
/// @param pageSize 页数
+ (CTRequest *)getQuestionAnswers:(NSInteger)questionId
                             page:(NSInteger)page
                         pageSize:(NSInteger)pageSize;

@end

NS_ASSUME_NONNULL_END
