//
//  CTFVideoImagesSlice.h
//  ChalkTalks
//
//  Created by zingwin on 2020/1/9.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"
#import <AVFoundation/AVFoundation.h>

@interface CTFVideoImageModel : BaseModel

@property(nonatomic,copy) UIImage * _Nullable cropImage;
@property(nonatomic,assign) CMTime actualTime;
@property(nonatomic,assign) BOOL isSelected;
@property(nonatomic,assign) CMTime requestTime;
@property(nonatomic,assign) NSInteger index;
@property(nonatomic,assign) CGFloat width;
@property(nonatomic,assign) CGFloat height;
@property(nonatomic,assign) CGFloat rotation;

-(CTFVideoImageModel*_Nonnull)initWithImage:(UIImage*_Nullable)image actualTime:(CMTime)actualTime;


@end

NS_ASSUME_NONNULL_BEGIN

@interface CTFVideoImagesSlice : NSObject
-(instancetype)initWithVideoUrl:(NSURL*)videoUrl;

-(NSTimeInterval)videoDuration;

/// 获取某一帧的f视频封面
/// @param ts  时间 ts 单位秒
/// @param complete  cb
-(void)asyncObtainCoverByTs:(NSTimeInterval)ts
                   complete:(void (^)(CTFVideoImageModel *vImage))complete;

/// 获取视频可用封面的时间戳 valueWithCMTime
-(NSArray<NSValue*>*)curVideoSliceTimes;

/// 获取视频拍摄角度
- (NSUInteger)degressFromVideoFileWithURL:(NSURL *)url;


-(void)cancelImageGeneration;


//模仿安卓实现
-(NSArray<CTFVideoImageModel*>*)curVideoSliceModes;
-(void)asyncRequestVideoImage:(CTFVideoImageModel*)model
                     complete:(void (^)(void))complete;


- (AVAssetTrack *)getVideoTrack;

@end

NS_ASSUME_NONNULL_END
