//
//  RNNativeStackNavigatorController.m
//  owl
//
//  Created by Bell Zhong on 2019/10/21.
//  Copyright © 2019 shimo.im. All rights reserved.
//

#import "RNNativeStackNavigatorController.h"
#import "RNNativeScene.h"
#import "RNNativePanGestureRecognizerManager.h"

#import <React/RCTRootContentView.h>
#import <React/RCTTouchHandler.h>

@interface RNNativeStackNavigatorController () <UIGestureRecognizerDelegate>

@end

@implementation RNNativeStackNavigatorController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    id target = self.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer *pan = [UIPanGestureRecognizer new];
    [pan addTarget:target action:NSSelectorFromString(@"handleNavigationTransition:")];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    [[RNNativePanGestureRecognizerManager sharedInstance] addPanGestureRecognizer:pan];

    self.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // INFO: push viewController 的同时旋转屏幕，UIViewControllerWrapperView 会保持旋转屏幕之前的 frame，新的 viewController 也会保持屏幕旋转之前的 frame。
    // 为了修复这个问题，重新布局的时候重新设置 frame。
    UIView *navigationTransitionView = [self findAndUpdateSubviewWithView:self.view className:@"UINavigationTransitionView"];
    if (navigationTransitionView) {
        UIView *viewControllerWrapperView = [self findAndUpdateSubviewWithView:navigationTransitionView className:@"UIViewControllerWrapperView"];
    }
    UIView *view = self.topViewController.view;
    if ([view isKindOfClass:[RNNativeScene class]]) {
        [self updateFrameWithView:view parentView:self.view];
    }
}

-(UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

-(UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return NO;
    }
    
    UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
    CGPoint point = [panGestureRecognizer translationInView:panGestureRecognizer.view];
    if (point.x <= 0) {
        return NO;
    }
    
    CGPoint location = [gestureRecognizer locationInView:self.view];
    if (location.x > RNNativePanGestureEdgeWidth) {
        return NO;
    }

    // cancel touches in parent, this is needed to cancel RN touch events. For example when Touchable
    // item is close to an edge and we start pulling from edge we want the Touchable to be cancelled.
    // Without the below code the Touchable will remain active (highlighted) for the duration of back
    // gesture and onPress may fire when we release the finger.
    UIView *parent = self.view;
    while (parent != nil && ![parent isKindOfClass:[RCTRootContentView class]]) parent = parent.superview;
    RCTRootContentView *rootView = (RCTRootContentView *)parent;
    [rootView.touchHandler cancel];

    UINavigationController *navigationController = [self getTargetNavigationController:self];
    if (navigationController.viewControllers.count > 1) {
        UIView *view = navigationController.topViewController.view;
        if ([view isKindOfClass:[RNNativeScene class]]) {
            RNNativeScene *scene = (RNNativeScene *)view;
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

#pragma mark - Private

- (UIView *)findAndUpdateSubviewWithView:(UIView *)view className:(NSString *)className {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:NSClassFromString(className)]) {
            [self updateFrameWithView:subview parentView:view];
            return subview;
        }
    }
    return nil;
}

- (void)updateFrameWithView:(UIView *)view parentView:(UIView *)parentView {
    CGRect parentFrame = parentView.frame;
    CGRect frame = view.frame;
    if (!CGRectEqualToRect(frame, parentFrame)) {
        view.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(parentFrame), CGRectGetHeight(parentFrame));
    }
}

@end
