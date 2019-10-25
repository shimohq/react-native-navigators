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

/**
 addChildViewController removeFromParentViewController
 */
- (void)updateSceneWithTransition:(RNNativeStackSceneTransition)transition
                           action:(RNNativeStackNavigatorAction)action
                       nextScenes:(NSArray<RNNativeStackScene *> *)nextScenes
                    removedScenes:(NSMutableArray<RNNativeStackScene *> *)removedScenes
                   insertedScenes:(NSMutableArray<RNNativeStackScene *> *)insertedScenes {
    // insertedScenes ViewController
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
    
    // nextScenes view
    for (NSInteger index = 0, size = nextScenes.count; index < size; index++) {
        RNNativeStackScene *scene = nextScenes[index];
        UIView *currentView = scene.controller.view;
        
        BOOL willShow = NO;
        if (index + 1 == size) {
            willShow = YES;
        } else {
            RNNativeStackScene *nextScene = nextScenes[index + 1];
            willShow = nextScene.transparent;
        }
        
        if (willShow) {
            [self addSubview:scene.controller.view toView:_controller.view];
        } else {
            [currentView removeFromSuperview];
        }
    }
    
    // transition
    if (transition == RNNativeStackSceneTransitionNone || action == RNNativeStackNavigatorActionNone) {
        [self removeScenes:removedScenes];
    } else if (action == RNNativeStackNavigatorActionShow) {
        [UIView animateWithDuration:0.35 animations:^{
            nextTopScene.frame = self.controller.view.bounds;
        } completion:^(BOOL finished) {
            [self removeScenes:removedScenes];
        }];
    } else if (action == RNNativeStackNavigatorActionHide) {
        [self addSubview:currentTopScene toView:_controller.view];
        [UIView animateWithDuration:0.35 animations:^{
            currentTopScene.frame = [self getFrameWithContainerView:self.controller.view transition:transition];
        } completion:^(BOOL finished) {
            [self removeScenes:removedScenes];
        }];
    }
}

- (void)removeScenes:(NSMutableArray<RNNativeStackScene *> *)removedScenes {
    for (NSInteger index = 0, size = removedScenes.count; index < size; index++) {
        RNNativeStackScene *scene = removedScenes[index];
        [scene.controller.view removeFromSuperview];
        [scene.controller removeFromParentViewController];
    }
}

#pragma mark - Private

- (void)addSubview:(UIView *)subview toView:(UIView *)view {
    UIView *superView = [subview superview];
    if (superView) {
        if (superView == view) {
            [superView bringSubviewToFront:superView];
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
            frame = CGRectMake(CGRectGetMinX(containerBounds), CGRectGetMaxY(containerBounds), CGRectGetWidth(containerBounds), CGRectGetHeight(containerBounds));
            break;
        default:
            frame = containerBounds;
            break;
    }
    return frame;
}

@end
