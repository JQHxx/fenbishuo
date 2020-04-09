//
//  CTFMyAnswerViewModel.h
//  ChalkTalks
//
//  Created by vision on 2019/12/27.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseViewModel.h"
#import "CTFMyAnswerCellLayout.h"
#import "AnswersModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFMyAnswerViewModel : BaseViewModel


/*
* 加载我的观点
* @param userId 用户id
* @param page 页码
*/
- (void)loadMyAnswersDataByPage:(PagingModel *)pageModel complete:(AdpaterComplete)complete;

/*
* 删除我的观点
* @param answerId 观点id
* @param page 页码
*/
- (void)deleteMyAnswerWithAnswerId:(NSInteger)answerId;

//动态数
- (NSInteger)numberOfMyAnswersData;
//获取cell的动态
- (CTFMyAnswerCellLayout *)getMyAnswerModelWithIndex:(NSInteger)index;
//是否还有更多评论
- (BOOL)hasMoreMyAnswersListData;
//是否为空
- (BOOL)isEmpty;

@end

NS_ASSUME_NONNULL_END
