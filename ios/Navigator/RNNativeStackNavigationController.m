//
//  RNNativeStackNavigationController.m
//  owl
//
//  Created by Bell Zhong on 2019/10/21.
//  Copyright © 2019 shimo.im. All rights reserved.
//

#import "RNNativeStackNavigationController.h"
#import "RNNativeStackScene.h"

@interface RNNativeStackNavigationController () <UIGestureRecognizerDelegate>

@end

@implementation RNNativeStackNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    id target = self.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer *pan = [UIPanGestureRecognizer new];
    [pan addTarget:target action:NSSelectorFromString(@"handleNavigationTransition:")];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    self.interactivePopGestureRecognizer.enabled = NO;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    UINavigationController *navigationController = [self getTargetNavigationController:self];
    if (navigationController.viewControllers.count > 1) {
        UIView *view = navigationController.topViewController.view;
        if ([view isKindOfClass:[RNNativeStackScene class]]) {
            RNNativeStackScene *scene = (RNNativeStackScene *)view;
            return scene.gestureEnabled;
        }
    }
    return NO;
}

- (UINavigationController *)getTargetNavigationController:(UINavigationController *)navigationController {
    NSArray<__kindof UIViewController *> *childViewControllers = navigationController.topViewController.childViewControllers;
    for (NSInteger index = 0, size = childViewControllers.count; index < size; index++) {
        UIViewController *viewController = childViewControllers[size - index - 1];
        if ([viewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *targetNavigationController = (UINavigationController *)viewController;
            if (targetNavigationController.viewControllers.count > 1) {
                return [self getTargetNavigationController:targetNavigationController];
            }
        }
    }
    return navigationController;
}

@end
