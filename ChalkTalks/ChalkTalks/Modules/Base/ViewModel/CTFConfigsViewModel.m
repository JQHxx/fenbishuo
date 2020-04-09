//
//  CTFConfigsViewModel.m
//  ChalkTalks
//
//  Created by vision on 2020/2/10.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFConfigsViewModel.h"
#import <KTVHTTPCache/KTVHTTPCache.h>
#import "NSURL+Ext.h"

@interface CTFConfigsViewModel ()

@property (nonatomic,strong) CTFConfigsModel *configsModel;

@end

@implementation CTFConfigsViewModel

-(instancetype)init{
    self = [super init];
    if (self) {
        self.configsModel = [[CTFConfigsModel alloc] init];
    }
    return self;
}

- (void)systemConfigsComplete:(AdpaterComplete)complete{
    CTRequest *request = [CTFUtilsApi systemConfigs];
     @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
         @strongify(self);
        [self handlerError:error];
        if(isSuccess){
            [self.configsModel yy_modelSetWithJSON:data];
            NSString *videoUrl = self.configsModel.questionGuideVideo.url;
            if (!kIsEmptyString(videoUrl)) {
                NSURL *videoPath = [KTVHTTPCache proxyURLWithOriginalURL:[NSURL safe_URLWithString:videoUrl]];
                self.configsModel.questionGuideVideo.videoPath = videoUrl;
                [self requestVideoCoverWithVideoPath:videoPath];
            }
            complete(YES);
        }else{
            complete(NO);
        }
    }];
}

#pragma mark 系统配置
- (CTFConfigsModel *)getTSysConfigs{
    return self.configsModel;
}


#pragma mark 获取封面图片
- (void )requestVideoCoverWithVideoPath:(NSURL *)videoPath{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoPath options:nil];
        CMTime time = [asset duration];
        NSParameterAssert(asset);
        AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
        assetImageGenerator.appliesPreferredTrackTransform = YES;
        assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
        
        CGImageRef thumbnailImageRef = NULL;
        NSError *error = nil;
        CMTime fk = CMTimeMakeWithSeconds(0, time.timescale);
        thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:fk actualTime:NULL error:&error];
        if (!error) {
            UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
            [[SDImageCache sharedImageCache] storeImage:thumbnailImage forKey:kPublishGuideVideoCoverKey toDisk:YES completion:nil];
            self.configsModel.questionGuideVideo.videoCoverImage = thumbnailImage;
        } else {
            ZLLog(@"thumbnailImageGenerationError %@",error);
        }
    });
}

@end
