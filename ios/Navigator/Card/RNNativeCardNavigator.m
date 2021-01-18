//
//  RNNativeCardNavigator.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2019/10/25.
//

#import "RNNativeCardNavigator.h"
#import "RNNativeCardNavigatorController.h"
#import "RNNativeScene.h"
#import "RNNativeNavigatorFrameData.h"
#import "RNNativeNavigatorUtils.h"

#import <React/RCTUIManager.h>
#import <React/RCTUIManagerUtils.h>
#import <React/RCTShadowView.h>
#import <React/RCTRootShadowView.h>

#import "RNNativeBaseNavigator+Layout.h"

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

#pragma mark - RNNativeCardNavigatorControllerDelegate

- (void)didRemoveController:(nonnull UIViewController *)viewController {
    [_viewControllers removeObject:viewController];
}

#pragma mark - RNNativeCardNavigatorControllerDataSource

- (NSArray<RNNativeScene *> *)getCurrentScenes {
    return self.currentScenes;
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
                                                               parentBounds:self.viewController.view.bounds
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
    if (transition == RNNativeSceneTransitionNone || action == RNNativeStackNavigatorActionNone) {
        nextTopScene.frame = self.viewController.view.bounds;
        [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes];
        endTransition(YES, nil);
    } else if (action == RNNativeStackNavigatorActionShow) {
        [UIView animateWithDuration:RNNativeNavigateDuration animations:^{
            nextTopScene.frame = [RNNativeNavigatorUtils getEndFrameFrame:nextTopScene.frame];
        } completion:^(BOOL finished) {
            if (!finished) {
                nextTopScene.frame = [RNNativeNavigatorUtils getEndFrameFrame:nextTopScene.frame];
            }
            [nextTopScene.controller didMoveToParentViewController:self.viewController];
            [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes];
            endTransition(YES, nil);
        }];
    } else if (action == RNNativeStackNavigatorActionHide) {
        [currentTopScene.superview bringSubviewToFront:currentTopScene];
        [currentTopScene.controller willMoveToParentViewController:nil];
        [UIView animateWithDuration:RNNativeNavigateDuration animations:^{
            currentTopScene.frame = [RNNativeNavigatorUtils getBeginFrameWithFrame:currentTopScene.frame
                                                                      parentBounds:self.viewController.view.bounds
                                                                        transition:transition];
        } completion:^(BOOL finished) {
            [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes];
            endTransition(YES, nil);
        }];
    }
}

@end
