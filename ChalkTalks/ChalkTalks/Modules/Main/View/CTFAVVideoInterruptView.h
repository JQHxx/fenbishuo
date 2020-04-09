//
//  CTFVideoInterruptView.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/25.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTFCellularPlayerVideo.h"
#import <Masonry/Masonry.h>
#import "AppMargin.h"
#import "CTModels.h"
#import "UIImage+Ext.h"


typedef NS_ENUM(NSInteger, VideoInterrupted) {
    VideoInterrupted_No = 0,
    VideoInterrupted_LoadingError,     //加载失败
    VideoInterrupted_Cellular,    //4G网络，不能自动播放
    VideoInterrupted_Complete,  //视频播放完成
    VideoInterrupted_NetError,  //没有网络
};


NS_ASSUME_NONNULL_BEGIN

@interface CTFAVVideoInterruptView : UIView
@property(nonatomic, copy) void (^ _Nonnull playVideo)(void);

-(void)showViewByType:(VideoInterrupted)type;
@end

NS_ASSUME_NONNULL_END
