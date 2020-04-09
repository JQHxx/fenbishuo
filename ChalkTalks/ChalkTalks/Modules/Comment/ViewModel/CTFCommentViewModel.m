//
//  CTFCommentViewModel.m
//  ChalkTalks
//
//  Created by vision on 2019/12/24.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFCommentViewModel.h"
#import "CTFCommentApi.h"
#import "CTFUtilsApi.h"

@interface CTFCommentViewModel ()

@property (nonatomic, strong) NSMutableArray  *commentsList;
@property (nonatomic, strong) NSMutableArray  *subCommentsList;
@property (nonatomic, assign) NSInteger       answerId;
@property (nonatomic, strong) PagingModel     *commentPagingModel;
@property (nonatomic, strong) PagingModel     *detailsPageModel;
@property (nonatomic, assign) NSInteger       commentCount;

@property (nonatomic, strong) NSMutableArray  *tempCommentsArray;
@property (nonatomic, strong) NSMutableArray  *tempSubCommentsArray;

@end

@implementation CTFCommentViewModel

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(instancetype)initWithAnswerId:(NSInteger)answerId{
    self = [super init];
    if (self) {
        self.answerId = answerId;
        [self setupUI];
    }
    return self;
}

#pragma mark 初始化
- (void)setupUI{
    self.commentsList = [[NSMutableArray alloc] init];
    self.subCommentsList = [[NSMutableArray alloc] init];
    self.tempCommentsArray = [[NSMutableArray alloc] init];
    self.tempSubCommentsArray = [[NSMutableArray alloc] init];
    self.commentPagingModel = [[PagingModel alloc] init];
    self.detailsPageModel = [[PagingModel alloc] init];
}

#pragma mark 加载评论数据
-(void)loadCommentsListByPage:(PagingModel *)page complete:(AdpaterComplete)complete{
    CTRequest *request = [CTFCommentApi requestCommentsListWithAnswerId:self.answerId page:page.page pageSize:page.pageSize];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if (isSuccess) {
            NSDictionary *paging = [data safe_objectForKey:@"paging"];
            self.commentPagingModel.total = [paging safe_integerForKey:@"total"];
            self.commentPagingModel.count = [paging safe_integerForKey:@"count"];
            
            self.commentCount = [data safe_integerForKey:@"answerCommentCounts"];
            
            NSArray *comments = [data safe_objectForKey:@"data"];
            NSArray *arr = [NSArray yy_modelArrayWithClass:[CTFCommentModel class] json:comments];
            NSMutableArray *tempArr = [self filterCommentsData:arr tempArr:self.tempCommentsArray];
            if (page.page == 1) {
                [self.commentsList removeAllObjects];
            }
            [self.commentsList safe_addObjectsFromArray:tempArr];
            if (complete) complete(YES);
        }else{
            if (complete) complete(NO);
        }
    }];
}

#pragma mark 加载某评论下所有子评论
- (void)loadSubCommentsDataByPage:(PagingModel *)pageModel commentId:(NSInteger)commentId complete:(AdpaterComplete)complete{
    CTRequest *request = [CTFCommentApi requestSubCommentsListWithCommentId:commentId page:pageModel.page pageSize:pageModel.pageSize];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if (isSuccess) {
            NSDictionary *paging = [data safe_objectForKey:@"paging"];
            self.detailsPageModel.total = [paging safe_integerForKey:@"total"];
            self.detailsPageModel.count = [paging safe_integerForKey:@"count"];
            
            NSArray *comments = [data safe_objectForKey:@"data"];
            NSArray *arr = [NSArray yy_modelArrayWithClass:[CTFCommentModel class] json:comments];
            NSMutableArray *tempArr = [[NSMutableArray alloc] init];
            for (CTFCommentModel *model in arr) {
                model.avatarHeight = 33;
                [tempArr addObject:model];
            }
            NSMutableArray *tempSubArr = [self filterCommentsData:tempArr tempArr:self.tempSubCommentsArray];
            if (pageModel.page == 1) {
                [self.subCommentsList removeAllObjects];
            }
            [self.subCommentsList addObjectsFromArray:tempSubArr];
            if (complete) complete(YES);
        }else{
            if (complete) complete(NO);
        }
    }];
}

#pragma mark 发表评论
-(void)createCommentWithContent:(NSString *)content complete:(AdpaterComplete)complete{
    CTRequest *request = [CTFCommentApi creatCommentWithAnswerId:self.answerId content:content];
    @weakify(self);
   [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
       @strongify(self);
       [self handlerError:error];
       if (isSuccess) {
           CTFCommentModel *model = [[CTFCommentModel alloc] init];
           [model yy_modelSetWithJSON:data];
           model.isLocal = YES;
           [self.tempCommentsArray addObject:model];
           [self.commentsList insertObject:model atIndex:0];
           self.commentPagingModel.total ++;
           self.commentCount ++ ;
           complete(YES);
       } else {
           complete(NO);
       }
   }];
}

