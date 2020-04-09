//
//  CTFAnswerDetailCellLayout.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/23.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppMargin.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFAnswerDetailCellLayout : NSObject
@property (nonatomic, strong) AnswerModel *model;

@property (nonatomic, readonly) CGRect userInfoRect;
@property (nonatomic, readonly) CGRect videoRect;        //视频
@property (nonatomic, readonly) CGRect imgsRect;         //图片
@property (nonatomic, readonly) CGRect audioRect;
@property (nonatomic, readonly) CGRect viewpointRect;    //描述
@property (nonatomic, readonly) CGRect statusRect;    
@property (nonatomic, readonly) CGRect viewCountRect;    //阅读量
@property (nonatomic, readonly) CGRect handleRect;       //更多\评论\靠谱事件
@property (nonatomic, readonly) CGRect separationRect;   //线条

@property (nonatomic, assign) CGFloat height;

- (instancetype)initWithData:(AnswerModel *)data;

+(NSArray<CTFAnswerDetailCellLayout*>*)converToLayout:(NSArray<AnswerModel*>*)list;
@end

NS_ASSUME_NONNULL_END
