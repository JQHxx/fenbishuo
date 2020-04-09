//
//  CTFQuestionsModel.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/11.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface Author : BaseModel
@property (nonatomic , assign) NSInteger              authorId;
@property (nonatomic , copy) NSString              * avatarUrl;
@property (nonatomic , copy) NSString              * headline;
@property (nonatomic , copy) NSString              * name;
@property (nonatomic , copy) NSString              * city;
@property (nonatomic , copy) NSString              * gender;

@end

@interface CTFQuestionsModel : BaseModel

@property (nonatomic , assign) NSInteger           idString;
@property (nonatomic ,  copy ) NSString            *title;    //完整标题
@property (nonatomic ,  copy ) NSString            *shortTitle; //标题
@property (nonatomic , assign) NSInteger           titleSuffixId; //后缀id
@property (nonatomic ,  copy ) NSString            *suffix; //前缀或后缀
@property (nonatomic ,  copy ) NSString            *type; //话题类型 recommend求推荐 demand提要求
@property (nonatomic , assign) NSInteger           createdAt;
@property (nonatomic , assign) NSInteger           answerCount; //所拥有的观点数(回复数)
@property (nonatomic , assign) NSInteger           voteupCount;
@property (nonatomic , assign) NSInteger           votedownCount;
@property (nonatomic ,  copy ) NSString            *attitude;
@property (nonatomic , assign) NSInteger           questionId;
@property (nonatomic , strong) Author              *author;
@property (nonatomic , assign) NSInteger           votedAt;
@property (nonatomic , assign) BOOL                isAuthor;
@property (nonatomic , strong) AnswerModel         *myAnswer;
@property (nonatomic ,  copy ) NSString            *summary;
@property (nonatomic ,  copy ) NSString            *content;
@property (nonatomic , strong) NSArray <ImageItemModel *>   *images;
@property (nonatomic ,  copy ) NSString            *status;   //init:初始状态；reviewing:正在审核中;failed:转码失败;normal：正常状态 ；blocked:已拉黑
@property (nonatomic, assign) BOOL                 showAll;

@property (nonatomic , assign) CGFloat              maxAttention;
@property (nonatomic , assign) CGFloat              attention;
@property (nonatomic , assign) CGFloat              referenceValue;

@end

NS_ASSUME_NONNULL_END
