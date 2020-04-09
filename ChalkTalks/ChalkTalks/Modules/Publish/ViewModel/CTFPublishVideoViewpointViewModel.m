//
//  CTFPublishVideoViewpointViewModel.m
//  ChalkTalks
//
//  Created by zingwin on 2020/1/9.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFPublishVideoViewpointViewModel.h"
@interface CTFPublishVideoViewpointViewModel()

@property(nonatomic, assign) NSInteger publishAnswerId;

@end

@implementation CTFPublishVideoViewpointViewModel
-(instancetype)initWithQuesionId:(NSInteger)quesionId{
    self = [super init];
    if (self) {
        self.quesionId = quesionId;
    }
    return self;
}
-(void)createVideoAnswert:(NSString*)content
                 videoId:(NSString*)videoId
        videoCoverImageId:(NSString*)videoCoverImageId
                 complete:(AdpaterComplete)complete{
    CTRequest *request = [CTFTopicApi creatAnswers:self.quesionId content:content videoId:videoId imageIds:nil type:@"video" videoCoverImageId:videoCoverImageId];
    
     @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
         @strongify(self);
        [self handlerError:error];
        if(isSuccess){
            self.publishAnswerId = [data safe_integerForKey:@"id"];
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
