//
//  CTFMyAnswerCellLayout.h
//  ChalkTalks
//
//  Created by vision on 2020/1/7.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnswersModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFMyAnswerCellLayout : NSObject

@property (nonatomic, strong) AnswerModel *model;

@property (nonatomic, readonly) CGRect myTitleRect;  //我的观点标题
@property (nonatomic, readonly) CGRect titleRect;    //话题标题
@property (nonatomic, readonly) CGRect authorRect;   //话题发布者
@property (nonatomic, readonly) CGRect videoRect;
@property (nonatomic, readonly) CGRect imgsRect;
@property (nonatomic, readonly) CGRect audioRect;
@property (nonatomic, readonly) CGRect descRect;
@property (nonatomic, readonly) CGRect statusRect;
@property (nonatomic, readonly) CGRect answerInfoRect;
@property (nonatomic, readonly) CGRect eventRect;       //更多、评论、靠谱事件
@property (nonatomic, readonly) CGRect separationRect;

@property (nonatomic, readonly) CGFloat height;

- (instancetype)initWithData:(AnswerModel *)data;

+(NSArray<CTFMyAnswerCellLayout*>*)converToLayout:(NSArray<AnswerModel*>*)list;


@end

NS_ASSUME_NONNULL_END
