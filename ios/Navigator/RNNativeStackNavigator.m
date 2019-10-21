//
//  RNNativeStackNavigator.m
//  owl
//
//  Created by Bell Zhong on 2019/10/16.
//  Copyright © 2019 shimo.im. All rights reserved.
//

#import "RNNativeStackNavigator.h"
#import "RNNativeStackNavigationController.h"
#import "RNNativeStackController.h"
#import "RNNativePushAnimatedTransition.h"
#import "RNNativePopAnimatedTransition.h"

@interface RNNativeStackNavigator () <UINavigationControllerDelegate>

@property (nonatomic, strong) UINavigationController *controller;

@end

@implementation RNNativeStackNavigator

- (instancetype)init
{
    _controller = [[RNNativeStackNavigationController alloc] init];
    _controller.delegate = self;
    [_controller setNavigationBarHidden:YES];
    
    self = [super initWithViewController:_controller];
    return self;
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
        if ([targetController isKindOfClass:[RNNativeStackController class]]) {
            RNNativeStackController *controller = (RNNativeStackController *)targetController;
            RNNativeStackSceneTransition transition = controller.scene.transition;
            if (transition != RNNativeStackSceneTransitionSlideFormRight && transition != RNNativeStackSceneTransitionNone) {
                // 无动画，或者从右进入的动画使用系统动画
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

/**
 push or pop
 */
- (void)updateSceneWithTransition:(RNNativeStackSceneTransition)transition
                           action:(RNNativeStackNavigatorAction)action
                      nextScrenes:(NSArray<RNNativeStackScene *> *)nextScrenes
                    removedScenes:(NSMutableArray<RNNativeStackScene *> *)removedScenes
                   insertedScenes:(NSMutableArray<RNNativeStackScene *> *)insertedScenes {
    NSMutableArray<UIViewController *> *willShowViewControllers = [NSMutableArray new];
    for (RNNativeStackScene *scene in nextScrenes) {
        [willShowViewControllers addObject:scene.controller];
    }
    
    if (transition == RNNativeStackSceneTransitionNone || action == RNNativeStackNavigatorActionNone) { // 无动画
        [_controller setViewControllers:willShowViewControllers animated:NO];
    } else { // 有动画
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
    }
}

@end
