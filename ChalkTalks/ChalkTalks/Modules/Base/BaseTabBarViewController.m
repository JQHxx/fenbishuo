//
//  BaseTabBarViewController.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "BaseTabBarViewController.h"
#import "BaseNavigationController.h"
#import "PublishTopicViewController.h"
#import "UIViewController+CTF_CheckLoginStatement.h"
#import "CTFVersionViewModel.h"
#import "CTFConfigsViewModel.h"
#import "ChalkTalks-Swift.h"
#import "NSString+Size.h"
#import "CTFVersionView.h"
#import "NSUserDefaultsInfos.h"
#import "MainPageViewController.h"
#import "CTFCommonManager.h"
#import "CTFPublishGuideViewController.h"
#import <HWPanModal.h>

#define kViewWidth (kScreen_Width-47)/2.0
#define kViewHeight kViewWidth*(130.0/156.0)

@interface BaseTabBarViewController () <UITabBarControllerDelegate>

@property (nonatomic, strong) CTFVersionViewModel *versionViewModel; //版本控制相关VM
@property (nonatomic, strong) CTFConfigsViewModel *configsViewModel; //系统配置相关VM
@property (nonatomic, strong) CTFConfigsModel     *configsModel;

@property (nonatomic, strong) NSDate *lastSelectedDate;

@end

@implementation BaseTabBarViewController

+ (BaseTabBarViewController *)createRootViewController {
    return [[BaseTabBarViewController alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.versionViewModel = [[CTFVersionViewModel alloc] init];
    self.configsViewModel = [[CTFConfigsViewModel alloc] init];
    
    BaseNavigationController *nav1 = [self className:kMainPageViewController
                                             vcTitle:@"首页"
                                            tabTitle:@"粉笔说"
                                            tabImage:@"tabbar_1_nor"
                                    tabSelectedImage:@"tabbar_1_sel"];
    
    BaseNavigationController *nav2 = [self className:kVoteViewController
                                             vcTitle:@"投票"
                                            tabTitle:@"投票"
                                            tabImage:@"tabbar_2_nor"
                                    tabSelectedImage:@"tabbar_2_sel"];
    
    BaseNavigationController *nav3 = [self className:kMessageViewController
                                             vcTitle:@"消息"
                                            tabTitle:@"消息"
                                            tabImage:@"tabbar_3_nor"
                                    tabSelectedImage:@"tabbar_3_sel"];
    
    BaseNavigationController *nav4 = [self className:kMineViewController
                                             vcTitle:@"我的"
                                            tabTitle:@"我的"
                                            tabImage:@"tabbar_4_nor"
                                    tabSelectedImage:@"tabbar_4_sel"];
    
    BaseNavigationController *publish = [self className:@"BaseViewController"
                                                vcTitle:@""
                                               tabTitle:@""
                                               tabImage:nil
                                       tabSelectedImage:nil];
    
    self.viewControllers = @[nav1, nav2, publish, nav3, nav4];
    self.delegate = self;
    [self.tabBar setTintColor:UIColorFromHEX(0x222222)];
    
    /* 将按钮添加至tabBar上 */
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width-50)/2.0, (self.tabBar.frame.size.height-40)/2.0, 50, 40)];
    [btn setImage:ImageNamed(@"tabbar_publish_btn") forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(tabBarDidClickPlusButton) forControlEvents:UIControlEventTouchUpInside];
    [self.tabBar addSubview:btn];
    
    [self changeLineOfTabbarColor];
    
    //检测版本
    [self checkVersion];
    //系统设置
    [self loadSystemConfigs];
}

