//
//  CTFVoteListHeadView.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/1/11.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTFVoteListHeadView : UIView

/* 话题数 + 排序方式 */
- (instancetype)initWithFrame:(CGRect)frame account:(NSInteger)account sortType:(NSString *)sort;
- (void)updateDataByAccount:(NSInteger)account sortType:(NSString *)sort;

/* 轮播消息 + 排序方式 */
- (instancetype)initWithFrame:(CGRect)frame wheelData:(NSArray<CTFCarouselsModel*> *)wheelArray sortType:(NSString *)sort;
- (void)updateDataByWheelData:(NSArray<CTFCarouselsModel*> *)wheelArray sortType:(NSString *)sort;

@end

NS_ASSUME_NONNULL_END
