//
//  OpenRoutesManager.m
//  StarryNight
//
//  Created by zingwin on 2017/1/22.
//  Copyright © 2017年 zwin. All rights reserved.
//

#import "OpenRoutesManager.h"
#import <JLRoutes/JLRoutes.h>
#import "NSObject+Routes.h"
#import "BaseNavigationController.h"
#import "AppDelegate.h"

NSString* const kMainPageViewController = @"MainPageViewController";
NSString* const kVoteViewController = @"VoteViewController";
NSString* const kMessageViewController = @"MessageViewController";
NSString* const kMineViewController = @"MineViewController";
NSString* const kLoginViewController = @"LoginViewController";
NSString* const kPublishTopicViewController = @"PublishTopicViewController";
NSString* const kPhoneLoginViewController = @"PhoneLoginViewController";
NSString* const kbindPhoneViewController = @"PhoneLoginViewController?isBindPhone=1";
NSString* const kCTFTopicDetailsVC = @"CTFTopicDetailsVC";
NSString* const kCTFPersonalSettingVC = @"CTFPersonalSettingVC";
NSString* const kCTFNickNameSettingVC = @"CTFNickNameSettingVC";
NSString* const kCTFSignContentSettingVC = @"CTFSignContentSettingVC";
NSString* const kCTFFeedBackVC = @"CTFFeedBackVC";
NSString* const kCTFMineTopicListVC = @"CTFMineTopicListVC";
NSString* const kCTFMineCareTopicListVC = @"CTFMineCareTopicListVC";
NSString* const kCTFMineViewPointListVC = @"CTFMineViewPointListVC";
NSString* const kCTFMineFansListVC = @"CTFMineFansListVC";
NSString* const kCTFMineFollowListVC = @"CTFMineFollowListVC";
NSString* const kCTFAboutUsVC = @"CTFAboutUsVC";
NSString* const kCTFUserAgreementVC = @"CTFUserAgreementVC";
NSString* const kCTFPublishImageViewpointVC = @"CTFPublishImageViewpointVC";
NSString* const kCTFPublishVideoViewpointVC = @"CTFPublishVideoViewpointVC";
NSString* const kCTFPersonalHomepageVC = @"CTFPersonalHomepageVC";
NSString* const kCTFSearchVC = @"CTFSearchVC";
NSString* const kCTFHomePageVC = @"CTFHomePageVC";
NSString* const kCTFPickVideoCoverVC = @"CTFPickVideoCoverVC";
NSString* const kCTFDraftBoxVC = @"CTFDraftBoxVC";


typedef NS_ENUM(NSUInteger, NavMethod) {
    push,
    present,
    tabhome,
};

@implementation OpenRoutesManager
{
    BOOL isAnimation;
    BOOL isPresentWithNavBar;
}

+(void)load {
    [ROUTER registSchema];
}

+(id)shareInstance{
    static OpenRoutesManager *content = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (content == nil) {
            content = [[OpenRoutesManager alloc] init];
        }
    });
    return content;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        isAnimation=YES;
        isPresentWithNavBar=NO;
    }
    return self;
}

