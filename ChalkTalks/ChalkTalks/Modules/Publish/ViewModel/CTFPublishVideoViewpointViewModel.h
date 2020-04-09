//
//  CTFPublishVideoViewpointViewModel.h
//  ChalkTalks
//
//  Created by zingwin on 2020/1/9.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "BaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFPublishVideoViewpointViewModel : BaseViewModel

@property(nonatomic, assign) NSInteger quesionId;

-(instancetype)initWithQuesionId:(NSInteger)quesionId;

-(void)createVideoAnswert:(NSString*)content
                  videoId:(NSString*)videoId
        videoCoverImageId:(NSString*)videoCoverImageId
                 complete:(AdpaterComplete)complete;

-(NSInteger)currentAnswerId;
@end

NS_ASSUME_NONNULL_END
