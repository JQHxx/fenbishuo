//
//  CTFAnswerHandleView.h
//  ChalkTalks
//
//  Created by vision on 2020/2/27.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CTFAnswerHandleViewTypeHome,           //首页
    CTFAnswerHandleViewTypeTopicDetails,   //话题详情
    CTFAnswerHandleViewTypeMyAnswer,       //我的回答
    CTFAnswerHandleViewTypeHomepage,       //个人主页
} CTFAnswerHandleViewType;

/* 例如用在首页cell中“更多+评论+靠谱+不靠谱”view */
@interface CTFAnswerHandleView : UIView

@property (nonatomic,assign) CTFAnswerHandleViewType type;

- (void)fillAnswerData:(AnswerModel *)answerModel indexPath:(NSIndexPath *)indexPath;


@end