/// App Router 配置项目
-(NSArray*)routeConfigs{
    NSArray *routes = @[
        @{@"cls":kMainPageViewController, @"method": @(tabhome)},
        @{@"cls":kVoteViewController, @"method": @(tabhome)},
        @{@"cls":kMessageViewController, @"method": @(tabhome)},
        @{@"cls":kMineViewController, @"method": @(tabhome)},
        @{@"cls":kLoginViewController, @"method": @(present)},
        @{@"cls":kPublishTopicViewController, @"method": @(present)},
        @{@"cls":kPhoneLoginViewController, @"method": @(push)},
        @{@"cls":kbindPhoneViewController, @"method": @(push)},
        @{@"cls":kCTFTopicDetailsVC, @"method": @(push)},
        @{@"cls":kCTFPersonalSettingVC, @"method": @(push)},
        @{@"cls":kCTFNickNameSettingVC, @"method": @(push)},
        @{@"cls":kCTFSignContentSettingVC, @"method": @(push)},
        @{@"cls":kCTFFeedBackVC, @"method": @(push)},
        @{@"cls":kCTFMineTopicListVC, @"method": @(push)},
        @{@"cls":kCTFMineCareTopicListVC, @"method": @(push)},
        @{@"cls":kCTFMineViewPointListVC, @"method": @(push)},
        @{@"cls":kCTFMineFansListVC, @"method": @(push)},
        @{@"cls":kCTFMineFollowListVC, @"method": @(push)},
        @{@"cls":kCTFAboutUsVC, @"method": @(push)},
        @{@"cls":kCTFUserAgreementVC, @"method": @(push)},
        @{@"cls":kCTFPublishImageViewpointVC, @"method": @(present)},
        @{@"cls":kCTFPublishVideoViewpointVC, @"method": @(present)},
        @{@"cls":kCTFPersonalHomepageVC, @"method": @(push)},
        @{@"cls":kCTFSearchVC, @"method": @(push)},
        @{@"cls":kCTFHomePageVC,@"method":@(push)},
        @{@"cls":kCTFPickVideoCoverVC,@"method":@(push)},
        @{@"cls":kCTFDraftBoxVC,@"method":@(push)},
    ];
    return routes;
}

-(void)routeByCls:(NSString*)kcls withParam:(NSDictionary*)param{
    //参数序列号
    NSMutableString *str = [[NSMutableString alloc] init];
    for (NSString *key in param.allKeys) {
        NSString *args = [NSString stringWithFormat:@"%@=%@&",key,[param objectForKey:key]];
        [str appendString:args];
    }
    NSString *p = [NSString stringWithFormat:@"%@?%@",kcls,str];
    [self routeByCls:p];
}

-(void)routeByCls:(NSString*)kcls
            param:(NSDictionary*)param
        animation:(BOOL)animation
presentWithNavBar:(BOOL)presentWithNavBar{
    isAnimation = animation;
    isPresentWithNavBar = presentWithNavBar;
    [self routeByCls:kcls withParam:param];
}

-(void)routeByCls:(NSString*)kcls{
    isAnimation = YES;
    [self routeSchemaByString:[NSString stringWithFormat:@"chalktalks://%@",kcls]];
}

-(void)routeSchemaByString:(NSString*)urlstr{
    NSString *encodingString = [urlstr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self routeSchemaByURL:[NSURL URLWithString:encodingString]];
}

-(void)routeSchemaByURL:(NSURL*)url
{
    if ([url.scheme isEqualToString:@"http"]) {
        // to webview
        return;
    }
    [[JLRoutes globalRoutes] routeURL:url];
}

-(void)registSchema{
    NSArray *arr = [self routeConfigs];
    for (NSDictionary *item in arr) {
        NSString *cls = [item objectForKey:@"cls"];
        NSString *method = [item objectForKey:@"method"];
        if([method isEqual:@(push)]){
            [[JLRoutes globalRoutes] addRoute:cls  handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
                [self navigationToViewControler:cls argu:parameters];
                return YES;
            }];
        }else if([method isEqual:@(tabhome)]){
            [[JLRoutes globalRoutes] addRoute:cls  handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
                [self switchToTabControler:cls argu:parameters];
                return YES;
            }];
        }else if([method isEqual:@(present)]){
            [[JLRoutes globalRoutes] addRoute:cls  handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
                [self presentToViewControler:cls argu:parameters];
                return YES;
            }];
        }
    }
}

-(UIViewController*)viewControllerForCls:(NSString*)kcls{
    NSArray *arr = [self routeConfigs];
    for (NSDictionary *item in arr) {
        NSString *cls = [item objectForKey:@"cls"];
        if ([kcls isEqualToString:cls]) {
            return [[NSClassFromString(kcls) alloc] init];
        }
    }
    return nil;
}

