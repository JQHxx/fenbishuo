//
//  CTFHomePageViewModel.h
//  ChalkTalks
//
//  Created by vision on 2019/12/26.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseViewModel.h"
#import "UserModel.h"
#import "CTFActivityModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFHomePageViewModel : BaseViewModel

/*
 * 初始化
 */
-(instancetype)initWithUserId:(NSInteger)userId isMine:(BOOL)isMine;


/*
* 加载用户详情
*/
-(void)loadUserDetilsComplete:(AdpaterComplete)complete;

/*
* 加载个人主页数据
* @param page 页码
*/
-(void)loadUserActivitiesDataByPage:(PagingModel *)pageModel complete:(AdpaterComplete)complete;

/*
* 删除个人动态（只能删除观点）
* @param answerId 观点id
*/
-(void)deleteMyActivityWithAnswerId:(NSInteger)answerId;

/*
* 关注用户
*/
- (void)requestForFollowNeed:(BOOL)needFollow complete:(AdpaterComplete)complete;

//动态数
-(NSInteger)numberOfActitivitiesData;
//获取cell的动态
-(CTFActivityModel *)getActivityModelWithIndex:(NSInteger)index;
//是否还有更多动态
- (BOOL)hasMoreActitivtiesListData;
//获取用户信息
- (UserModel *)getUserInfo;
// 动态是否为空
- (BOOL)isEmpty;

@end

NS_ASSUME_NONNULL_END
