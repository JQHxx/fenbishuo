//
//  CTFTopicDetailsViewModel.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/23.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFTopicDetailsViewModel.h"
#import "APIs.h"

@interface CTFTopicDetailsViewModel()
@property(nonatomic,assign) NSInteger questionId;
@property(nonatomic,strong) CTFTopicInfoCellLayout *questionModel;
@property(nonatomic,strong) NSMutableArray<CTFAnswerDetailCellLayout*> *answerList;
@property(nonatomic,strong) CTFAnswerDetailCellLayout *myAnswerLayout;
@property(nonatomic,strong) CTFAnswerDetailCellLayout *inAnswerLayout;

@property(nonatomic,assign) BOOL isContainMyAnswer;
@property(nonatomic,assign) SectionTwoShowType showAnswerType;

@property (nonatomic,assign) BOOL   showAll;

@property (nonatomic, strong) NSMutableArray<UserModel *> *modelList_invitedUserList;//被邀请的用户列表

@end

@implementation CTFTopicDetailsViewModel
-(instancetype)initWithTopicId:(NSInteger)questionId showAll:(BOOL)showAll{
    self = [super init];
    if (self) {
        self.questionId = questionId;
        self.page = [[PagingModel alloc] init];
        self.page.page = 1;
        self.page.pageSize = 16;
        self.answerList = [[NSMutableArray alloc] init];
        self.showAnswerType = SectionTwoShowType_Unknown;
        self.showAll = showAll;
        self.modelList_invitedUserList = [NSMutableArray array];
    }
    return self;
}
 
/* 获取话题详情数据 */
- (void)obtianTopicDetailComplete:(AdpaterComplete)complete {
    CTRequest *request = [CTFTopicApi questionDetail:self.questionId];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if (isSuccess) {
            CTFQuestionsModel *item = [CTFQuestionsModel yy_modelWithJSON:data];
            item.showAll = self.showAll;
            
            self.questionModel = [[CTFTopicInfoCellLayout alloc] initWithData:item];
            self.isContainMyAnswer = self.questionModel.model.myAnswer.answerId != 0;
            complete(YES);
        } else {
            complete(NO);
        }
    }];
}

-(CTFTopicInfoCellLayout*)currentTopicDetailModel{
    return self.questionModel;
}

-(BOOL)isMyTopic{
    return self.questionModel.model.isAuthor;
}
-(BOOL)isReviewingTopic{
    if(self.questionModel){
        if(![self.questionModel.model.status isEqualToString:@"normal"]) return YES;
    }
    return NO;
}

-(BOOL)isReviewingAnswer {
    if (self.inAnswerLayout) {
        if (![self.inAnswerLayout.model.status isEqualToString:@"normal"]) return YES;
    }
    return NO;
}

// 获取某个话题下的所有回答列表数据（分页）
- (void)fetchQuestionAnswersComplete:(AdpaterComplete)complete {
    CTRequest *request = [CTFTopicApi getQuestionAnswers:self.questionId page:self.page.page pageSize:self.page.pageSize];
    
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if(isSuccess){
            NSDictionary *paging = [data safe_objectForKey:@"paging"];
            self.page.total = [paging safe_integerForKey:@"total"];
                     
            NSDictionary *answers = [[data safe_objectForKey:@"data"] safe_objectForKey:@"answers"];
            NSArray *answersArr = [NSArray yy_modelArrayWithClass:[AnswerModel class] json:answers];
            NSMutableArray *l = [[NSMutableArray alloc] init];
            for (AnswerModel *model in answersArr) {
                CTFQuestionsModel *questionModel = [self currentTopicDetailModel].model;
                QuestionModel *question = [[QuestionModel alloc] init];
                question.questionId = questionModel.questionId;
                question.idString = questionModel.idString;
                question.title = questionModel.title;
                model.question = question;
                [l addObject:model];
            }
            NSArray *list = [CTFAnswerDetailCellLayout converToLayout:l];
            if(self.page.page == 1){
                [self.answerList removeAllObjects];
            }
            [self.answerList addObjectsFromArray:list];
            
            complete(YES);
        }else{
            self.page.page--;
            complete(NO);
        }
    }];

}