#pragma mark - help
-(void)switchToTabControler:(NSString*)vcIdentifier argu:(NSDictionary*)argu{
    UITabBarController *tab = (UITabBarController*)[self getCurrentRootViewController];
    UINavigationController *nav = tab.viewControllers[tab.selectedIndex];
    [nav popToRootViewControllerAnimated:NO];
    if ([vcIdentifier isEqualToString:kMainPageViewController]) {
        [tab setSelectedIndex:0];
    }else if ([vcIdentifier isEqualToString:kVoteViewController]){
        [tab setSelectedIndex:1];
    }else if ([vcIdentifier isEqualToString:kMessageViewController]){
        [tab setSelectedIndex:3];
    }else if ([vcIdentifier isEqualToString:kMineViewController]){
        [tab setSelectedIndex:4];
    }
}

-(void)presentToViewControler:(NSString*)vcIdentifier argu:(NSDictionary*)argu{
    UIViewController *topvc = [self topViewController];
    UIViewController *tarvc = [[NSClassFromString(vcIdentifier) alloc] init];
    tarvc.schemaArgu = argu;
    [tarvc setHidesBottomBarWhenPushed:YES];
    if(isPresentWithNavBar){
        BaseNavigationController *navtar = [[BaseNavigationController alloc] initWithRootViewController:tarvc];
        navtar.modalPresentationStyle = UIModalPresentationFullScreen;
        [topvc presentViewController:navtar animated:isAnimation completion:nil];
    }else{
//        tarvc.modalPresentationStyle = UIModalPresentationFullScreen;
        [topvc presentViewController:tarvc animated:isAnimation completion:nil];
    }
    
//    UITabBarController *tab = (UITabBarController*)[self getCurrentRootViewController];
//    UINavigationController *nav = tab.viewControllers[tab.selectedIndex];
//    UIViewController *tarvc = [[NSClassFromString(vcIdentifier) alloc] init];
//    BaseNavigationController *navtar = [[BaseNavigationController alloc] initWithRootViewController:tarvc];
//    navtar.modalPresentationStyle = UIModalPresentationFullScreen;
//    tarvc.schemaArgu = argu;
//    [tarvc setHidesBottomBarWhenPushed:YES];
//    UIViewController *vis = [nav visibleViewController];
//    if (vis && vis.navigationController){
//        [vis presentViewController:navtar animated:isAnimation completion:nil];
//    }else{
//        [nav presentViewController:navtar animated:isAnimation completion:nil];
//    }
}

-(void)navigationToViewControler:(NSString*)vcIdentifier argu:(NSDictionary*)argu{
    UIViewController *topvc = [self topViewController];
    
    UIViewController *tarvc = [[NSClassFromString(vcIdentifier) alloc] init];
    tarvc.schemaArgu = argu;
    [tarvc setHidesBottomBarWhenPushed:YES];
    
    if(topvc && topvc.navigationController){
        [topvc.navigationController pushViewController:tarvc animated:isAnimation];
    }else{
        NSAssert(YES, @"当前页面没有包含在导航栏里面，无法导航");
    }
    
//    UITabBarController *tab = (UITabBarController*)[self getCurrentRootViewController];
//    UINavigationController *nav = tab.viewControllers[tab.selectedIndex];
//    UIViewController *tarvc = [[NSClassFromString(vcIdentifier) alloc] init];
//
//    tarvc.schemaArgu = argu;
//    [tarvc setHidesBottomBarWhenPushed:YES];
//    UIViewController *vis = [nav visibleViewController];
//    if (vis && vis.navigationController) {
//        [vis.navigationController pushViewController:tarvc animated:YES];
//    }else{
//        [nav pushViewController:tarvc animated:YES];
//    }
//    if ([nav respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        nav.interactivePopGestureRecognizer.delegate = nil;
//    }
}

-(UIViewController *)getCurrentRootViewController {
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *rootVC = appdelegate.window.rootViewController;
    return rootVC;
}

- (UIViewController *)topViewController {
    UIViewController *resultVC = [self _topViewController:[self getCurrentRootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}
@end
