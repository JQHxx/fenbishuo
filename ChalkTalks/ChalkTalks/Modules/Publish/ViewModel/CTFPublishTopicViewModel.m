//
//  CTFPublishTopicViewModel.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/13.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFPublishTopicViewModel.h"
#import "UIImage+Size.h"

@interface CTFPublishTopicViewModel()

@property (nonatomic,assign) NSInteger publishTopicId;
@property (nonatomic, copy ) NSArray <CTFSuffixModel *> *suffixTitlesArray;

@end

@implementation CTFPublishTopicViewModel

-(instancetype)init{
    self = [super init];
    if (self) {
        self.uploadImageArr = [[NSMutableArray alloc] init];
    }
    return self;
}

-(NSInteger)numberOfImage{
    return [self.uploadImageArr count];
}

-(UploadImageFileModel*)modelIndex:(NSInteger)index{
    if(index > self.uploadImageArr.count) return nil;
    return self.uploadImageArr[index];
}

-(NSInteger)indexOfModel:(UploadImageFileModel*)model{
    return [self.uploadImageArr indexOfObject:model];
}

-(void)deleteModel:(UploadImageFileModel*)model{
    [self.uploadImageArr removeObject:model];
}

-(BOOL)isImageAllUpload{
    BOOL upload = YES;
    for(UploadImageFileModel *item in self.uploadImageArr){
        if(item.uploadCompleted == NO){
            upload = NO;
            break;
        }
    }
    return upload;
}

-(void)md5ImageComplete:(UploadImageFileModel*)fileModel
               complete:(void (^)(void))complete{
    @weakify(fileModel);
       dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           @strongify(fileModel);
               NSData *data = UIImageJPEGRepresentation(fileModel.localImage, 1.0);
               NSString *md5 =  [OSSUtil dataMD5String:data];
               fileModel.imgMD5String = md5;
               fileModel.localImgData = data;
           dispatch_async(dispatch_get_main_queue(), ^{
               if(complete) complete();
           });
       });
}

-(UploadImageFileModel*)insertPrepareImage:(UIImage*)img{
    //可以同时发布两张图片，不用先计算了
    UIImage *zipImage = [UIImage zipScaleWithImage:img];
    UploadImageFileModel *item = [[UploadImageFileModel alloc] init];
    item.localImage = zipImage;
    [self.uploadImageArr addObject:item];
    return item;
}

- (void)addImageItems:(NSArray<ImageItemModel *> *)items {
    for (ImageItemModel *remoteItem in items) {
        UploadImageFileModel *item = [[UploadImageFileModel alloc] init];
        if (remoteItem.isLocal) {
            item.localImage = remoteItem.image;
            if (item.localImgData == nil) {
                item.localImgData = UIImageJPEGRepresentation(item.localImage, 1.0);
            }
        } else {
            item.imageUrl = remoteItem.url;
        }
        item.imageId = [NSString stringWithFormat:@"%ld", (long)remoteItem.imgId];
        item.uploadCompleted = YES;
        [_uploadImageArr addObject:item];
    }
}

-(void)prepareUploadImage:(UploadImageFileModel*)model
                 complete:(AdpaterComplete)complete{
    CTRequest *request = [CTFFileApi checkUploadImage:model.imgMD5String];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if(isSuccess){
            NSDictionary *uploadTokenDic = [data safe_objectForKey:@"uploadToken"];
            AliUploadTokenModel *aliOSSToken = [AliUploadTokenModel yy_modelWithJSON:uploadTokenDic];
            [AliOSSTokenCache saveAliUploadToken:aliOSSToken];
            
            NSDictionary *uploadFileDic = [data safe_objectForKey:@"uploadFile"];
            model.imageId = [uploadFileDic safe_stringForKey:@"imageId"];
            model.objectKey = [uploadFileDic safe_stringForKey:@"objectKey"];
            model.status = [uploadFileDic safe_stringForKey:@"status"];
            model.uploadCompleted = ![model.status isEqualToString:@"init"];
            model.uploadError = NO;
            
            complete(YES);
        }else{
            complete(NO);
        }
    }];
}


#pragma mark -- 话题
#pragma mark 获取话题标题后缀
- (void)loadTopicSuffixTitlesComplete:(AdpaterComplete)complete {
    CTRequest *request = [CTFTopicApi requestTopicSuffixTitles];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        @strongify(self);
        [self handlerError:error];
        if (isSuccess) {
            NSArray *titles = [data safe_objectForKey:@"data"];
            NSArray *arr = [NSArray yy_modelArrayWithClass:[CTFSuffixModel class] json:titles];
            self.suffixTitlesArray = arr;
            complete(YES);
        } else {
            complete(NO);
        }
    }];
}

#pragma mark 创建话题
- (void)createTopicWithType:(NSString *)type
                      title:(NSString *)title
                     suffix:(NSInteger )suffixId
                    content:(NSString *)content
                   imageIds:(NSArray *)imageIds
                   complete:(AdpaterComplete)complete {
    
    CTRequest *request = [CTFTopicApi creatQuestionWithType:type title:title suffix:suffixId content:content imageIds:imageIds];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
         @strongify(self);
        [self handlerError:error];
        if (isSuccess) {
            /* 创建话题成功，拿到话题ID */
            self.publishTopicId = [data safe_integerForKey:@"id"];
           complete(YES);
        } else {
            complete(NO);
        }
    }];
}

#pragma mark 修改话题
- (void)modifyTopicWithId:(NSInteger)questionId
                     type:(NSString *)type
                    title:(NSString *)title
                   suffix:(NSInteger )suffixId
                  content:(NSString *)content
                 imageIds:(NSArray *)imageIds
                 complete:(AdpaterComplete)complete {
    CTRequest *request = [CTFTopicApi modifyQuestionWithId:questionId type:type title:title suffix:suffixId content:content imageIds:imageIds];
    @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
         @strongify(self);
        [self handlerError:error];
        if(isSuccess){
            self.publishTopicId = questionId;
           complete(YES);
        }else{
            complete(NO);
        }
    }];
}

-(NSArray<NSString*>*)uploadImageIds{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (UploadImageFileModel *item in self.uploadImageArr) {
        if (!kIsEmptyString(item.imageId)) {
            [arr addObject:item.imageId];
        }
    }
    return arr;
}

-(NSInteger)currentPublishTopicId{
    return  self.publishTopicId;
}

#pragma mark 话题标题后缀
- (NSArray<CTFSuffixModel *> *)allSuffixTitles {
    return self.suffixTitlesArray;
}

@end
