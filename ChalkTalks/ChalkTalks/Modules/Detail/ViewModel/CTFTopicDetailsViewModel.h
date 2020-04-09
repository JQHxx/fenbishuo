//
//  CTFTopicDetailsViewModel.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/23.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseViewModel.h"
#import "CTFTopicInfoCellLayout.h"
#import "CTFAnswerDetailCellLayout.h"

typedef NS_ENUM(NSInteger, SectionTwoShowType) {
    SectionTwoShowType_Unknown = 0,
    SectionTwoShowType_AnswerList,  //显示所有回答
    SectionTwoShowType_MyAnswer,    //显示我的回答
    SectionTwoShowType_InAnswer,    //显示进入id的回答
};


NS_ASSUME_NONNULL_BEGIN

@interface CTFTopicDetailsViewModel : BaseViewModel
@property(nonatomic,strong) PagingModel *page;
@property(nonatomic,assign) NSInteger inAnswerId;
@property(nonatomic,readonly) SectionTwoShowType showAnswerType;

///初始化
-(instancetype)initWithTopicId:(NSInteger)questionId showAll:(BOOL)showAll;

/* ***话题相关*******/
///获取话题详情
-(void)obtianTopicDetailComplete:(AdpaterComplete)complete;

///当前话题
-(CTFTopicInfoCellLayout*)currentTopicDetailModel;

///话题数
-(NSInteger)numberTopic;

///是否本人话题
-(BOOL)isMyTopic;

///正在审核中的话题
-(BOOL)isReviewingTopic;

///正在审核中的观点
-(BOOL)isReviewingAnswer;

///观点
-(CTFAnswerDetailCellLayout*)answerModelForIndex:(NSInteger)index;

///处理过的：话题详情tableView中section==1使用的rowNumber
-(NSInteger)numberOfAnswerList;

///真实的回答列表数量
- (NSInteger)numberOfAnswer;

///用于删除cell
-(NSInteger)factNumberOfAnswerList;

-(void)fetchQuestionAnswersComplete:(AdpaterComplete)complete;

/// 获取单个观点详情
/// @param answerId 观点id
/// @param complete callback
-(void)obtainViewpointDetail:(NSInteger)answerId
                    complete:(AdpaterComplete)complete;


/// 当前登录用户是否回答过这个话题
-(BOOL)isMyAnswered;
-(NSInteger)myAnswerId;
-(BOOL)needShowFindMyAnswerBtn;

///删除回答
/// @param answerId  回答id
/// @param isMine 是否本人的
-(void)deleteAnswerWithAnswerId:(NSInteger)answerId isMine:(BOOL)isMine;


-(void)setSectionTwoShowType:(SectionTwoShowType)type;

///关注
-(void)followActionToUser:(NSInteger)userId
               needFollow:(BOOL)needFollow
                 complete:(AdpaterComplete)complete;

//话题投票
-(void)votersToQuestion:(NSInteger)questionId
               attitude:(NSString*)attitude
               complete:(AdpaterComplete)complete;


/// 删除自己的话题
/// @param questionId  questionId
/// @param complete cb
-(void)deleteTopic:(NSInteger)questionId
          complete:(AdpaterComplete)complete;


- (void)fetchAll_invitedUserListComplete:(AdpaterComplete)complete;
- (NSArray<UserModel *> *)query_invitedUserList;

@end

NS_ASSUME_NONNULL_END
