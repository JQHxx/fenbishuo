//
//  CTFActivityModel.h
//  ChalkTalks
//
//  Created by vision on 2019/12/26.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseModel.h"
#import "AnswersModel.h"
#import "CTFQuestionsModel.h"
#import "CTFMyAnswerCellLayout.h"



NS_ASSUME_NONNULL_BEGIN

@interface CTFActivityModel : BaseModel

@property (nonatomic , assign) NSInteger       id;
@property (nonatomic , assign) NSInteger       resourceId;
@property (nonatomic , assign) long            createdAt;
@property (nonatomic , copy )  NSString        *resourceType; //question|answer)
@property (nonatomic , copy )  NSString        *actionText;   //USER_CREATE_ANSWER|USER_CREATE_QUESTIN|USER_VOTEUP_ANSWER|USER_FOLLOW_QUESTION
@property (nonatomic , copy )  NSString        *action;  //发布了话题|关心了话题|赞了观点|回复了话题
@property (nonatomic , strong) CTFQuestionsModel   *question;
@property (nonatomic , strong) AnswerModel     *answer;

@property (nonatomic , strong) CTFMyAnswerCellLayout *feedCellLayout;


@end

NS_ASSUME_NONNULL_END
