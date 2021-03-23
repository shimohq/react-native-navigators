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
#import "RNNativeTransitionUtils.h"

#import <React/RCTUIManager.h>
#import <React/RCTUIManagerUtils.h>
#import <React/RCTShadowView.h>
#import <React/RCTRootShadowView.h>
#import <React/RCTLayoutAnimationGroup.h>
#import <React/RCTLayoutAnimation.h>

#import "RNNativeBaseNavigator+Layout.h"
#import "UIView+RNNativeNavigator.h"


@interface RNNativeCardNavigator() <RNNativeCardNavigatorControllerDataSource>

@property (nonatomic, assign) BOOL updating;

@end

@implementation RNNativeCardNavigator

- (instancetype)initWithBridge:(RCTBridge *)bridge {
    RNNativeCardNavigatorController *viewController = [RNNativeCardNavigatorController new];
    viewController.dataSource = self;
    self = [super initWithBridge:bridge viewController:viewController];
    if (self) {
        _updating = NO;
    }
    return self;
}

#pragma mark - View

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.viewController.view.frame = self.bounds;
}

#pragma mark - RNNativeCardNavigatorControllerDataSource

- (NSArray<RNNativeScene *> *)getCurrentScenes {
    return self.currentScenes;
}

#pragma mark - RNNativeBaseNavigator

/**
 addChildViewController removeFromParentViewController
 */
- (void)updateSceneWithTransition:(RNNativeSceneTransition)transition
                           action:(RNNativeStackNavigatorAction)action
                    currentScenes:(NSArray<RNNativeScene *> *)currentScenes
                       nextScenes:(NSArray<RNNativeScene *> *)nextScenes
                    removedScenes:(NSArray<RNNativeScene *> *)removedScenes
                   insertedScenes:(NSArray<RNNativeScene *> *)insertedScenes
                  beginTransition:(RNNativeNavigatorTransitionBlock)beginTransition
                    endTransition:(RNNativeNavigatorTransitionBlock)endTransition {
    beginTransition(YES);
    
    // update dismissed
    for (RNNativeScene *scene in removedScenes) {
        scene.dismissed = YES;
    }

    // update will show view frame
    RNNativeScene *currentTopScene = currentScenes.lastObject;
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
        endTransition(YES);
    } else if (action == RNNativeStackNavigatorActionShow) {
        CGRect currentTopSceneOriginalFrame = currentTopScene.frame;
        CGRect currentTopSceneEndFrame = [RNNativeTransitionUtils getDownViewFrameWithView:currentTopScene transition:transition];
        
        [UIView animateWithDuration:RNNativeNavigateDuration animations:^{
            nextTopScene.frame = nextTopSceneEndFrame;
            currentTopScene.frame = currentTopSceneEndFrame;
        } completion:^(BOOL finished) {
            if (!finished) {
                nextTopScene.frame = nextTopSceneEndFrame;
            }
            currentTopScene.frame = currentTopSceneOriginalFrame;
            [nextTopScene setStatus:RNNativeSceneStatusDidFocus];
            [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes];
            endTransition(YES);
        }];
    } else if (action == RNNativeStackNavigatorActionHide) {
        [currentTopScene.superview bringSubviewToFront:currentTopScene];
        [currentTopScene setStatus:RNNativeSceneStatusWillBlur];
        
        NSInteger currentSecondSceneIndex = currentScenes.count - 2;
        RNNativeScene *currentSecondScene = currentSecondSceneIndex >= 0 ? currentScenes[currentSecondSceneIndex] : nil;
        CGRect currentSecondSceneOriginalFrame = currentSecondScene.frame;
        currentSecondScene.frame = [RNNativeTransitionUtils getDownViewFrameWithView:currentSecondScene transition:transition];
        
        [UIView animateWithDuration:RNNativeNavigateDuration animations:^{
            currentTopScene.frame = [self getBeginFrameWithScene:currentTopScene
                                                      transition:transition];
            currentSecondScene.frame = currentSecondSceneOriginalFrame;
        } completion:^(BOOL finished) {
            if (!finished) {
                currentSecondScene.frame = currentSecondSceneOriginalFrame;
            }
            [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes];
            endTransition(YES);
        }];
    }
}

#pragma mark - Private

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
    return frame;
}

@end
