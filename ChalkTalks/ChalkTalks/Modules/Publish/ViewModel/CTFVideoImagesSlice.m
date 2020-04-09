//
//  CTFVideoImagesSlice.m
//  ChalkTalks
//
//  Created by zingwin on 2020/1/9.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFVideoImagesSlice.h"

@implementation CTFVideoImageModel
-(CTFVideoImageModel*)initWithImage:(UIImage*)image actualTime:(CMTime)actualTime{
    self = [super init];
    if (self) {
        self.cropImage = image;
        self.actualTime = actualTime;
        self.isSelected = NO;
    }
    return self;
}
@end


@interface CTFVideoImagesSlice()
@property(nonatomic, copy ) NSURL *videoURL;
@property(nonatomic,strong) AVAssetImageGenerator *generator;
@property(nonatomic,assign) CMTime durationTime;
@end

@implementation CTFVideoImagesSlice
-(instancetype)initWithVideoUrl:(NSURL*)videoUrl{
    self = [super init];
    if(self){
        self.videoURL = videoUrl;
        //不需要精准时长
        NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:self.videoURL options:opts];
        self.durationTime = [urlAsset duration];
        
        self.generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
        self.generator.requestedTimeToleranceAfter = kCMTimeZero;
        self.generator.requestedTimeToleranceBefore = kCMTimeZero;
        self.generator.appliesPreferredTrackTransform = YES;
    }
    return self;
}

-(NSTimeInterval)videoDuration{
    return CMTimeGetSeconds(self.durationTime);
}

-(void)asyncObtainCoverByTs:(NSTimeInterval)ts
                   complete:(void (^)(CTFVideoImageModel *vImage))complete{
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        if(!self.videoURL){
            dispatch_async(dispatch_get_main_queue(), ^{
                if(complete){complete(nil);}
            });
            return;
        }
        NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:self.videoURL options:opts];
        CMTime time = [urlAsset duration];
        if(CMTimeGetSeconds(time) < ts) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(complete){complete(nil);}
            });
            return;
        }
       
        CMTime fk = CMTimeMakeWithSeconds(ts, time.timescale);
        NSError *error = nil;
        CGImageRef img = [self.generator copyCGImageAtTime:fk actualTime:NULL error:&error];
        if(error == nil){
            UIImage *image = [UIImage imageWithCGImage:img scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            CTFVideoImageModel *model = [[CTFVideoImageModel alloc] initWithImage:image actualTime:fk];
            NSArray *tracks = [urlAsset tracksWithMediaType:AVMediaTypeVideo];
            if([tracks count] > 0) {
                AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
                model.width = videoTrack.naturalSize.width;
                model.height = videoTrack.naturalSize.height;
                
                NSInteger degress = 0;
                CGAffineTransform t = videoTrack.preferredTransform;
                if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
                    // Portrait
                    degress = 90;
                }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
                    // PortraitUpsideDown
                    degress = 270;
                }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
                    // LandscapeRight
                    degress = 0;
                }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
                    // LandscapeLeft
                    degress = 180;
                }
                model.rotation = degress; ZLLog(@"width:%.f,height:%.f,rotation:%.f",videoTrack.naturalSize.width,videoTrack.naturalSize.height,model.rotation);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(complete){complete(model);}
            });
        }else{
            ZLLog(@"错误 %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                 if(complete){complete(nil);}
            });
           
        }
    });
}

-(NSArray<NSValue*>*)curVideoSliceTimes{
    if((self.durationTime.value / self.durationTime.timescale < 1)) return nil;
       
    //取封面  视频时长   默认  1s一帧     >=20s   3s一帧    >=180   5s一帧
    NSInteger keySec = 1;
    if(CMTimeGetSeconds(self.durationTime) >= 180){
        keySec = 5;
    }else if(CMTimeGetSeconds(self.durationTime) >= 20){
        keySec = 3;
    }
    ZLLog(@"视频时长 %f", CMTimeGetSeconds(self.durationTime));
    ZLLog(@"时间间距 %zd",keySec);
       
    NSInteger sumImageCount = CMTimeGetSeconds(self.durationTime) / keySec;
    NSMutableArray *times = [NSMutableArray array];
    
    for(int i = 0; i < sumImageCount; i++){
        CMTime it = CMTimeMakeWithSeconds(i * keySec, self.durationTime.timescale);
        NSValue *value = [NSValue valueWithCMTime:it];
        [times addObject:value];
    }
    return times;
}

-(void)cancelImageGeneration{
    if(self.generator){
        [self.generator cancelAllCGImageGeneration];
    }
}



-(NSArray<CTFVideoImageModel*>*)curVideoSliceModes{
    if((self.durationTime.value / self.durationTime.timescale < 1)) return nil;
          
   //取封面  视频时长   默认  1s一帧     >=20s   3s一帧    >=180   5s一帧
   NSInteger keySec = 1;
   if(CMTimeGetSeconds(self.durationTime) >= 180){
       keySec = 5;
   }else if(CMTimeGetSeconds(self.durationTime) >= 20){
       keySec = 3;
   }
   
   NSInteger sumImageCount = CMTimeGetSeconds(self.durationTime) / keySec;
   NSMutableArray *times = [NSMutableArray array];
   
    ZLLog(@"视频时长 %f", CMTimeGetSeconds(self.durationTime));
    ZLLog(@"时间间距 %zd",keySec);
    ZLLog(@"总个数 %zd", sumImageCount);
    
   for(int i = 0; i < sumImageCount; i++){
       CMTime it = CMTimeMakeWithSeconds(i * keySec, self.durationTime.timescale);
       //NSValue *value = [NSValue valueWithCMTime:it];
       CTFVideoImageModel *item = [[CTFVideoImageModel alloc] init];
       item.requestTime = it;
       item.index = i;
       [times addObject:item];
   }
   return times;
}


-(void)asyncRequestVideoImage:(CTFVideoImageModel*)model
                        complete:(void (^)(void))complete{

    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        NSError *error = nil;
        CGImageRef img = [self.generator copyCGImageAtTime:model.requestTime actualTime:NULL error:&error];
        if(error == nil){
            UIImage *image = [UIImage imageWithCGImage:img scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            model.cropImage = image;
           
            dispatch_async(dispatch_get_main_queue(), ^{
                if(complete){complete();}
            });
        }else{
            ZLLog(@"错误 %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                 if(complete){complete();}
            });
           
        }
    });
}


@end
