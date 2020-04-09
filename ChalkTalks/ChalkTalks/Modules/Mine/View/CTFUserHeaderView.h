//
//  CTFUserHeaderView.h
//  ChalkTalks
//
//  Created by vision on 2019/12/26.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

NS_ASSUME_NONNULL_BEGIN

@class CTFUserHeaderView;
@protocol CTFUserHeaderViewDelegate <NSObject>

//个人设置
-(void)userHeaderViewDidPushToUserSet:(CTFUserHeaderView *)headerView;
//关注
-(void)userHeaderViewDidFollow:(CTFUserHeaderView *)headerView needFollow:(BOOL)needFollow;
//靠谱
-(void)userHeaderView:(CTFUserHeaderView *)headerView setActionWithTag:(NSInteger)tag;

@end

@interface CTFUserHeaderView : UIView

@property (nonatomic,strong) UserModel    *userDetails;
@property (nonatomic, weak ) id<CTFUserHeaderViewDelegate>viewDelegate;

-(instancetype)initWithFrame:(CGRect)frame isMine:(BOOL)isMine;

- (void)updateBadgesWall:(NSArray<CTFBadgeModel *> *)badgesArray;

@end

NS_ASSUME_NONNULL_END
