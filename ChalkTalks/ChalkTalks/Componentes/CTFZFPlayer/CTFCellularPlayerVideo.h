//
//  CTFCellularPlayerVideo.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/16.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN



/// 视频播放，4g网络控制
@interface CTFCellularPlayerVideo : NSObject
+ (instancetype)sharedInstance;

//是否可以在4g网络播放视频
@property (nonatomic, assign) BOOL canPlayVideoViaWWAN;
@end

NS_ASSUME_NONNULL_END
