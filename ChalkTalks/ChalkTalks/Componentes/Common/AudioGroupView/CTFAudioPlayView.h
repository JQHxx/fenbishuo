//
//  CTFAudioPlayView.h
//  ChalkTalks
//
//  Created by vision on 2020/1/14.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnswersModel.h"

@interface CTFAudioPlayView : UIView

@property (nonatomic,strong) NSDictionary *audio;

@property (nonatomic,assign) NSInteger timeCount;

//开始加载
-(void)startLoading;

//播放动画
-(void)animationPlay;

//停止动画
-(void)animationStop;

//开始加载
-(void)endLoading;

@end

