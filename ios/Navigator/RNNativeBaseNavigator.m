//
//  RNNativeBaseNavigator.m
//  owl
//
//  Created by Bell Zhong on 2019/10/16.
//  Copyright © 2019 shimo.im. All rights reserved.
//

#import "RNNativeBaseNavigator.h"
#import "RNNativeStackHeader.h"

#import <React/RCTBridge.h>
#import <React/RCTUIManager.h>
#import <React/RCTUIManagerUtils.h>

@interface RNNativeBaseNavigator () <UINavigationControllerDelegate, RNNativeStackSceneDelegate>

@property (nonatomic, weak) RCTBridge *bridge;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) NSMutableArray<RNNativeStackScene *> *currentScenes;
@property (nonatomic, strong) NSMutableArray<RNNativeStackScene *> *nextScenes;

@end

@implementation RNNativeBaseNavigator
{
    BOOL _needUpdate;
}

- (instancetype)initWithBridge:(RCTBridge *)bridge viewController:(UIViewController *)viewController {
    if (self = [super init]) {
        _bridge = bridge;
        _viewController = viewController;
        _currentScenes = [NSMutableArray new];
        _nextScenes = [NSMutableArray new];
        [self addSubview:viewController.view];
    }
    return self;
}

- (void)updateSceneWithTransition:(RNNativeStackSceneTransition)transition
                           action:(RNNativeStackNavigatorAction)action
                      nextScrenes:(NSArray<RNNativeStackScene *> *)nextScrenes
                    removedScenes:(NSMutableArray<RNNativeStackScene *> *)removedScenes
                   insertedScenes:(NSMutableArray<RNNativeStackScene *> *)insertedScenes {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"For `RNNativeBaseNavigator` subclass, you must override %@ method", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self reactAddControllerToClosestParent:_viewController];
    _viewController.view.frame = self.bounds;
}

- (void)markChildUpdated
{
    // do nothing
}

- (void)didUpdateChildren
{
    // do nothing
}

- (void)insertReactSubview:(UIView *)subview atIndex:(NSInteger)atIndex
{
    [super insertReactSubview:subview atIndex:atIndex];
    if (![subview isKindOfClass:[RNNativeStackScene class]]) {
        return;
    }
    
    RNNativeStackScene *scene = (RNNativeStackScene *)subview;
    scene.delegate = self;
    [_nextScenes insertObject:scene atIndex:atIndex];
    [self markUpdated];
}

- (void)removeReactSubview:(UIView *)subview
{
    [super removeReactSubview:subview];
    if (![subview isKindOfClass:[RNNativeStackScene class]]) {
        return;
    }
    
    [_nextScenes removeObject:(RNNativeStackScene *)subview];
    [self markUpdated];
}

- (void)didUpdateReactSubviews
{
    // do nothing
}

#pragma mark - RCTInvalidating

- (void)invalidate {
    [_nextScenes removeAllObjects];
    [self updateSceneWithNextScenes:_nextScenes];
}

#pragma mark - RNNativeStackSceneDelegate

- (void)needUpdateForScene:(RNNativeStackScene *)scene {
    if ([_nextScenes containsObject:scene]) {
        [self markUpdated];
    }
}

#pragma mark - Update Container

- (void)markUpdated
{
    // We want 'updateContainer' to be executed on main thread after all enqueued operations in
    // uimanager are complete. In order to achieve that we enqueue call on UIManagerQueue from which
    // we enqueue call on the main queue. This seems to be working ok in all the cases I've tried but
    // there is a chance it is not the correct way to do that.
    if (!_needUpdate) {
        _needUpdate = YES;
        RCTExecuteOnUIManagerQueue(^{
            RCTExecuteOnMainQueue(^{
                _needUpdate = NO;
                NSMutableArray<RNNativeStackScene *> *nextScenes = [NSMutableArray new];
                for (RNNativeStackScene *scene in _nextScenes) {
                    if (!scene.closing) {
                        [nextScenes addObject:scene];
                    }
                }
                [self updateSceneWithNextScenes:nextScenes];
            });
        });
    }
}

- (void)updateSceneWithNextScenes:(NSArray<RNNativeStackScene *> *)nextScenes {
    NSMutableArray<RNNativeStackScene *> *removedScenes = [NSMutableArray new];
    NSMutableArray<RNNativeStackScene *> *insertedScenes = [NSMutableArray new];
    for (RNNativeStackScene *scene in _currentScenes) {
        if (![nextScenes containsObject:scene]) {
            [removedScenes addObject:scene];
        }
    }
    for (RNNativeStackScene *scene in nextScenes) {
        if (![_currentScenes containsObject:scene]) {
            [insertedScenes addObject:scene];
        }
    }
    if (removedScenes.count == 0 && insertedScenes.count == 0) {
        // 无更新
        return;
    }
    RNNativeStackScene *currentTopScene = [_currentScenes lastObject];
    RNNativeStackScene *nextTopScene = [nextScenes lastObject];
    
    RNNativeStackNavigatorAction action = RNNativeStackNavigatorActionNone;
    RNNativeStackSceneTransition transition = RNNativeStackSceneTransitionNone;
    // 当前列表为空时，无动画
    // 即将显示的顶层 screne 在当前列表中，且当前显示的顶层 screne 在即将显示的列表中，无动画
    // 当前和即将显示的顶层 screne 为同一个，无动画
    if (currentTopScene && currentTopScene != nextTopScene) {
        // 当前和即将显示的顶层 screne 不是同一个，有动画
        if (nextTopScene && ![_currentScenes containsObject:nextTopScene]) {
            // 即将显示的顶层 screne 不在当前列表中，取即将显示的顶层 screne 的显示动画
            action = RNNativeStackNavigatorActionShow;
            transition = nextTopScene.transition;
        } else if (![nextScenes containsObject:currentTopScene]) {
            // 即将显示的顶层 screne 在当前列表中，当前显示的顶层 screne 不在即将显示的列表中，取当前显示的顶层 screne 的隐藏动画
            action = RNNativeStackNavigatorActionHide;
            transition = currentTopScene.transition;
        }
    }
    [self updateSceneWithTransition:transition
                             action:action
                        nextScrenes:nextScenes
                      removedScenes:removedScenes
                     insertedScenes:insertedScenes];
    [_currentScenes setArray:nextScenes];
}

@end