-(BOOL)hasMoreData{
    return self.page.total > self.answerList.count;
}
-(BOOL)isEmpty{
    return self.answerList.count == 0;
}

-(NSInteger)numberOfAnswerList{
    if (self.errorType != UNERROR) {
        return 0;
    }
    if (([self isReviewingTopic] && ![self isMyTopic])||(self.inAnswerId > 0 && [self isReviewingAnswer])) {
        return 0;
    }
    
    if (self.showAnswerType == SectionTwoShowType_AnswerList) {//显示所有回答
        return [self.answerList count] == 0 ? 1 : [self.answerList count]; //1:显示没有观点cell
        
    } else if (self.showAnswerType == SectionTwoShowType_InAnswer) {//显示进入id的回答
        if (self.questionModel.model.answerCount > 1) {/* 如果只有一个回答，就不用showAll */
            return self.inAnswerLayout ? 2 : 1;  //+1：showall  nil:显示没有观点cell
        } else {
            return self.inAnswerLayout ? 1 : 1;  //+1：showall  nil:显示没有观点cell
        }
        
    } else if (self.showAnswerType == SectionTwoShowType_MyAnswer) {//显示我的回答
        if (self.questionModel.model.answerCount > 1) {/* 如果只有一个回答，就不用showAll */
            return self.myAnswerLayout ? 2 : 1;//+1：showall  nil:显示没有观点cell
        } else {
            return self.myAnswerLayout ? 1 : 1;//+1：showall  nil:显示没有观点cell
        }
    }
    return 0;
}

- (NSInteger)numberOfAnswer {
    return [self numberOfAnswerList] - 1;
}

-(NSInteger)factNumberOfAnswerList{
    if(self.errorType != UNERROR){
        return 0;
    }
    if(self.showAnswerType == SectionTwoShowType_AnswerList){
        return [self.answerList count];
    }else if (self.showAnswerType == SectionTwoShowType_InAnswer){
        return self.inAnswerLayout ? 1 : 0;
    }else if(self.showAnswerType == SectionTwoShowType_MyAnswer){
        return self.myAnswerLayout ? 1 : 0;
    }
    return 0;
}

- (NSInteger)numberTopic {
    if (self.errorType != UNERROR) {
        return 0;
    }
    
    if (self.questionModel == nil) {
        return 0;
    }
    
    if (([self isReviewingTopic] && ![self isMyTopic])||(self.inAnswerId > 0 && [self isReviewingAnswer])) {
        return 0;
    }
    
    return 1;
}

-(BOOL)needShowFindMyAnswerBtn{
    if(self.inAnswerId != 0 && [self myAnswerId] == self.inAnswerId){
        return NO;
    }
    return YES;
}

-(CTFAnswerDetailCellLayout*)answerModelForIndex:(NSInteger)index{
    if (self.showAnswerType == SectionTwoShowType_AnswerList){
         return [self.answerList safe_objectAtIndex:index];
     } else if (self.showAnswerType == SectionTwoShowType_InAnswer){
         if(index == 0){
             return self.inAnswerLayout;
         }
         CTFAnswerDetailCellLayout *layout = [[CTFAnswerDetailCellLayout alloc] init];
         layout.model = [[AnswerModel alloc] init];
         layout.model.type = @"showall";
         layout.height = 50.0f;
         return layout;
     } else if(self.showAnswerType == SectionTwoShowType_MyAnswer){
         if(index == 0){
             return self.myAnswerLayout;
         }
         CTFAnswerDetailCellLayout *layout = [[CTFAnswerDetailCellLayout alloc] init];
         layout.model = [[AnswerModel alloc] init];
         layout.model.type = @"showall";
         layout.height = 50.0f;
         return layout;
     }
    return nil;
}

