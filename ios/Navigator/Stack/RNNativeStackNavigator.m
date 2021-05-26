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

- (void)insertReactSubview:(UIView *)subview atIndex:(NSInteger)atIndex {
    [super insertReactSubview:subview atIndex:atIndex];
    if ([subview isKindOfClass:[RNNativeScene class]]) {
        RNNativeScene *scene = (RNNativeScene *)subview;
        scene.enableLifeCycle = YES;
    }
}

- (void)removeReactSubview:(UIView *)subview {
    [super removeReactSubview:subview];
    if ([subview isKindOfClass:[RNNativeScene class]]) {
        RNNativeScene *scene = (RNNativeScene *)subview;
        scene.enableLifeCycle = NO;
    }
}

/**
 push or pop
 
 不调用  beginTransition 和 endTransition，使用 viewXXXAppear 管理 RNNativeSceneStatus
 */
- (void)updateSceneWithTransition:(RNNativeSceneTransition)transition
                           action:(RNNativeStackNavigatorAction)action
                    currentScenes:(NSArray<RNNativeScene *> *)currentScenes
                       nextScenes:(NSArray<RNNativeScene *> *)nextScenes
                    removedScenes:(NSArray<RNNativeScene *> *)removedScenes
                   insertedScenes:(NSArray<RNNativeScene *> *)insertedScenes
                  beginTransition:(RNNativeNavigatorTransitionBlock)beginTransition
                    endTransition:(RNNativeNavigatorTransitionBlock)endTransition {
    BOOL hasAnimation = transition != RNNativeSceneTransitionNone && action != RNNativeStackNavigatorActionNone;
    beginTransition(!hasAnimation);
    
    NSMutableArray<UIViewController *> *willShowViewControllers = [NSMutableArray new];
    for (RNNativeScene *scene in nextScenes) {
        if (![willShowViewControllers containsObject:scene.controller]) {
            [willShowViewControllers addObject:scene.controller];
        }
    }
    
    if (hasAnimation) { // 有动画
        if (action == RNNativeStackNavigatorActionShow) { // 显示
            NSInteger willShowViewControllersCount = willShowViewControllers.count;
            if (willShowViewControllersCount > 0) {
                NSArray *viewControllers = [willShowViewControllers subarrayWithRange:NSMakeRange(0, willShowViewControllersCount - 1)];
                // INFO 当前可见的 ViewController 不在 willShowViewControllers 时，为防止出现界面抖动的问题，先不移除，动画结束后再移除
                UIViewController *outViewController = _controller.visibleViewController;
                if (outViewController) {
                    if ([willShowViewControllers containsObject:outViewController]) {
                        outViewController = nil;
                    } else {
                        viewControllers = [viewControllers arrayByAddingObject:outViewController];
                    }
                }
                [_controller setViewControllers:viewControllers animated:NO];
                [_controller pushViewController:[willShowViewControllers lastObject] animated:YES];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSMutableArray *currentViewControllers = [_controller.viewControllers mutableCopy];
                    if (outViewController && [currentViewControllers containsObject:outViewController]) {
                        [currentViewControllers removeObject:outViewController];
                        [_controller setViewControllers:currentViewControllers animated:NO];
                    }
                });
            } else {
                [_controller setViewControllers:willShowViewControllers animated:NO];
            }
        } else { // 隐藏
            if (currentScenes.count) {
                // INFO: fix https://console.firebase.google.com/project/shimo-ios/crashlytics/app/ios:chuxin.shimo.wendang.2014/issues/9459c34c470c7aa1be4bab8c93777ea9
                // https://console.firebase.google.com/project/shimo-ios/crashlytics/app/ios:chuxin.shimo.wendang.2014/issues/24bb183291e800bef919893f22702bd5
                // scene.controller 可能已经被释放。
                UIViewController *lastController = [currentScenes lastObject].controller;
                if (lastController) {
                    NSMutableArray<UIViewController *> *newControllers = [NSMutableArray arrayWithArray:willShowViewControllers];
                    [newControllers addObject:lastController];
                    [_controller setViewControllers:newControllers animated:NO];
                    [_controller popViewControllerAnimated:YES];
                } else {
                    [_controller setViewControllers:willShowViewControllers animated:NO];
                }
            } else {
                [_controller setViewControllers:willShowViewControllers animated:NO];
            }
        }
    } else { // 无动画
        [_controller setViewControllers:willShowViewControllers animated:NO];
    }
    // 有动画时 UINavigationController 导航结束没有回调，所以无法在导航结束时更新 scene.status。
    // 采用 scene.viewController 的生命周期来更新 scene.status
    endTransition(!hasAnimation);
}

@end
