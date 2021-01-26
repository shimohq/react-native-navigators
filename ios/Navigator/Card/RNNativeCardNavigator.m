//
//  RNNativeCardNavigator.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2019/10/25.
//

#import "RNNativeCardNavigator.h"
#import "RNNativeCardNavigatorController.h"
#import "RNNativeScene.h"
#import "RNNativeNavigatorUtils.h"

#import <React/RCTUIManager.h>
#import <React/RCTUIManagerUtils.h>
#import <React/RCTShadowView.h>
#import <React/RCTRootShadowView.h>
#import <React/RCTLayoutAnimationGroup.h>
#import <React/RCTLayoutAnimation.h>


#import "RNNativeBaseNavigator+Layout.h"
#import "UIView+RNNativeNavigator.h"

@interface RNNativeCardNavigator() <RNNativeCardNavigatorControllerDelegate, RNNativeCardNavigatorControllerDataSource>

@property (nonatomic, strong) NSMutableArray<UIViewController *> *viewControllers;
@property (nonatomic, assign) BOOL updating;

@end

@implementation RNNativeCardNavigator

- (instancetype)initWithBridge:(RCTBridge *)bridge {
    RNNativeCardNavigatorController *viewController = [RNNativeCardNavigatorController new];
    viewController.delegate = self;
    viewController.dataSource = self;
    self = [super initWithBridge:bridge viewController:viewController];
    if (self) {
        _viewControllers = [NSMutableArray array];
        _updating = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.viewController.view.frame = self.bounds;
}

#pragma mark - RNNativeCardNavigatorControllerDelegate

- (void)didRemoveController:(nonnull UIViewController *)viewController {
    [_viewControllers removeObject:viewController];
}

#pragma mark - RNNativeCardNavigatorControllerDataSource

- (NSArray<RNNativeScene *> *)getCurrentScenes {
    return self.currentScenes;
}

#pragma mark - RNNativeBaseNavigator

- (void)didFullScreenChangedWithScene:(RNNativeScene *)scene {
    // determine whether scene is in the navigator
    NSInteger index = [self.currentScenes indexOfObject:scene];
    if (index == NSNotFound) {
        return;
    }
    
    UIViewController *targetViewController;
    if (scene.splitFullScreen) {
        // toggle to enable full screen
        UIViewController *splitNavigatorController = [scene rnn_nearestSplitNavigatorController];
        targetViewController = splitNavigatorController ?: self.viewController;
        
        UIViewController *parentController = scene.controller.parentViewController;
        UIView *parentView = scene.superview;
        
        if (parentController && parentController != targetViewController) {
            [scene.controller removeFromParentViewController];
            parentController = nil;
        }
        if (parentView && parentView != targetViewController.view) {
            scene.frame = [scene convertRect:scene.frame toView:targetViewController.view];
            [scene removeFromSuperview];
            parentView = nil;
        }
        
        if (!parentController) {
            [targetViewController addChildViewController:scene.controller];
        }
        if (!parentView) {
            [targetViewController.view addSubview:scene];
        }
        
        CGRect frame = targetViewController.view.bounds;
        if (CGRectEqualToRect(scene.frame, frame)) {
            return;
        }
        
        RCTExecuteOnUIManagerQueue(^{
            RCTShadowView *shadowView = [self.bridge.uiManager shadowViewForReactTag:scene.reactTag];
            if (shadowView) {
                RCTLayoutAnimation *layoutAnimation = [[RCTLayoutAnimation alloc] initWithDuration:RNNativeNavigateDuration
                                                                                             delay:0.0
                                                                                          property:@"fullScreen"
                                                                                     springDamping:0.0
                                                                                   initialVelocity:0.0
                                                                                     animationType:RCTAnimationTypeEaseInEaseOut];
                RCTLayoutAnimationGroup *layoutAnimationGroup = [[RCTLayoutAnimationGroup alloc] initWithCreatingLayoutAnimation:nil updatingLayoutAnimation:layoutAnimation deletingLayoutAnimation:nil callback:^(NSArray *response) {}];
                RCTExecuteOnMainQueue(^{
                    [self.bridge.uiManager setNextLayoutAnimationGroup:layoutAnimationGroup];
                });
                
                [shadowView setLeft:YGValueZero];
                [shadowView setWidth:(YGValue){CGRectGetWidth(frame), YGUnitPoint}];
                [shadowView setRight:YGValueUndefined];
                
                [shadowView setTop:YGValueZero];
                [shadowView setHeight:(YGValue){CGRectGetHeight(frame), YGUnitPoint}];
                [shadowView setBottom:YGValueUndefined];
                
                [self.bridge.uiManager setNeedsLayout];
            }
        });
    } else {
        // toggle to disable full screen
        targetViewController = self.viewController;
        
        UIViewController *parentController = scene.controller.parentViewController;
        UIView *parentView = scene.superview;
        
        if (parentView && parentView != targetViewController.view) {
            scene.backgroundColor = [UIColor redColor];
            CGRect tempFrame = [targetViewController.view convertRect:targetViewController.view.bounds toView:parentView];
            RCTExecuteOnUIManagerQueue(^{
                RCTShadowView *shadowView = [self.bridge.uiManager shadowViewForReactTag:scene.reactTag];
                if (shadowView) {
                    RCTLayoutAnimation *layoutAnimation = [[RCTLayoutAnimation alloc] initWithDuration:RNNativeNavigateDuration
                                                                                                 delay:0.0
                                                                                              property:@"fullScreen"
                                                                                         springDamping:0.0
                                                                                       initialVelocity:0.0
                                                                                         animationType:RCTAnimationTypeEaseInEaseOut];
                    RCTLayoutAnimationGroup *layoutAnimationGroup = [[RCTLayoutAnimationGroup alloc] initWithCreatingLayoutAnimation:nil updatingLayoutAnimation:layoutAnimation deletingLayoutAnimation:nil callback:^(NSArray *response) {
                        RCTExecuteOnMainQueue(^{
                            if (parentController && parentController != targetViewController) {
                                [scene.controller removeFromParentViewController];
                            }

                            [scene removeFromSuperview];

                            if (!parentController) {
                                [targetViewController addChildViewController:scene.controller];
                            }
                            scene.frame = targetViewController.view.bounds;
                            
                            [targetViewController.view addSubview:scene];
                            
                            // end yoga layout
                            RCTExecuteOnUIManagerQueue(^{
                                [shadowView setLeft:YGValueZero];
                                [shadowView setWidth:YGValueAuto];
                                [shadowView setRight:YGValueZero];
                                
                                [shadowView setTop:YGValueZero];
                                [shadowView setHeight:YGValueAuto];
                                [shadowView setBottom:YGValueZero];
                                
                                [self.bridge.uiManager setNeedsLayout];
                            });
                        });
                    }];
                    RCTExecuteOnMainQueue(^{
                        [self.bridge.uiManager setNextLayoutAnimationGroup:layoutAnimationGroup];
                    });
                    
                    // temp yoga layout
                    [shadowView setLeft:(YGValue){CGRectGetMinX(tempFrame), YGUnitPoint}];
                    [shadowView setWidth:(YGValue){CGRectGetWidth(tempFrame), YGUnitPoint}];
                    [shadowView setRight:YGValueUndefined];
                    
                    [shadowView setTop:(YGValue){CGRectGetMinY(tempFrame), YGUnitPoint}];
                    [shadowView setHeight:(YGValue){CGRectGetHeight(tempFrame), YGUnitPoint}];
                    [shadowView setBottom:YGValueUndefined];
                    
                    [self.bridge.uiManager setNeedsLayout];
                }
            });
        } else {
            if (!parentController) {
                [targetViewController addChildViewController:scene.controller];
            }
            if (!parentView) {
                [targetViewController.view addSubview:scene];
            }
            CGRect frame = targetViewController.view.bounds;
            if (CGRectEqualToRect(scene.frame, frame)) {
                RCTExecuteOnUIManagerQueue(^{
                    RCTShadowView *shadowView = [self.bridge.uiManager shadowViewForReactTag:scene.reactTag];
                    if (shadowView) {
                        [shadowView setLeft:YGValueZero];
                        [shadowView setWidth:YGValueAuto];
                        [shadowView setRight:YGValueZero];
                        
                        [shadowView setTop:YGValueZero];
                        [shadowView setHeight:YGValueAuto];
                        [shadowView setBottom:YGValueZero];
                        
                        [self.bridge.uiManager setNeedsLayout];
                    }
                });
            }
            scene.frame = targetViewController.view.bounds;
        }
    }
}

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
    
    beginTransition(YES, nil);
    
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
        nextTopScene.frame = [RNNativeNavigatorUtils getBeginFrameWithFrame:nextTopScene.frame
                                                                 transition:transition];
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
    CGRect nextTopSceneEndFrame = [RNNativeNavigatorUtils getEndFrameWithFrame:nextTopScene.frame];
    if (transition == RNNativeSceneTransitionNone || action == RNNativeStackNavigatorActionNone) {
        nextTopScene.frame = nextTopSceneEndFrame;
        [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes];
        endTransition(YES, nil);
    } else if (action == RNNativeStackNavigatorActionShow) {
        [UIView animateWithDuration:RNNativeNavigateDuration animations:^{
            nextTopScene.frame = nextTopSceneEndFrame;
        } completion:^(BOOL finished) {
            if (!finished) {
                nextTopScene.frame = nextTopSceneEndFrame;
            }
            [nextTopScene setStatus:RNNativeSceneStatusDidFocus];
            [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes];
            endTransition(YES, nil);
        }];
    } else if (action == RNNativeStackNavigatorActionHide) {
        [currentTopScene.superview bringSubviewToFront:currentTopScene];
        [currentTopScene setStatus:RNNativeSceneStatusWillBlur];
        [UIView animateWithDuration:RNNativeNavigateDuration animations:^{
            currentTopScene.frame = [RNNativeNavigatorUtils getBeginFrameWithFrame:currentTopScene.frame
                                                                        transition:transition];
        } completion:^(BOOL finished) {
            [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes];
            endTransition(YES, nil);
        }];
    }
}

@end
