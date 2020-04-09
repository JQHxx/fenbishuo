//
//  CTFFeedbackViewModel.m
//  ChalkTalks
//
//  Created by vision on 2019/12/30.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFFeedbackViewModel.h"
#import "CTFUtilsApi.h"

@implementation CTFFeedbackViewModel

#pragma mark -- 提交反馈

- (void)createFeedbackWithContent:(NSString *)content imageIds:(NSArray *)imageIds email:(NSString *)email complete:(AdpaterComplete)complete {
    CTRequest *request = [CTFUtilsApi creatFeedbakWithContent:content imageIds:imageIds feedbackType:@"feedback" email:email];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if (isSuccess) {
           complete(YES);
        } else {
            complete(NO);
        }
    }];
}

- (void)createComplainWithContent:(NSString *)content imageIds:(NSArray *)imageIds email:(NSString *)email complete:(AdpaterComplete)complete {
    CTRequest *request = [CTFUtilsApi creatFeedbakWithContent:content imageIds:imageIds feedbackType:@"complain" email:email];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if (isSuccess) {
           complete(YES);
        } else {
            complete(NO);
        }
    }];
}

- (void)createReportsWithResourceId:(NSInteger)rescourceId resourceType:(NSString *)resourceType feedbackTitle:(NSString *)feedbackTitle Content:(NSString *)content imageIds:(NSArray *)imageIds email:(NSString *)email complete:(AdpaterComplete)complete {
    CTRequest *request = [CTFUtilsApi reportContent:rescourceId resourceType:resourceType feedbackTitle:feedbackTitle content:content email:email imageIds:imageIds];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
       if (isSuccess) {
           complete(YES);
       } else {
           complete(NO);
       }
    }];
}

@end
