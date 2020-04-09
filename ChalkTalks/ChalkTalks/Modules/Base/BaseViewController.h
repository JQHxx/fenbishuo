//
//  BaseViewController.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "UIColor+DefColors.h"
#import <UMAnalytics/MobClick.h>
#import "CTModels.h"
#import "NSObject+Routes.h"
#import "BaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

@property (nonatomic ,assign) BOOL        isHiddenBackBtn;      //隐藏返回按钮
@property (nonatomic ,assign) BOOL        isHiddenNavBar;       //隐藏导航栏
@property (nonatomic , copy ) NSString    *baseTitle;           //标题
@property (nonatomic , copy ) NSString    *leftImageName;       //导航栏左侧图片名称
@property (nonatomic , copy ) NSString    *leftTitleName;       //导航栏左侧标题名称
@property (nonatomic , copy ) NSString    *rightImageName;      //导航栏右侧图片名称
@property (nonatomic , copy ) NSString    *rigthTitleName;      //导航栏右侧标题名称

@property (nonatomic ,strong) UIView      *baseNavView;   
@property (nonatomic ,strong) UIButton    *rightBtn;   //导航栏右侧按钮

@property (nonatomic,strong) BaseViewModel  *baseViewModel;

-(void)leftNavigationItemAction;
-(void)rightNavigationItemAction;

//显示网络错误
-(void)showNetErrorViewWithType:(ERRORTYPE)type whetherLittleIconModel:(BOOL)isLittleIconModel frame:(CGRect)frame;
//隐藏网络错误
-(void)hideNetErrorView;
//刷新数据
-(void)baseRefreshData;

@end

NS_ASSUME_NONNULL_END
