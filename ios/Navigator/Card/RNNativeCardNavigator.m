//
//  RNNativeCardNavigator.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2019/10/25.
//

#import "RNNativeCardNavigator.h"
#import "RNNativeCardNavigatorController.h"
#import "RNNativeScene.h"
#import "RNNativeCardNavigatorShadowView.h"
#import "RNNativeSceneShadowView.h"

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
@property (nonatomic, assign) BOOL enableClipsToBounds;

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
        _enableClipsToBounds = YES;
        [self updateForEnableClipsToBounds:_enableClipsToBounds];
    }
    return self;
}

- (void)updateEnableClipsToBounds {
    [self updateEnableClipsToBounds:self.currentScenes];
}

#pragma mark - View

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.viewController.view.frame = self.bounds;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *result = [super hitTest:point withEvent:event];
    if (!result) {
        for (UIView *view in self.reactSubviews.reverseObjectEnumerator) {
            if ([view isKindOfClass:[RNNativeScene class]]) {
                RNNativeScene *scene = (RNNativeScene *)view;
                if (scene.splitFullScreen) {
                    if (CGRectContainsPoint(scene.frame, point)) {
                        result = scene;
                    }
                    break;
                }
            }
        }
    }
    return result;
}

#pragma mark - Setter

- (void)setEnableClipsToBounds:(BOOL)enableClipsToBounds {
    if (enableClipsToBounds == _enableClipsToBounds) {
        return;
    }
    _enableClipsToBounds = enableClipsToBounds;
    [self updateForEnableClipsToBounds:enableClipsToBounds];
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
    
    // update enableClipsToBounds
    if (scene.splitFullScreen) {
        [self setEnableClipsToBounds:NO];
    }
    
    RCTExecuteOnUIManagerQueue(^{
        RCTShadowView *parentShadowView = [self.bridge.uiManager shadowViewForReactTag:self.reactTag];
        if (![parentShadowView isKindOfClass:[RNNativeCardNavigatorShadowView class]]) {
            return;
        }
        RCTShadowView *sceneShadowView = [self.bridge.uiManager shadowViewForReactTag:scene.reactTag];
        if (![sceneShadowView isKindOfClass:[RNNativeSceneShadowView class]]) {
            return;
        }
        
        RCTLayoutAnimation *layoutAnimation = [[RCTLayoutAnimation alloc] initWithDuration:RNNativeNavigateDuration
                                                                                     delay:0.0
                                                                                  property:@"fullScreen"
                                                                             springDamping:0.0
                                                                           initialVelocity:0.0
                                                                             animationType:RCTAnimationTypeEaseInEaseOut];
        RCTLayoutAnimationGroup *layoutAnimationGroup = [[RCTLayoutAnimationGroup alloc] initWithCreatingLayoutAnimation:nil updatingLayoutAnimation:layoutAnimation deletingLayoutAnimation:nil callback:^(NSArray *response) {
            if (!scene.splitFullScreen) {
                [self updateEnableClipsToBounds];
            }
        }];
        RCTExecuteOnMainQueue(^{
            [self.bridge.uiManager setNextLayoutAnimationGroup:layoutAnimationGroup];
        });
        
        [(RNNativeCardNavigatorShadowView *)parentShadowView updateShadowView:(RNNativeSceneShadowView *)sceneShadowView];
        [self.bridge.uiManager setNeedsLayout];
    });
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
    
    [self updateEnableClipsToBounds:nextScenes];
    
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
        nextTopScene.frame = [self getBeginFrameWithScene:nextTopScene
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
    CGRect nextTopSceneEndFrame = [self getEndFrameWithScene:nextTopScene];
    
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
            currentTopScene.frame = [self getBeginFrameWithScene:currentTopScene
                                                      transition:transition];
        } completion:^(BOOL finished) {
            [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes];
            endTransition(YES, nil);
        }];
    }
}

#pragma mark - Private

- (void)updateEnableClipsToBounds:(NSArray<RNNativeScene *> *)scenes {
    BOOL enableClipsToBounds = YES;
    for (RNNativeScene *nativeScene in scenes) {
        if (nativeScene.splitFullScreen) {
            enableClipsToBounds = NO;
            break;
        }
    }
    [self setEnableClipsToBounds:enableClipsToBounds];
}

/// RCTShadowView 的 overflow 属性无效，所以用 UIView 的 clipsToBounds
- (void)updateForEnableClipsToBounds:(BOOL)enableClipsToBounds {
    if (enableClipsToBounds) {
        self.clipsToBounds = YES;
        self.layer.masksToBounds = YES;
    } else {
        self.clipsToBounds = NO;
        self.layer.masksToBounds = NO;
    }
}

- (CGRect)getBeginFrameWithScene:(RNNativeScene *)scene
                      transition:(RNNativeSceneTransition)transition {
    CGRect frame = [self getEndFrameWithScene:scene];
    
    CGFloat width = CGRectGetWidth(frame);
    CGFloat height = CGRectGetHeight(frame);
    CGFloat endX = CGRectGetMinX(frame);
    CGFloat endY = CGRectGetMinY(frame);
   
    switch (transition) {
        case RNNativeSceneTransitionSlideFormRight:
            frame.origin.x = endX + width;
            break;
        case RNNativeSceneTransitionSlideFormLeft:
            frame.origin.x = endX - width;
            break;
        case RNNativeSceneTransitionSlideFormTop:
            frame.origin.y = endY - height;
            break;
        case RNNativeSceneTransitionSlideFormBottom:
        case RNNativeSceneTransitionDefault:
            frame.origin.y = endY + height;
        case RNNativeSceneTransitionNone:
        default:
            break;
    }
    return frame;
}

- (CGRect)getEndFrameWithScene:(RNNativeScene *)scene {
    CGRect frame = scene.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    if (scene.splitFullScreen) {
        UIViewController *splitNavigatorController = [self rnn_nearestSplitNavigatorController];
        if (splitNavigatorController) {
            CGRect relativeFrame = [splitNavigatorController.view convertRect:splitNavigatorController.view.bounds toView:self];
            frame.origin.x = CGRectGetMinX(relativeFrame);
            frame.origin.y = CGRectGetMinY(relativeFrame);
        }
    }
    return frame;
}

@end