- (BaseNavigationController *)className:(NSString *)className
                                vcTitle:(NSString *)vcTitle
                               tabTitle:(NSString *)tabTitle
                               tabImage:(NSString *)image
                       tabSelectedImage:(NSString *)selectedImage {
    
    UIViewController *vc = [[NSClassFromString(className) alloc] init];
    if ([className isEqualToString:kMessageViewController]) {
        vc = [CTMessageViewController new];
    }
    vc.title = vcTitle;
    vc.tabBarItem.title = tabTitle;
    if (image) {
        vc.tabBarItem.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    if (selectedImage) {
        vc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    BaseNavigationController *navgation = [[BaseNavigationController alloc] initWithRootViewController:vc];
    return navgation;
}

//发布按钮点击事件
- (void)tabBarDidClickPlusButton {
    if (![self ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded]) {
        return;
    }
    [self showSeekRecommendView];
}

//判断是否响应-tabBarButton点击事件
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    //首页
    if ([viewController isEqual:tabBarController.viewControllers[0]]) {
        [MobClick event:@"home_tab"];
        
        // 获取当前点击时间
        NSDate *currentDate = [NSDate date];
        CGFloat timeInterval = currentDate.timeIntervalSince1970 - self.lastSelectedDate.timeIntervalSince1970;
 
        // 两次点击时间间隔少于 0.5S 视为一次双击
        if (timeInterval < 0.5) {
            // 通知首页刷新数据
            BaseNavigationController *nav = (BaseNavigationController *)viewController;
            if (nav.viewControllers.count == 0) return NO;
            // 取 navgationController 中栈底控制器
            MainPageViewController *homeVC = nav.viewControllers.firstObject;
            [homeVC refreshTableView];
 
            // 双击之后将上次选中时间置为1970年0点0时0分0秒,用以避免连续三次或多次点击
            self.lastSelectedDate = [NSDate dateWithTimeIntervalSince1970:0];
            return YES;
        }
        // 若是单击将当前点击时间复制给上一次单击时间
        self.lastSelectedDate = currentDate;
        
        return YES;
    }
    //投票
    if ([viewController isEqual:tabBarController.viewControllers[1]]) {
        [MobClick event:@"home_vote"];
        return YES;
    }
    //无
    if ([viewController isEqual:tabBarController.viewControllers[2]]) {
        return NO;
    }
    //消息
    if ([viewController isEqual:tabBarController.viewControllers[3]]) {
        if (![self ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Logined]) {
            return NO;
        }
        [MobClick event:@"home_message"];
        return YES;
    }
    //我的
    if ([viewController isEqual:tabBarController.viewControllers[4]]) {
        if (![self ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Logined]) {
            return NO;
        }
        [MobClick event:@"home_my"];
        return YES;
    }
    
    return YES;
}

//tabBarButton点击事件
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (![item.title isEqualToString:@"粉笔说"]) {
        [CTFCommonManager sharedCTFCommonManager].needVideoStop = YES;
    }
    UIImageView *imageView;
    for (UIView *view in tabBar.subviews) {
        if ([NSStringFromClass([view class]) isEqualToString:@"UITabBarButton"]) {
            for (UIView *sv in view.subviews) {
                if ([sv isKindOfClass:[UIImageView class]] && ((UIImageView *)sv).image == item.selectedImage) {
                    imageView = (UIImageView *)sv;
                }
            }
        }
    }
    
    if (imageView == nil) {
        return;
    }
    
    imageView.transform = CGAffineTransformMakeScale(0.7, 0.7);
    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:0.3
          initialSpringVelocity:0.3
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        imageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:nil];
}

#pragma mark 求推荐
- (void)seekRecommendationWithTag:(NSInteger )viewTag {
    [MobClick event:@"home_add"];
    NSInteger index = viewTag-100;
    CTFQuestionsModel *model = [[CTFQuestionsModel alloc] init];
    model.type = index==0 ? @"demand" : @"recommend";
    PublishTopicViewController *topicVC = [[PublishTopicViewController alloc] init];
    topicVC.questionsModel = model;
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:topicVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark -- Private methods
#pragma mark 版本检测
- (void)checkVersion{
    @weakify(self);
    [self.versionViewModel checkVersioncomplete:^(BOOL isSuccess) {
        if (isSuccess) {
            @strongify(self);
            CTFVersionModel *model = [self.versionViewModel getTargetVersion];
            if (![model.status isEqualToString:@"skip"]) { //需要更新
                [self showVersionUpdateWithModel:model];
            }
        }
    }];
}

#pragma mark 系统配置
- (void)loadSystemConfigs{
    @weakify(self);
    [self.configsViewModel systemConfigsComplete:^(BOOL isSuccess) {
        @strongify(self);
        if (isSuccess) {
            self.configsModel = [self.configsViewModel getTSysConfigs];
            if (self.configsModel.questionTitleSuffix.count>0) {
                [CTFCommonManager sharedCTFCommonManager].questionTitleSuffix = self.configsModel.questionTitleSuffix;
            }
        }
    }];
}

#pragma mark 显示版本提示
- (void)showVersionUpdateWithModel:(CTFVersionModel *)version{
    CGFloat contentH = [version.content boundingRectWithSize:CGSizeMake(220, CGFLOAT_MAX) withTextFont:[UIFont regularFontWithSize:14]].height;
    [CTFVersionView showVersionViewWithFrame:CGRectMake(0, 0, 260, contentH+270) version:version];
}

#pragma mark 修改横线颜色
- (void)changeLineOfTabbarColor {
    CGRect rect = CGRectMake(0.0f, 0.0f, kScreen_Width, 0.5);
    UIGraphicsBeginImageContextWithOptions(rect.size,NO, 0);
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, UIColorFromHEX(0xEDEDED).CGColor);
    CGContextFillRect(context, rect);
    UIImage *image =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.tabBar setShadowImage:image];
    [self.tabBar setBackgroundImage:[UIImage new]];
}

#pragma mark 显示弹出框
- (void)showSeekRecommendView{
    CTFPublishGuideViewController *guideVC = [[CTFPublishGuideViewController alloc] init];
    guideVC.guideVideo = self.configsModel.questionGuideVideo;
    kSelfWeak;
    guideVC.dismissBlock = ^(NSInteger viewTag) {
        [weakSelf seekRecommendationWithTag:viewTag];
    };
    [self presentPanModal:guideVC];

}

#pragma mark -- Getters
- (CTFConfigsModel *)configsModel{
    if (!_configsModel) {
        _configsModel = [[CTFConfigsModel alloc] init];
    }
    return _configsModel;
}

@end
