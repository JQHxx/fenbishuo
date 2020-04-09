//
//  CTFPublishVideoViewpointVC.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/12.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseViewController.h"

@class AVURLAsset, CTDraftAnswer;

NS_ASSUME_NONNULL_BEGIN


/// 发布视频观点
@interface CTFPublishVideoViewpointVC : BaseViewController

@property (nonatomic,strong) CTDraftAnswer  *draftModel;
@property (nonatomic,strong) AVURLAsset     *asset;


@end

NS_ASSUME_NONNULL_END
