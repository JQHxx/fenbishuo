//
//  MainPageViewModel.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/3.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "MainPageViewModel.h"
#import "CTFPreloadVideoManager.h"
#import "CTFFeedCellLayout.h"
#import "NSUserDefaultsInfos.h"

@interface MainPageViewModel()

@property (nonatomic, strong) NSMutableArray<CategoriesModel *> *categoriesArr;
@property (nonatomic, strong) CategoriesModel     *recommendTab;
@property (nonatomic, strong) NSMutableDictionary *feedDictionary;
@property (nonatomic, strong) NSMutableDictionary *feedPageDictionary;
@property (nonatomic, assign) NSInteger   beforeId;
@property (nonatomic, assign) NSInteger   downRefreshDataCount;
@property (nonatomic, assign) NSInteger   latestFeedsCount;

@end
@implementation MainPageViewModel

-(instancetype)init{
    self = [super init];
    if (self) {
        [self setupData];
    }
    return self;
}

-(void)setupData{
    self.categoriesArr = [[NSMutableArray alloc] init];
    self.feedDictionary = [[NSMutableDictionary alloc] init];
    self.feedPageDictionary = [[NSMutableDictionary alloc] init];
    
    self.recommendTab = [[CategoriesModel alloc] init];
    self.recommendTab.categoryId = 909090;
    self.recommendTab.name = @"热门";
}

-(CategoriesModel*)recommendCategory{
    return self.recommendTab;
}

-(void)fetchFeedTopTabList:(AdpaterComplete)complete{
    CTRequest *request = [FeedApi feedCategoriesApi];
    @weakify(self);
    [request requstApiWithCacheComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if(isSuccess){
            NSArray *categories = data;
            NSArray *arr = [NSArray yy_modelArrayWithClass:[CategoriesModel class] json:categories];
            [self.categoriesArr removeAllObjects];
            [self.categoriesArr safe_addObject:[self recommendCategory]];
            [self.categoriesArr safe_addObjectsFromArray:arr];
            if(complete) complete(YES);
        }else{
            if(complete) complete(NO);
        }
    }];
}

-(NSArray<CategoriesModel*>*)categoriesList{
    return self.categoriesArr;
}

#pragma mark 首次加载feeds数据
- (void)fetchFirstLaunchingFeedsDataByCategoryID:(NSInteger)categoryId complete:(AdpaterComplete)complete {
    if (![self isEmpty:categoryId]) {
        NSString *key = [NSString stringWithFormat:@"%zd", categoryId];
        [self.feedDictionary removeObjectForKey:key];
    }
    self.beforeId = 0;
    [self _fetchFeedListWithCategoryId:categoryId action:@"down" feedId:0 complete:^(BOOL isSuccess) {
        NSInteger feedId = [self lastAnswerFeedId];
        [self _fetchFeedListWithCategoryId:categoryId action:@"up" feedId:feedId complete:complete];
    }];
}

#pragma mark 数据上报
- (void)uploadAnswerHasReadWithAnswerId:(NSInteger)answerId {
    CTRequest *request = [FeedApi feedAnswerUploadReadByAnswerId:answerId];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, NSDictionary * _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
    }];
}

-(void)fetchFeedListByCategoryID:(NSInteger)categoryId
                          action:(NSString *)action
                          feedId:(NSInteger)feedId
                            page:(PagingModel*)page
                        complete:(AdpaterComplete)complete{
    
    if (categoryId == [self recommendCategory].categoryId) {
       [self _fetchFeedListWithCategoryId:categoryId action:action feedId:feedId complete:complete];
    }else{
       NSString *key = [NSString stringWithFormat:@"%zd", categoryId];
       [self.feedPageDictionary safe_setValue:page forKey:key];
       [self _fetchFeedOhterList:categoryId page:page complete:complete];
    }
}

