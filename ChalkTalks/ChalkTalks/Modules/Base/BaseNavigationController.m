//
//  BaseNavigationController.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController () <UINavigationControllerDelegate>

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
   if (viewController == navigationController.viewControllers[0]) {
       navigationController.interactivePopGestureRecognizer.enabled = NO;
   } else {
       navigationController.interactivePopGestureRecognizer.enabled = YES;
   }
}

@end
