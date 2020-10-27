//
//  RNNativeStackNavigator.m
//  owl
//
//  Created by Bell Zhong on 2019/10/16.
//  Copyright © 2019 shimo.im. All rights reserved.
//

#import "RNNativeStackNavigator.h"
#import "RNNativeStackNavigatorController.h"
#import "RNNativeSceneController.h"
#import "RNNativePushAnimatedTransition.h"
#import "RNNativePopAnimatedTransition.h"

@interface RNNativeStackNavigator () <UINavigationControllerDelegate>

@property (nonatomic, strong) UINavigationController *controller;

@end

@implementation RNNativeStackNavigator

- (instancetype)initWithBridge:(RCTBridge *)bridge {
    _controller = [[RNNativeStackNavigatorController alloc] init];
    _controller.delegate = self;
    [_controller setNavigationBarHidden:YES];
    
    return [super initWithBridge:bridge viewController:_controller];
}

#pragma mark - UINavigationControllerDelegate

/**
 自定义 push pop 动画
 */
- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC {
    if (operation != UINavigationControllerOperationNone) {
        UIViewController *targetController = operation == UINavigationControllerOperationPush ? toVC : fromVC;
        if ([targetController isKindOfClass:[RNNativeSceneController class]]) {
            RNNativeSceneController *controller = (RNNativeSceneController *)targetController;
            RNNativeSceneTransition transition = controller.nativeScene.transition;
            if (transition != RNNativeSceneTransitionDefault && transition != RNNativeSceneTransitionNone) {
                if (operation == UINavigationControllerOperationPush) {
                    return [[RNNativePushAnimatedTransition alloc] initWithTransition:transition];
                } else {
                    return [[RNNativePopAnimatedTransition alloc] initWithTransition:transition];
                }
            }
        }
    }
    return nil;
}

#pragma mark - RNNativeBaseNavigator

- (BOOL)isDismissedForViewController:(UIViewController *)viewController {
    return viewController && ![_controller.viewControllers containsObject:viewController];
}

/**
 push or pop
 
 不调用  beginTransition 和 endTransition，使用 viewXXXAppear 管理 RNNativeSceneStatus
 */
- (void)updateSceneWithTransition:(RNNativeSceneTransition)transition
                           action:(RNNativeStackNavigatorAction)action
                       nextScenes:(NSArray<RNNativeScene *> *)nextScenes
                    removedScenes:(NSArray<RNNativeScene *> *)removedScenes
                   insertedScenes:(NSArray<RNNativeScene *> *)insertedScenes
                  beginTransition:(RNNativeNavigatorTransitionBlock)beginTransition
                    endTransition:(RNNativeNavigatorTransitionBlock)endTransition {
    BOOL hasAnimation = transition != RNNativeSceneTransitionNone && action != RNNativeStackNavigatorActionNone;
    beginTransition(!hasAnimation);
    
    NSMutableArray<UIViewController *> *willShowViewControllers = [NSMutableArray new];
    for (RNNativeScene *scene in nextScenes) {
        [willShowViewControllers addObject:scene.controller];
    }
    
    if (hasAnimation) { // 有动画
        if (action == RNNativeStackNavigatorActionShow) { // 显示
            NSMutableArray<UIViewController *> *newControllers = [NSMutableArray arrayWithArray:willShowViewControllers];
            [newControllers removeLastObject];
            [_controller setViewControllers:newControllers animated:NO];
            [_controller pushViewController:[willShowViewControllers lastObject] animated:YES];
        } else { // 隐藏
            NSMutableArray<UIViewController *> *newControllers = [NSMutableArray arrayWithArray:willShowViewControllers];
            [newControllers addObject:[self.currentScenes lastObject].controller];
            [_controller setViewControllers:newControllers animated:NO];
            [_controller popViewControllerAnimated:YES];
        }
    } else { // 无动画
        [_controller setViewControllers:willShowViewControllers animated:NO];
    }
    endTransition(!hasAnimation);
}

@end

