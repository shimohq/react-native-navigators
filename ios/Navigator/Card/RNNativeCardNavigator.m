//
//  RNNativeCardNavigator.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2019/10/25.
//

#import "RNNativeCardNavigator.h"
#import "RNNativeCardNavigatorController.h"
#import "RNNativeScene.h"
#import <React/RCTUIManager.h>

@interface RNNativeCardNavigator() <RNNativeCardNavigatorControllerDelegate>

@property (nonatomic, strong) RNNativeCardNavigatorController *controller;
@property (nonatomic, strong) NSMutableArray<UIViewController *> *viewControllers;
@property (nonatomic, assign) BOOL updating;

@end

@implementation RNNativeCardNavigator

- (instancetype)initWithBridge:(RCTBridge *)bridge {
    _viewControllers = [NSMutableArray array];
    _controller = [RNNativeCardNavigatorController new];
    _controller.delegte = self;
    _updating = NO;
    return [super initWithBridge:bridge viewController:_controller];
}

#pragma mark - RNNativeCardNavigatorControllerDelegate

- (void)didRemoveController:(nonnull UIViewController *)viewController {
    [_viewControllers removeObject:viewController];
}

#pragma mark - RNNativeBaseNavigator

- (BOOL)isDismissedForViewController:(UIViewController *)viewController {
    return viewController && ![_viewControllers containsObject:viewController];
}

/**
 addChildViewController removeFromParentViewController
 */
- (void)updateSceneWithTransition:(RNNativeSceneTransition)transition
                           action:(RNNativeStackNavigatorAction)action
                       nextScenes:(NSArray<RNNativeScene *> *)nextScenes
                    removedScenes:(NSArray<RNNativeScene *> *)removedScenes
                   insertedScenes:(NSArray<RNNativeScene *> *)insertedScenes
                  beginTransition:(RNNativeNavigatorTransitionBlock)beginTransition
                    endTransition:(RNNativeNavigatorTransitionBlock)endTransition {
    beginTransition(YES);
    
    // viewControllers
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (RNNativeScene *scene in nextScenes) {
        [viewControllers addObject:scene.controller];
    }
    [_viewControllers setArray:viewControllers];

    // update will show view frame
    RNNativeScene *currentTopScene = self.currentScenes.lastObject;
    RNNativeScene *nextTopScene = nextScenes.lastObject;
    if (action == RNNativeStackNavigatorActionShow && transition != RNNativeSceneTransitionNone) {
        nextTopScene.frame = [self getFrameWithContainerView:_controller.view transition:transition];
    }
    
    // add scene
    for (NSInteger index = 0, size = nextScenes.count; index < size; index++) {
        RNNativeScene *scene = nextScenes[index];
        if (index + 2 < size) { // 顶部两层 scene 必须显示，否则手势返回不好处理
            RNNativeScene *nextScene = nextScenes[index + 1];
            if (!nextScene.transparent) { // 非部两层 scene，上层 scene 透明时才显示
                continue;
            }
        }
        [self addScene:scene];
    }
    // transition
    if (transition == RNNativeSceneTransitionNone || action == RNNativeStackNavigatorActionNone) {
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

- (void)addScene:(RNNativeScene *)scene {
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

- (void)removeScene:(RNNativeScene *)scene {
    [scene removeFromSuperview];
    [scene.controller removeFromParentViewController];
}

- (void)removeScenes:(NSArray<RNNativeScene *> *)scenes {
    for (RNNativeScene *scene in scenes) {
        [self removeScene:scene];
    }
}

- (void)removeScenesWithRemovedScenes:(NSArray<RNNativeScene *> *)removedScenes nextScenes:(NSArray<RNNativeScene *> *)nextScenes {
    for (RNNativeScene *scene in removedScenes) {
        [self removeScene:scene];
    }
    // 顶部两层 scene 必须显示，否则手势返回不好处理
    for (NSInteger index = 0, size = nextScenes.count; index < size - 2; index++) {
        RNNativeScene *scene = nextScenes[index];
        RNNativeScene *nextScene = nextScenes[index + 1];
        if (!nextScene.transparent) { // 非顶部两层 scene，且上层 scene 不透明
            [self removeScene:scene];
        }
    }
}

- (CGRect)getFrameWithContainerView:(UIView *)containerView transition:(RNNativeSceneTransition)transition {
    CGRect containerBounds = containerView.bounds;
    CGRect frame;
    switch (transition) {
        case RNNativeSceneTransitionSlideFormRight:
            frame = CGRectMake(CGRectGetMaxX(containerBounds), CGRectGetMinY(containerBounds), CGRectGetWidth(containerBounds), CGRectGetHeight(containerBounds));
            break;
        case RNNativeSceneTransitionSlideFormLeft:
            frame = CGRectMake(-CGRectGetMaxX(containerBounds), CGRectGetMinY(containerBounds), CGRectGetWidth(containerBounds), CGRectGetHeight(containerBounds));
            break;
        case RNNativeSceneTransitionSlideFormTop:
            frame = CGRectMake(CGRectGetMinX(containerBounds), -CGRectGetMaxY(containerBounds), CGRectGetWidth(containerBounds), CGRectGetHeight(containerBounds));
            break;
        case RNNativeSceneTransitionSlideFormBottom:
        case RNNativeSceneTransitionDefault:
            frame = CGRectMake(CGRectGetMinX(containerBounds), CGRectGetMaxY(containerBounds), CGRectGetWidth(containerBounds), CGRectGetHeight(containerBounds));
            break;
        default:
            frame = containerBounds;
            break;
    }
    return frame;
}

@end