#pragma mark 回复评论
- (void)createReplyWithCommentId:(NSInteger)commentId content:(NSString *)content complete:(AdpaterComplete)complete{
    CTRequest *request = [CTFCommentApi creatReplyWithCommentId:commentId content:content];
     @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if (isSuccess) {
            CTFCommentModel *model = [[CTFCommentModel alloc] init];
            [model yy_modelSetWithJSON:data];
            model.isLocal = YES;
            if (self.isDetails) {
                [self.tempSubCommentsArray addObject:model];
            }
            self.commentCount ++ ;
            //处理评论结果
            [self handleComment:model commentId:commentId];
            complete(YES);
        } else {
            complete(NO);
        }
    }];
}

#pragma mark 删除评论
-(void)deleteCommentWithCommentId:(NSInteger)commentId complete:(AdpaterComplete)complete{
    CTRequest *request = [CTFCommentApi deleteCommentWithCommentId:commentId];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
         @strongify(self);
        [self handlerError:error];
        if (isSuccess) {
            [self deleteCommentWithId:commentId];
            complete(YES);
        } else {
            complete(NO);
        }
    }];
}

#pragma mark 举报评论
-(void)reportCommentWithCommentId:(NSInteger)commentId complete:(AdpaterComplete)complete{
    CTRequest *request = [CTFUtilsApi reportContent:commentId resourceType:@"comment" feedbackTitle:@"" content:@"" email:@"" imageIds:@[]];
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

#pragma mark 评论投票
-(void)voteCommentWithCommentId:(NSInteger)commentId attitude:(nonnull NSString *)attitude complete:(nonnull AdpaterComplete)complete{
    CTRequest *request = [CTFCommentApi voteCommentWithCommentId:commentId attitude:attitude];
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

#pragma mark 返回评论数量
-(NSInteger)numberOfCommentsList{
    return self.commentsList.count;
}

#pragma mark 返回评论对象
-(CTFCommentModel *)getCommentModelWithIndex:(NSInteger)index{
    CTFCommentModel *model = [self.commentsList safe_objectAtIndex:index];
    return model;
}

#pragma mark 是否还有更多
- (BOOL)hasMoreCommentsListData {
    if(self.commentPagingModel && self.commentsList) {
        return self.commentPagingModel.total > self.commentsList.count;
    }
    return NO;
}

-(BOOL)isEmpty{
    return self.commentsList.count==0;
}

#pragma mark 子评论
- (NSArray<CTFCommentModel *> *)subCommentsData{
    return self.subCommentsList;
}

#pragma mark 是否还有更多子评论
- (BOOL)hasMoreSubCommentsData {
    if(self.detailsPageModel && self.subCommentsList) {
        return self.detailsPageModel.total > self.subCommentsList.count;
    }
    return NO;
}

#pragma mark 当前回答评论数
- (NSInteger)answerAllCommentCount {
    return self.commentCount;
}

#pragma mark -- Private methods
#pragma mark 处理评论结果
- (void)handleComment:(CTFCommentModel *)model commentId:(NSInteger)commentId{
    if (self.isDetails) {
        model.avatarHeight = 33;
        [self.subCommentsList insertObject:model atIndex:0];
    }else{
        for (CTFCommentModel *aModel in self.commentsList) {
            BOOL flag = NO;
            if (aModel.commentId == commentId) {
                flag = YES;
            } else {
                for (CTFCommentModel *subComment in aModel.childComments) {
                    if (subComment.commentId == commentId) {
                        flag = YES;
                        break;
                    }
                }
            }
            if (flag) {
                NSMutableArray *tempArr = [NSMutableArray arrayWithArray:aModel.childComments];
                [tempArr insertObject:model atIndex:0];
                aModel.childComments = tempArr;
                NSInteger count = aModel.childCommentsCount;
                count ++;
                aModel.childCommentsCount = count;
                break;
            }
        }
    }
}

#pragma mark 删除评论回调
- (void)deleteCommentWithId:(NSInteger)commentId{
    if (self.isDetails) {
        for (CTFCommentModel *model in self.subCommentsList) {
            if (model.commentId == commentId) {
                model.isDeleted = YES;
                break;
            }
        }
    } else {
        for (CTFCommentModel *model in self.commentsList) {
            if (model.commentId == commentId) {
                model.isDeleted = YES;
            } else {
                for (CTFCommentModel *model in self.commentsList) {
                    for (CTFCommentModel *subComment in model.childComments) {
                        if (subComment.commentId == commentId) {
                            subComment.isDeleted = YES;
                            break;
                        }
                    }
                }
            }
        }
    }
}

#pragma mark -- Setters
- (void)setIsDetails:(BOOL)isDetails{
    _isDetails = isDetails;
}

#pragma mark 剔除重复数据
- (NSMutableArray *)filterCommentsData:(NSArray *)arr tempArr:(NSMutableArray *)tempComment{
    //剔除重复数据
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    for (CTFCommentModel *aModel in arr) {
        if (tempComment.count>0) {
            for (CTFCommentModel *tempModel in tempComment) {
                if (aModel.commentId != tempModel.commentId) {
                    [tempArr addObject:aModel];
                }
            }
        } else {
            [tempArr addObject:aModel];
        }
    }
    return tempArr;
}

@end
