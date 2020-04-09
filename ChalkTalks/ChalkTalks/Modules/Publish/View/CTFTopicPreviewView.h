//
//  CTFTopicPreviewView.h
//  ChalkTalks
//
//  Created by vision on 2020/2/6.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTFQuestionsModel.h"

@protocol CTFTopicPreviewViewDelegate <NSObject>

//返回修改
- (void)topicPreviewViewDidBackAction;
//确认发布
- (void)topicPreviewViewSubmitTopic;

@end

@interface CTFTopicPreviewView : UIView

@property (nonatomic, weak )id<CTFTopicPreviewViewDelegate>delegate;

- (void)fillTopicData:(CTFQuestionsModel *)question;

@end

