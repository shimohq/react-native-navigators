//
//  RNNativeCardNavigator.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2019/10/25.
//

#import "RNNativeCardNavigator.h"
#import "RNNativeStackScene.h"
#import <React/RCTUIManager.h>

@interface RNNativeCardNavigator()

@property (nonatomic, strong) UIViewController *controller;

@end

@implementation RNNativeCardNavigator

- (instancetype)initWithBridge:(RCTBridge *)bridge {
    _controller = [UIViewController new];
    return [super initWithBridge:bridge viewController:_controller];
}

#pragma mark - RNNativeBaseNavigator

- (BOOL)isDismissedForViewController:(UIViewController *)viewController {
    return viewController && ![_controller.childViewControllers containsObject:viewController];
}

/**
 addChildViewController removeFromParentViewController
 */
- (void)updateSceneWithTransition:(RNNativeStackSceneTransition)transition
                           action:(RNNativeStackNavigatorAction)action
                       nextScenes:(NSArray<RNNativeStackScene *> *)nextScenes
                    removedScenes:(NSArray<RNNativeStackScene *> *)removedScenes
                   insertedScenes:(NSArray<RNNativeStackScene *> *)insertedScenes
                  beginTransition:(RNNativeNavigatorTransitionBlock)beginTransition
                    endTransition:(RNNativeNavigatorTransitionBlock)endTransition {
    beginTransition();
    
    // addChildViewController
    for (NSInteger index = 0, size = insertedScenes.count; index < size; index++) {
        RNNativeStackScene *scene = insertedScenes[index];
        [self.controller addChildViewController:scene.controller];
    }
    
    // update will show view frame
    RNNativeStackScene *currentTopScene = self.currentScenes.lastObject;
    RNNativeStackScene *nextTopScene = nextScenes.lastObject;
    if (action == RNNativeStackNavigatorActionShow && transition != RNNativeStackSceneTransitionNone) {
        nextTopScene.frame = [self getFrameWithContainerView:_controller.view transition:transition];
    }
    
    // addSubview
    for (NSInteger index = 0, size = nextScenes.count; index < size; index++) {
        BOOL willShow = NO;
        if (index + 1 == size) {
            willShow = YES;
        } else {
            RNNativeStackScene *nextScene = nextScenes[index + 1];
            willShow = nextScene.transparent;
        }
        if (willShow) {
            RNNativeStackScene *scene = nextScenes[index];
            [self addSubview:scene toView:_controller.view];
        }
    }
    
    // transition
    if (transition == RNNativeStackSceneTransitionNone || action == RNNativeStackNavigatorActionNone) {
        [self removeScenesWithNextScenes:nextScenes removedScenes:removedScenes action:action];
        endTransition();
    } else if (action == RNNativeStackNavigatorActionShow) {
        [UIView animateWithDuration:0.35 animations:^{
            nextTopScene.frame = self.controller.view.bounds;
        } completion:^(BOOL finished) {
            [nextTopScene.controller didMoveToParentViewController:self.controller];
            [self removeScenesWithNextScenes:nextScenes removedScenes:removedScenes action:action];
            endTransition();
        }];
    } else if (action == RNNativeStackNavigatorActionHide) {
        [self addSubview:currentTopScene toView:_controller.view];
        [currentTopScene.controller willMoveToParentViewController:nil];
        [UIView animateWithDuration:0.35 animations:^{
            currentTopScene.frame = [self getFrameWithContainerView:self.controller.view transition:transition];
        } completion:^(BOOL finished) {
            [self removeScenesWithNextScenes:nextScenes removedScenes:removedScenes action:action];
            endTransition();
        }];
    }
}

#pragma mark - Layout

- (void)removeScenesWithNextScenes:(NSArray<RNNativeStackScene *> *)nextScenes
                     removedScenes:(NSArray<RNNativeStackScene *> *)removedScenes
                            action:(RNNativeStackNavigatorAction)action {
    // removedScenes
    for (NSInteger index = 0, size = removedScenes.count; index < size; index++) {
        RNNativeStackScene *scene = removedScenes[index];
        [scene removeFromSuperview];
        [scene.controller removeFromParentViewController];
    }
    
    // nextScenes
    for (NSInteger index = 0, size = nextScenes.count; index < size; index++) {
        if (index + 1 == size) {
            continue;
        }
        RNNativeStackScene *scene = nextScenes[index];
        RNNativeStackScene *nextScene = nextScenes[index + 1];
        if (!nextScene.transparent && [scene superview]) {
            [scene removeFromSuperview];
        }
    }
}

- (void)addSubview:(UIView *)subview toView:(UIView *)view {
    UIView *superView = [subview superview];
    if (superView) {
        if (superView == view) {
            [superView bringSubviewToFront:subview];
        } else {
            [subview removeFromSuperview];
            [view addSubview:subview];
        }
    } else {
        [view addSubview:subview];
    }
}

- (CGRect)getFrameWithContainerView:(UIView *)containerView transition:(RNNativeStackSceneTransition)transition {
    CGRect containerBounds = containerView.bounds;
    CGRect frame;
    switch (transition) {
        case RNNativeStackSceneTransitionSlideFormRight:
            frame = CGRectMake(CGRectGetMaxX(containerBounds), CGRectGetMinY(containerBounds), CGRectGetWidth(containerBounds), CGRectGetHeight(containerBounds));
            break;
        case RNNativeStackSceneTransitionSlideFormLeft:
            frame = CGRectMake(-CGRectGetMaxX(containerBounds), CGRectGetMinY(containerBounds), CGRectGetWidth(containerBounds), CGRectGetHeight(containerBounds));
            break;
        case RNNativeStackSceneTransitionSlideFormTop:
            frame = CGRectMake(CGRectGetMinX(containerBounds), -CGRectGetMaxY(containerBounds), CGRectGetWidth(containerBounds), CGRectGetHeight(containerBounds));
            break;
        case RNNativeStackSceneTransitionSlideFormBottom:
        case RNNativeStackSceneTransitionDefault:
            frame = CGRectMake(CGRectGetMinX(containerBounds), CGRectGetMaxY(containerBounds), CGRectGetWidth(containerBounds), CGRectGetHeight(containerBounds));
            break;
        default:
            frame = containerBounds;
            break;
    }
    return frame;
}

@end
