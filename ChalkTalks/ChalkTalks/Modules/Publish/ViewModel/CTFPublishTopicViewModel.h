//
//  CTFPublishTopicViewModel.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/13.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseViewModel.h"
#import <AliyunOSSiOS/OSSService.h>
#import "APIs.h"
#import "AliOSSTokenCache.h"
#import "CTFConfigsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFPublishTopicViewModel : BaseViewModel

@property(nonatomic, strong) NSMutableArray<UploadImageFileModel *> *uploadImageArr;

/// 通过用户选择的图片构造上传结构体
/// @param img  uiimage
-(UploadImageFileModel*)insertPrepareImage:(UIImage*)img;

-(void)md5ImageComplete:(UploadImageFileModel*)fileModel
               complete:(void (^)(void))complete;

/// 上传图片之前，需要先检查
/// @param model   构造的img数据
/// @param complete cb
-(void)prepareUploadImage:(UploadImageFileModel*)model
                 complete:(AdpaterComplete)complete;

-(UploadImageFileModel*)modelIndex:(NSInteger)index;
-(NSInteger)numberOfImage;
-(NSInteger)indexOfModel:(UploadImageFileModel*)model;
-(void)deleteModel:(UploadImageFileModel*)model;

-(NSArray<NSString*>*)uploadImageIds;

- (void)addImageItems:(NSArray<ImageItemModel *> *)items;

/// 获取话题标题后缀
/// @param complete cb
- (void)loadTopicSuffixTitlesComplete:(AdpaterComplete)complete;

/// 创建话题
/// @param type   话题类型
/// @param title   话题标题
/// @param suffixId   标题后缀Id
/// @param content   话题描述
/// @param imageIds   话题图片
/// @param complete cb
-(void)createTopicWithType:(NSString *)type
                     title:(NSString *)title
                    suffix:(NSInteger )suffixId
                   content:(NSString *)content
                  imageIds:(NSArray  *)imageIds
                  complete:(AdpaterComplete)complete;

/// 修改话题
/// @param questionId   话题id
/// @param type   话题类型
/// @param title   话题标题
/// @param suffixId   标题后缀id
/// @param content   话题描述
/// @param imageIds   话题图片
/// @param complete cb
-(void)modifyTopicWithId:(NSInteger )questionId
                    type:(NSString *)type
                   title:(NSString *)title
                  suffix:(NSInteger )suffixId
                 content:(NSString *)content
                imageIds:(NSArray *)imageIds
                complete:(AdpaterComplete)complete;

-(BOOL)isImageAllUpload;

-(NSInteger)currentPublishTopicId;

///话题标题后缀
- (NSArray <CTFSuffixModel *>*)allSuffixTitles;

@end

NS_ASSUME_NONNULL_END