#pragma mark 获取单个观点详情
-(void)obtainViewpointDetail:(NSInteger)answerId
                    complete:(AdpaterComplete)complete{
    if(!answerId) {complete(YES);return;};
    
    CTRequest *request = [FeedApi getViewpointDetail:answerId];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if(isSuccess){
            CTFQuestionsModel *model = [self currentTopicDetailModel].model;
            AnswerModel *item = [AnswerModel yy_modelWithJSON:data];
            QuestionModel *question = [[QuestionModel alloc] init];
            question.questionId = model.questionId;
            question.title = model.title;
            question.idString = model.idString;
            item.question = question;
            if(self.showAnswerType == SectionTwoShowType_MyAnswer){
                self.myAnswerLayout = [[CTFAnswerDetailCellLayout alloc] initWithData:item];
            }else{
                self.inAnswerLayout = [[CTFAnswerDetailCellLayout alloc] initWithData:item];
            }
            complete(YES);
        }else{
            complete(NO);
        }
    }];
}

#pragma mark 当前话题下，是否有当前用户自己的回答
-(BOOL)isMyAnswered{
    return self.isContainMyAnswer;
}

#pragma mark 返回关于某个话题下我的回答ID
- (NSInteger)myAnswerId {
    return self.currentTopicDetailModel.model.myAnswer.answerId;
}

#pragma mark 删除回答
-(void)deleteAnswerWithAnswerId:(NSInteger)answerId isMine:(BOOL)isMine{
    if(self.myAnswerLayout.model.answerId == answerId){
        self.myAnswerLayout = nil;
    }
    
    if(self.inAnswerLayout.model.answerId == answerId){
        self.inAnswerLayout = nil;
    }
    
    CTFAnswerDetailCellLayout *target = nil;
    for(CTFAnswerDetailCellLayout *item in self.answerList){
        if(item.model.answerId == answerId){
            target = item;
            break;
        }
    }
    [self.answerList removeObject:target];
    
    if (isMine) {
        self.isContainMyAnswer = NO;
    }
}

-(void)setSectionTwoShowType:(SectionTwoShowType)type{
    self.showAnswerType = type;
}

-(void)followActionToUser:(NSInteger)userId
               needFollow:(BOOL)needFollow
                    complete:(AdpaterComplete)complete{
    CTRequest *request;
    if(needFollow){
         request = [CTFMineApi followToUser:userId];
    }else{
         request = [CTFMineApi unfollowerToUser:userId];
    }
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if(isSuccess){
            if (needFollow) {
                [[CTPushManager share] showAuthReqAlertIfNeed];
            }
            complete(YES);
        }else{
            complete(NO);
        }
    }];
}

-(void)votersToQuestion:(NSInteger)questionId
                  attitude:(NSString*)attitude
                  complete:(AdpaterComplete)complete{
    CTRequest *request = [CTFVoteApi voteQuestionId:questionId toState:attitude];
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        if (isSuccess) {
            if(complete) complete(YES);
        }else {
            if(complete) complete(NO);
        }
    }];
}

-(void)deleteTopic:(NSInteger)questionId
                  complete:(AdpaterComplete)complete{
    CTRequest *request = [CTFTopicApi deleteQuestion:questionId];
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        [self handlerError:error];
        if (isSuccess) {
            if(complete) complete(YES);
        }else {
            if(complete) complete(NO);
        }
    }];
}

- (void)fetchAll_invitedUserListComplete:(AdpaterComplete)complete {
    CTRequest *request = [CTFTopicApi inviteUserForQuestionId:self.questionId];
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        [self handlerError:error];
        if (isSuccess) {
            NSArray *userList = data;
            NSArray<UserModel *> *userModelList = [NSArray yy_modelArrayWithClass:[UserModel class] json:userList];
            if (userModelList) {
                [self.modelList_invitedUserList setArray:userModelList];
            }
            if(complete) complete(YES);
        }else {
            if(complete) complete(NO);
        }
    }];
}

- (NSArray<UserModel *> *)query_invitedUserList {
    return self.modelList_invitedUserList;
}

@end