#pragma mark 获取首页非热门列表数据
-(void)_fetchFeedOhterList:(NSInteger)categoryId
                      page:(PagingModel*)page
                  complete:(AdpaterComplete)complete{
    CTRequest *request = [FeedApi feedAnswersApi:categoryId page:page.page pageSize:page.pageSize];
    
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, NSDictionary * _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        
        if(isSuccess){
            NSDictionary *paging = [data safe_objectForKey:@"paging"];
            page.total = [paging safe_integerForKey:@"total"];
            
            NSDictionary *answers = [[data safe_objectForKey:@"data"] safe_objectForKey:@"answers"];
            NSArray *list = [NSArray yy_modelArrayWithClass:[AnswerModel class] json:answers];
            NSArray *answerList = [CTFFeedCellLayout converToLayout:list];
            NSString *key = [NSString stringWithFormat:@"%zd", categoryId];
            NSMutableArray *arr = [self.feedDictionary safe_objectForKey:key];
            
            if (arr) {
                if(page.page == 1) [arr removeAllObjects];
                [arr addObjectsFromArray:answerList];
            } else {
                NSMutableArray *v = [NSMutableArray arrayWithArray:answerList];
                [self.feedDictionary safe_setObject:v forKey:key];
            }
            if(complete) complete(YES);
            [self videoUrlForPrelaod:answerList];
        }else{
            if(complete) complete(NO);
        }
    }];
}

#pragma mark 获取首页热门feeds流数据
- (void)_fetchFeedListWithCategoryId:(NSInteger)categoryId
                              action:(NSString *)action
                              feedId:(NSInteger)feedId
                            complete:(AdpaterComplete)complete {
    CTRequest *request = [FeedApi homeFeedListApiByAction:action feedId:feedId];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        [NSUserDefaultsInfos putKey:kAPPlicationFinishLaunching andValue:[NSNumber numberWithBool:NO]];
        if (isSuccess) {
            [NSUserDefaultsInfos putKey:kFeedLoginIn andValue:[NSNumber numberWithBool:NO]];
            NSDictionary *answers = [data safe_objectForKey:@"data"];
            NSArray *list = [NSArray yy_modelArrayWithClass:[AnswerModel class] json:answers];
            NSArray *answerList = [CTFFeedCellLayout converToLayout:list];
            
            NSString *key = [NSString stringWithFormat:@"%zd", categoryId];
            NSMutableArray *arr = [self.feedDictionary safe_objectForKey:key];
            if (!kIsArray(arr)) {
                arr = [[NSMutableArray alloc] init];
            }
            if ([action isEqualToString:@"down"]) {
                if (answerList.count > 0) {
                    if (self.beforeId == 0) {
                        CTFFeedCellLayout * layout = [answerList lastObject];
                        self.beforeId = layout.model.feedId;
                    }
                    NSMutableIndexSet  *indexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, answerList.count)];
                    [arr insertObjects:answerList atIndexes:indexes];
                }
                self.downRefreshDataCount = answerList.count;
            } else {
                self.latestFeedsCount = answerList.count;
                CTFFeedCellLayout * layout = [answerList lastObject];
                self.beforeId = layout.model.feedId;
                [arr addObjectsFromArray:answerList];
            }
            [self.feedDictionary safe_setObject:arr forKey:key];
            if (complete) complete(YES);
            [self videoUrlForPrelaod:answerList];
        } else {
            if (complete) complete(NO);
        }
    }];
}

#pragma mark 获取首页热门列表数据
-(void)_fetchFeedRecommendList:(NSInteger)categoryId
                          page:(PagingModel*)page
                      complete:(AdpaterComplete)complete{
    CTRequest *request = [FeedApi feedRecommendsApi:page.page pageSize:page.pageSize];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, NSDictionary * _Nullable data, NSError * _Nullable error) {
         @strongify(self);
        [self handlerError:error];
        if(isSuccess){
            NSDictionary *paging = [data safe_objectForKey:@"paging"];
            page.total = [paging safe_integerForKey:@"total"];
            
            NSDictionary *answers = [data safe_objectForKey:@"data"];
            NSArray *list = [NSArray yy_modelArrayWithClass:[AnswerModel class] json:answers];
            NSArray *answerList = [CTFFeedCellLayout converToLayout:list];
            
            NSString *key = [NSString stringWithFormat:@"%zd", categoryId];
            NSMutableArray *arr = [self.feedDictionary safe_objectForKey:key];
            if (arr) {
                if(page.page == 1) [arr removeAllObjects];
                [arr addObjectsFromArray:answerList];
            } else {
                NSMutableArray *v = [NSMutableArray arrayWithArray:answerList];
                [self.feedDictionary safe_setObject:v forKey:key];
            }
            if(complete) complete(YES);
            [self videoUrlForPrelaod:answerList];
       }else{
           if(complete) complete(NO);
       }
    }];
}

-(NSInteger)numberOfList:(NSInteger)categoryId{
    NSString *key = [NSString stringWithFormat:@"%zd", categoryId];
    NSArray *arr = [self.feedDictionary safe_objectForKey:key];
    return [arr count];
}

