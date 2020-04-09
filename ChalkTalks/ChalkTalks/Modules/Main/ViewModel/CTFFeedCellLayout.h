//
//  CTFFeedImageCellLayout.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/28.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CTFFeedCellLayout : NSObject

@property (nonatomic, strong) AnswerModel *model;

@property (nonatomic, readonly) CGRect titleRect;    //话题标题
@property (nonatomic, readonly) CGRect authorRect;    //发布者
@property (nonatomic, readonly) CGRect videoRect;
@property (nonatomic, readonly) CGRect imgsRect;
@property (nonatomic, readonly) CGRect audioRect;
@property (nonatomic, readonly) CGRect descRect;
@property (nonatomic, readonly) CGRect infoRect;    //回答发布者
@property (nonatomic, readonly) CGRect handleRect;
@property (nonatomic, readonly) CGRect separationRect;

@property (nonatomic, readonly) CGFloat height;

- (instancetype)initWithData:(AnswerModel *)data;

+(NSArray<CTFFeedCellLayout*>*)converToLayout:(NSArray<AnswerModel*>*)list;
@end


NS_ASSUME_NONNULL_END
