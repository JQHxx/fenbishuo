//
//  CTFPublishImageViewpointViewModel.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/25.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFPublishImageViewpointViewModel.h"
@interface CTFPublishImageViewpointViewModel()

@property(nonatomic, assign) NSInteger publishAnswerId;

@end

@implementation CTFPublishImageViewpointViewModel
{
}

-(instancetype)initWithQuesionId:(NSInteger)quesionId{
    self = [super init];
    if (self) {
        self.quesionId = quesionId;
    }
    return self;
}

- (void)publishAnswer:(NSString*)content
             oldAnswerModel:(AnswerModel *)oldModel
             imageIds:(NSArray*)imageIds
             complete:(AdpaterComplete)complete {
    CTRequest *request;
    if (oldModel&&oldModel.answerId>0) {
        request = [CTFTopicApi changeAnswer:oldModel.answerId
         content:content
        imageIds:imageIds];
        
    } else {
        request = [CTFTopicApi creatAnswers:self.quesionId
                  content:content
                  videoId:nil
                 imageIds:imageIds
                     type:@"images"
        videoCoverImageId:nil];
    }
    
     @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if(isSuccess){
            if (oldModel == nil) {
                self.publishAnswerId = [data safe_integerForKey:@"id"];
            } else {
                self.publishAnswerId = oldModel.answerId;
            }
            complete(YES);
        }else{
            complete(NO);
        }
    }];
}

-(NSInteger)currentAnswerId{
    return  self.publishAnswerId;
}
@end
