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
@property (nonatomic, strong) NSMutableArray<UIViewController *> *viewControllers;
@property (nonatomic, assign) BOOL updating;

@end

@implementation RNNativeCardNavigator

- (instancetype)initWithBridge:(RCTBridge *)bridge {
    _viewControllers = [NSMutableArray array];
    _controller = [UIViewController new];
    _updating = NO;
    return [super initWithBridge:bridge viewController:_controller];
}

#pragma mark - RNNativeBaseNavigator

- (BOOL)isDismissedForViewController:(UIViewController *)viewController {
    return viewController && ![_viewControllers containsObject:viewController];
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
    beginTransition(YES);
    
    // viewControllers
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (RNNativeStackScene *scene in nextScenes) {
        [viewControllers addObject:scene.controller];
    }
    [_viewControllers setArray:viewControllers];

    // update will show view frame
    RNNativeStackScene *currentTopScene = self.currentScenes.lastObject;
    RNNativeStackScene *nextTopScene = nextScenes.lastObject;
    if (action == RNNativeStackNavigatorActionShow && transition != RNNativeStackSceneTransitionNone) {
        nextTopScene.frame = [self getFrameWithContainerView:_controller.view transition:transition];
    }
    
    // add scene
    for (NSInteger index = 0, size = nextScenes.count; index < size; index++) {
        RNNativeStackScene *scene = nextScenes[index];
        if (index + 1 < size) { // 顶层 scene 必须显示
            RNNativeStackScene *nextScene = nextScenes[index + 1];
            if (!nextScene.transparent) { // 非顶层 scene，上层 scene 透明才显示
                continue;
            }
        }
        [self addScene:scene];
    }
    // transition
    if (transition == RNNativeStackSceneTransitionNone || action == RNNativeStackNavigatorActionNone) {
        nextTopScene.frame = self.controller.view.bounds;
        [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes];
        endTransition(YES);
    } else if (action == RNNativeStackNavigatorActionShow) {
        [UIView animateWithDuration:0.35 animations:^{
            nextTopScene.frame = self.controller.view.bounds;
        } completion:^(BOOL finished) {
            if (!finished) {
                nextTopScene.frame = self.controller.view.bounds;
            }
            [nextTopScene.controller didMoveToParentViewController:self.controller];
            [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes];
            endTransition(YES);
        }];
    } else if (action == RNNativeStackNavigatorActionHide) {
        [currentTopScene.superview bringSubviewToFront:currentTopScene];
        [currentTopScene.controller willMoveToParentViewController:nil];
        [UIView animateWithDuration:0.35 animations:^{
            currentTopScene.frame = [self getFrameWithContainerView:self.controller.view transition:transition];
        } completion:^(BOOL finished) {
            if (!finished) {
                nextTopScene.frame = self.controller.view.bounds;
            }
            [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes];
            endTransition(YES);
        }];
    }
}

#pragma mark - Layout

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

- (void)removeScenes:(NSArray<RNNativeStackScene *> *)scenes {
    for (RNNativeStackScene *scene in scenes) {
        [self removeScene:scene];
    }
}

- (void)removeScenesWithRemovedScenes:(NSArray<RNNativeStackScene *> *)removedScenes nextScenes:(NSArray<RNNativeStackScene *> *)nextScenes {
    for (RNNativeStackScene *scene in removedScenes) {
        [self removeScene:scene];
    }
    for (NSInteger index = 0, size = nextScenes.count - 1; index < size; index++) {
        RNNativeStackScene *scene = nextScenes[index];
        RNNativeStackScene *nextScene = nextScenes[index + 1];
        if (!nextScene.transparent) { // 非顶层 scene，且上层 scene 不透明
            [self removeScene:scene];
        }
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
