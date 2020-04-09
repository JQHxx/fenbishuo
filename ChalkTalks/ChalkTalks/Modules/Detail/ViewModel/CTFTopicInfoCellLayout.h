//
//  CTFTopicInfoCellLayout.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/23.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTFTopicInfoCellLayout : NSObject
@property (nonatomic, strong) CTFQuestionsModel *model;

@property (nonatomic, readonly) CGRect headerRect;
@property (nonatomic, readonly) CGRect nickNameRect;
@property (nonatomic, readonly) CGRect signRect;
@property (nonatomic, readonly) CGRect timeRect;
@property (nonatomic, readonly) CGRect typeRect;
@property (nonatomic, readonly) CGRect topicContentRect;
@property (nonatomic, readonly) CGRect topicSummaryRect; //2行
@property (nonatomic, readonly) CGRect topicAllSummaryRect; //全部
@property (nonatomic, readonly) CGRect statusRect;
@property (nonatomic, assign)  BOOL  needShowAllBtn;
@property (nonatomic, readonly) CGRect showAllButtonRect; //显示 全部/收起
@property (nonatomic, readonly) CGRect imgsRect;
@property (nonatomic, readonly) CGFloat imgItemWidth;
@property (nonatomic, readonly) CGFloat imgItemHeight;
@property (nonatomic, readonly) CGRect attitudeRect;  //关心 踩
@property (nonatomic, readonly) CGRect lineRect;

@property (nonatomic, readonly) CGFloat height;  //没有展示全部备注的高度
@property (nonatomic, readonly) CGFloat allHeight; //

- (instancetype)initWithData:(CTFQuestionsModel *)data;
@end

NS_ASSUME_NONNULL_END
