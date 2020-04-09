//
//  CTFCommentApi.m
//  ChalkTalks
//
//  Created by vision on 2019/12/24.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFCommentApi.h"


static NSString *const api_v1_answers = @"/api/v1/answers";
static NSString *const api_v1_comments = @"/api/v1/comments";

@implementation CTFCommentApi

#pragma mark 获取某个观点下的所有评论
+ (CTRequest *)requestCommentsListWithAnswerId:(NSInteger)answerId page:(NSInteger)page pageSize:(NSInteger)pageSize{
    NSDictionary *arg = @{
        @"page": @(page),
        @"pageSize": @(pageSize)
    };
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"%@/%ld/comments_tree",api_v1_answers,answerId] argument:arg method:YTKRequestMethodGET];
    return request;
}

#pragma mark 获取某评论下的所有子评论
+ (CTRequest *)requestSubCommentsListWithCommentId:(NSInteger)commentId page:(NSInteger)page pageSize:(NSInteger)pageSize{
    NSDictionary *arg = @{
        @"page": @(page),
        @"pageSize": @(pageSize)
    };
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"%@/%ld/child_comments",api_v1_comments,commentId] argument:arg method:YTKRequestMethodGET];
    return request;
}

#pragma mark  发布评论
+ (CTRequest *)creatCommentWithAnswerId:(NSInteger)answerId content:(NSString *)content{
    NSDictionary *arg = @{
        @"content": content,
    };
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"%@/%ld/comments",api_v1_answers,answerId] argument:arg method:YTKRequestMethodPOST];
    return request;
}

#pragma mark 回复评论
+ (CTRequest *)creatReplyWithCommentId:(NSInteger)commentId content:(NSString *)content{
    NSDictionary *arg = @{
        @"content": content,
    };
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"%@/%ld/reply",api_v1_comments,commentId] argument:arg method:YTKRequestMethodPOST];
    return request;
}

#pragma mark 删除评论
+ (CTRequest *)deleteCommentWithCommentId:(NSInteger)commentId{
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:[NSString stringWithFormat:@"%@/%ld",api_v1_comments, commentId] argument:nil method:YTKRequestMethodDELETE];
    return request;
}

#pragma mark  对评论进行投票
+ (CTRequest *)voteCommentWithCommentId:(NSInteger)commentId attitude:(NSString *)attitude{
    NSDictionary *arg = @{
        @"attitude": attitude
    };
    NSString *const url = [NSString stringWithFormat:@"%@/%ld/voters", api_v1_comments,commentId];
    CTRequest *request = [[CTRequest alloc] initWithRequestUrl:url argument:arg method:YTKRequestMethodPOST];
    return request;
}

@end