-(CTFFeedCellLayout*)modelForFeed:(NSInteger)categoryId Index:(NSInteger)index{
    NSString *key = [NSString stringWithFormat:@"%zd", categoryId];
    NSArray *arr = [self.feedDictionary safe_objectForKey:key];
    return [arr safe_objectAtIndex:index];
}

-(void)deleteModelForFeed:(NSInteger)categoryId Index:(NSInteger)index{
    NSString *key = [NSString stringWithFormat:@"%zd", categoryId];
    NSMutableArray *arr = [self.feedDictionary safe_objectForKey:key];
    [arr removeObjectAtIndex:index];
}

-(BOOL)hasMoreData:(NSInteger)categoryId{
    NSString *key = [NSString stringWithFormat:@"%zd", categoryId];
    NSArray *arr = [self.feedDictionary safe_objectForKey:key];
    PagingModel *page = [self.feedPageDictionary safe_objectForKey:key];
    
    if(page && arr && arr.count){
        return page.total > arr.count;
    }
    return NO;
}

- (NSInteger)refreshDataCount {
    return self.downRefreshDataCount;
}

#pragma mark 最新一次上拉拉取数量
- (NSInteger)latestUpLoadFeedsDataCount {
    return self.latestFeedsCount;
}


-(BOOL)isEmpty:(NSInteger)categoryId{
    NSString *key = [NSString stringWithFormat:@"%zd", categoryId];
    NSArray *arr = [self.feedDictionary safe_objectForKey:key];
    if(arr && arr.count) return NO;
    return YES;
}

#pragma mark feedId
- (NSInteger)lastAnswerFeedId {
    return self.beforeId > 0 ? self.beforeId : 0;
}

-(ERRORTYPE)errorType:(NSInteger)categoryId{
    return self.errorType;
}

-(void)votersToAnswer:(NSInteger)answerId
             attitude:(NSString*)attitude
             complete:(AdpaterComplete)complete{
    CTRequest *request = [FeedApi voterToAttitude:answerId attitude:attitude];
    
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if(isSuccess){
            complete(YES);
        }else{
            complete(NO);
        }
    }];
}

-(void)impeachViewpoint:(NSInteger)answerId
               complete:(AdpaterComplete)complete{
    CTRequest *request = [CTFUtilsApi reportContent:answerId resourceType:@"answer" feedbackTitle:@"" content:@"" email:@"" imageIds:@[]];
     @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
       if(isSuccess){
           complete(YES);
       }else{
           ZLLog(@"%@", error);
            complete(NO);
       }
    }];
}

-(void)impeachTopic:(NSInteger)questionId
               complete:(AdpaterComplete)complete{
    CTRequest *request = [CTFUtilsApi reportContent:questionId resourceType:@"question" feedbackTitle:@"" content:@"" email:@"" imageIds:@[]];
     @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
       if(isSuccess){
           complete(YES);
       }else{
           ZLLog(@"%@", error);
            complete(NO);
       }
    }];
}

-(void)deleteMyViewpoint:(NSInteger)answerId
               complete:(AdpaterComplete)complete{
    CTRequest *request = [FeedApi deleteViewpoint:answerId];
     @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
      if(isSuccess){
           complete(YES);
       }else{
            complete(NO);
       }
    }];
}

#pragma mark 预览
-(void)videoUrlForPrelaod:(NSArray<CTFFeedCellLayout*>*)arr{
    NSMutableArray *urls = [[NSMutableArray alloc] init];
    for(CTFFeedCellLayout *item in arr){
        if([item.model.type isEqualToString:@"video"]){
            if(item.model.video.url && [item.model.video.status isEqualToString:@"succeed"]){
                [urls safe_addObject:item.model.video.url];
            }
        }
    }
    [[CTFPreloadVideoManager sharedInstance] preloadVideoUrls:urls];
}

#pragma mark 播放进度清零
- (void)setAllAnswerVideoPlayStopByCategoryId:(NSInteger)categoryId {
    NSString *key = [NSString stringWithFormat:@"%zd", categoryId];
    NSArray *arr = [self.feedDictionary safe_objectForKey:key];
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    for (CTFFeedCellLayout *item in arr) {
        item.model.video.aleayPlayDuration = 0;
    }
    [self.feedDictionary safe_setValue:tempArr forKey:key];
}

@end
