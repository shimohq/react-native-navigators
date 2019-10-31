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
    
    
    // update will show view frame
    RNNativeStackScene *currentTopScene = self.currentScenes.lastObject;
    RNNativeStackScene *nextTopScene = nextScenes.lastObject;
    if (action == RNNativeStackNavigatorActionShow && transition != RNNativeStackSceneTransitionNone) {
        nextTopScene.frame = [self getFrameWithContainerView:_controller.view transition:transition];
    }
    
    // add scene
    for (RNNativeStackScene *scene in nextScenes) {
        [self addScene:scene];
    }
    
    // transition
    if (transition == RNNativeStackSceneTransitionNone || action == RNNativeStackNavigatorActionNone) {
        [self removeScenesWithRemovedScenes:removedScenes];
        endTransition();
    } else if (action == RNNativeStackNavigatorActionShow) {
        [UIView animateWithDuration:0.35 animations:^{
            nextTopScene.frame = self.controller.view.bounds;
        } completion:^(BOOL finished) {
            [nextTopScene.controller didMoveToParentViewController:self.controller];
            [self removeScenesWithRemovedScenes:removedScenes];
            endTransition();
        }];
    } else if (action == RNNativeStackNavigatorActionHide) {
        [self addScene:currentTopScene];
        [currentTopScene.controller willMoveToParentViewController:nil];
        [UIView animateWithDuration:0.35 animations:^{
            currentTopScene.frame = [self getFrameWithContainerView:self.controller.view transition:transition];
        } completion:^(BOOL finished) {
            [self removeScenesWithRemovedScenes:removedScenes];
            endTransition();
        }];
    }
}

#pragma mark - Layout

- (void)removeScenesWithRemovedScenes:(NSArray<RNNativeStackScene *> *)removedScenes {
    for (RNNativeStackScene *scene in removedScenes) {
        [self removeScene:scene];
    }
}

- (void)addScene:(RNNativeStackScene *)scene {
    UIView *superView = [scene superview];
    if (superView && superView != _controller.view) {
        [scene removeFromSuperview];
        superView = nil;
    }
    
    UIViewController *parentViewController = [scene.controller parentViewController];
    if (parentViewController && parentViewController != _controller) {
        [scene.controller removeFromParentViewController];
        parentViewController = nil;
    }
    
    if (!parentViewController) {
        [_controller addChildViewController:scene.controller];
    }
    
    if (superView) {
        [_controller.view bringSubviewToFront:scene];
    } else {
        CGRect frame = scene.frame;
        CGRect bounds = _controller.view.bounds;
        scene.frame = CGRectMake(frame.origin.x, frame.origin.y, bounds.size.width, bounds.size.height);
        scene.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_controller.view addSubview:scene];
    }
}

- (void)removeScene:(RNNativeStackScene *)scene {
    [scene removeFromSuperview];
    [scene.controller removeFromParentViewController];
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
