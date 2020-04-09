//
//  CTFTopicApi.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/13.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFTopicApi.h"

static NSString * const api_v1_questions = @"/api/v1/questions";
static NSString * const api_v2_questions = @"/api/v2/questions";
static NSString * const api_v3_questions = @"/api/v3/questions";
static NSString * const api_v4_questions = @"/api/v4/questions";

@implementation CTFTopicApi

+ (NSArray *)sortImageIds:(NSArray *)imageIds {
    if (imageIds && [imageIds count]) {
        NSMutableArray *mimageIds = [[NSMutableArray alloc] init];
        NSInteger count = 0;
        for (NSString *imgID in imageIds) {
            [mimageIds addObject:[NSString stringWithFormat:@"%zd-%@",count, imgID]];
            count++;
        }
        return mimageIds;
    }
    return nil;
}

#pragma mark - 话题
#pragma mark 获取话题标题的后缀
+ (CTRequest *)requestTopicSuffixTitles {
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:@"/api/v1/question/title/suffixes" argument:nil method:YTKRequestMethodGET];
    return request;
}

#pragma mark 创建话题
+ (CTRequest *)creatQuestionWithType:(NSString *)type
                               title:(NSString *)title
                              suffix:(NSInteger)suffixId
                             content:(NSString *)content
                            imageIds:(NSArray *)imageIds {
    
    NSMutableDictionary *arg = [[NSMutableDictionary alloc] init];
    [arg safe_setValue:type forKey:@"type"];
    [arg safe_setValue:title forKey:@"shortTitle"];
    [arg safe_setValue:@(suffixId) forKey:@"titleSuffixId"];
    [arg safe_setValue:content forKey:@"content"];
    [arg safe_setObject:[[self class] sortImageIds:imageIds] forKey:@"imageIds"];
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:api_v4_questions argument:arg method:YTKRequestMethodPOST];
    return request;
}

#pragma mark 修改话题
+ (CTRequest *)modifyQuestionWithId:(NSInteger)questionId
                               type:(NSString *)type
                              title:(NSString *)title
                             suffix:(NSInteger )suffixId
                            content:(NSString *)content
                           imageIds:(NSArray *)imageIds {
    
    NSMutableDictionary *arg = [[NSMutableDictionary alloc] init];
    [arg safe_setValue:type forKey:@"type"];
    [arg safe_setValue:title forKey:@"shortTitle"];
    [arg safe_setValue:@(suffixId) forKey:@"titleSuffixId"];
    [arg safe_setValue:content forKey:@"content"];
    [arg safe_setObject:[[self class] sortImageIds:imageIds] forKey:@"imageIds"];
    
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"%@/%ld",api_v4_questions, questionId] argument:arg method:YTKRequestMethodPUT];
    return request;
}

#pragma mark 删除话题
+ (CTRequest *)deleteQuestion:(NSInteger)questionId {
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"%@/%ld",api_v1_questions, questionId] argument:nil method:YTKRequestMethodDELETE];
    return request;
}

#pragma mark 获取话题详情
+ (CTRequest *)questionDetail:(NSInteger)questionId {
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"%@/%ld",api_v1_questions, questionId] argument:nil method:YTKRequestMethodGET];
    return request;
}

#pragma mark 发布话题后邀请到的用户列表
+ (CTRequest *)inviteUserForQuestionId:(NSInteger)questionId {
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"%@/%ld/invitees",api_v1_questions, questionId] argument:nil method:YTKRequestMethodGET];
    return request;
}

#pragma mark - 观点
#pragma mark 创建观点
+ (CTRequest *)creatAnswers:(NSInteger)quesionId
                    content:(NSString *)content
                    videoId:(NSString *)videoId
                   imageIds:(NSArray *)imageIds
                       type:(NSString *)type
          videoCoverImageId:(NSString *)coverImageId {
    
    NSMutableDictionary *arg = [[NSMutableDictionary alloc] init];
    
    [arg safe_setObject:content forKey:@"content"];
    [arg safe_setObject:videoId forKey:@"videoId"];
    [arg safe_setObject:type forKey:@"type"];
    [arg safe_setObject:coverImageId forKey:@"coverImageId"];
    [arg safe_setObject:[[self class] sortImageIds:imageIds] forKey:@"imageIds"];
    
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"%@/%zd/answers",api_v2_questions, quesionId] argument:arg method:YTKRequestMethodPOST];
     return request;
}

#pragma mark 创建观点（回复话题）
+ (CTRequest *)createAnswer:(NSInteger)questionId withParameters:(NSDictionary *)param {
    CTRequest *request = [[CTRequest alloc]
                          initWithRequestUrl:[NSString stringWithFormat:@"%@/%zd/answers",api_v2_questions, questionId]
                          argument:param
                          method:YTKRequestMethodPOST];
    return request;
}

#pragma mark 修改观点
+ (CTRequest *)changeAnswer:(NSInteger)answerId
                    content:(NSString *)content
                   imageIds:(NSArray *)imageIds {
    NSMutableDictionary *arg = [[NSMutableDictionary alloc] init];
    [arg safe_setObject:content forKey:@"content"];
    [arg safe_setObject:[[self class] sortImageIds:imageIds] forKey:@"imageIds"];
    
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"/api/v1/answers/%ld", (long)answerId]
                                                      argument:arg
                                                        method:YTKRequestMethodPUT];
    return request;
}

#pragma mark 获取话题下面的所有观点（回答）
+ (CTRequest *)getQuestionAnswers:(NSInteger)questionId
                             page:(NSInteger)page
                         pageSize:(NSInteger)pageSize {
    NSDictionary *arg = @{
        @"page": @(page),
        @"pageSize": @(pageSize)
    };
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"%@/%ld/answers",api_v2_questions, questionId] argument:arg method:YTKRequestMethodGET];
    return request;
}

@end
