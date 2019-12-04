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

@property (nonatomic, copy) NSArray<RNNativeStackScene *> *needUpdateScenes;
@property (nonatomic, assign) BOOL updatingScenes;

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
                       nextScenes:(NSArray<RNNativeStackScene *> *)nextScenes
                    removedScenes:(NSArray<RNNativeStackScene *> *)removedScenes
                   insertedScenes:(NSArray<RNNativeStackScene *> *)insertedScenes
                  beginTransition:(RNNativeNavigatorTransitionBlock)beginTransition
                    endTransition:(RNNativeNavigatorTransitionBlock)endTransition {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"For `RNNativeBaseNavigator` subclass, you must override %@ method", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (BOOL)isDismissedForViewController:(UIViewController *)viewController {
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

#pragma mark - Setting

- (void)setUpdatingScenes:(BOOL)updatingScenes {
    if (_updatingScenes == updatingScenes) {
        return;
    }
    _updatingScenes = updatingScenes;
    [self updateScenes];
}

- (void)setNeedUpdateScenes:(NSArray<RNNativeStackScene *> *)neededUpdateScenes {
    if (_needUpdateScenes == neededUpdateScenes) {
        return;
    }
    if (neededUpdateScenes) {
        _needUpdateScenes = [NSArray arrayWithArray:neededUpdateScenes];
    } else {
        _needUpdateScenes = neededUpdateScenes;
    }
    [self updateScenes];
}

#pragma mark - RCTInvalidating

- (void)invalidate {
    [self.nextScenes removeAllObjects];
    RCTExecuteOnMainQueue(^{
        [self setNeedUpdateScenes:self.nextScenes];
    });
}

#pragma mark - RNNativeStackSceneDelegate

- (void)needUpdateForScene:(RNNativeStackScene *)scene {
    if ([_nextScenes containsObject:scene]) {
        [self markUpdated];
    }
}

- (BOOL)isDismissedForScene:(RNNativeStackScene *)scene {
    return [self isDismissedForViewController:scene.controller];
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
                self->_needUpdate = NO;
                NSMutableArray<RNNativeStackScene *> *nextScenes = [NSMutableArray new];
                for (RNNativeStackScene *scene in self.nextScenes) {
                    if (!scene.closing) {
                        [nextScenes addObject:scene];
                    }
                }
                [self setNeedUpdateScenes:nextScenes];
            });
        });
    }
}

- (void)updateScenes {
    if (_updatingScenes || !_needUpdateScenes) {
        return;
    }
    _updatingScenes = YES;
    NSArray<RNNativeStackScene *> *nextScenes = [NSArray arrayWithArray:_needUpdateScenes];
    _needUpdateScenes = nil;
    
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
        [self setUpdatingScenes:NO];
        return;
    }
    RNNativeStackScene *currentTopScene = [_currentScenes lastObject];
    RNNativeStackScene *nextTopScene = [nextScenes lastObject];
    
    RNNativeStackNavigatorAction action = RNNativeStackNavigatorActionNone;
    RNNativeStackSceneTransition transition = RNNativeStackSceneTransitionNone;
    // 当前列表为空时，无动画
    // 即将显示的顶层 scene 在当前列表中，且当前显示的顶层 scene 在即将显示的列表中，无动画
    // 当前和即将显示的顶层 scene 为同一个，无动画
    if (currentTopScene && currentTopScene != nextTopScene) {
        // 当前和即将显示的顶层 scene 不是同一个，有动画
        if (nextTopScene && ![_currentScenes containsObject:nextTopScene]) {
            // 即将显示的顶层 scene 不在当前列表中，取即将显示的顶层 scene 的显示动画
            action = RNNativeStackNavigatorActionShow;
            transition = nextTopScene.transition;
        } else if (![nextScenes containsObject:currentTopScene]) {
            // 即将显示的顶层 scene 在当前列表中，当前显示的顶层 scene 不在即将显示的列表中，取当前显示的顶层 scene 的隐藏动画
            action = RNNativeStackNavigatorActionHide;
            if (![self isDismissedForScene:currentTopScene]) {
                transition = currentTopScene.transition;
            }
        }
    }
    
    if (currentTopScene != nextTopScene) {
        if (![removedScenes containsObject:currentTopScene]) {
            [currentTopScene resignFirstResponder];
        }
        if ([_currentScenes containsObject:nextTopScene]) {
            [nextTopScene becomeFirstResponder];
        }
    }
  
    [self updateSceneWithTransition:transition
                             action:action
                         nextScenes:nextScenes
                      removedScenes:removedScenes
                     insertedScenes:insertedScenes
                    beginTransition:^(BOOL updateStatus) {
        if (updateStatus) {
            [self willUpdateStatusWithNextScenes:nextScenes removedScenes:removedScenes action:action];
        }
    } endTransition:^(BOOL updateStatus) {
        if (updateStatus) {
            [self didUpdateStatusWithNextScenes:nextScenes removedScenes:removedScenes action:action];
        }
        [self setUpdatingScenes:NO];
    }];
    [_currentScenes setArray:nextScenes];
}

#pragma mark - Status

- (void)willUpdateStatusWithNextScenes:(NSArray<RNNativeStackScene *> *)nextScenes
                         removedScenes:(NSMutableArray<RNNativeStackScene *> *)removedScenes
                                action:(RNNativeStackNavigatorAction)action {
    if (action == RNNativeStackNavigatorActionHide) {
        [self willBlurWithNextScenes:nextScenes removedScenes:removedScenes];
        [self willFocusWithNextScenes:nextScenes];
    } else {
        [self willFocusWithNextScenes:nextScenes];
        [self willBlurWithNextScenes:nextScenes removedScenes:removedScenes];
    }
}

- (void)didUpdateStatusWithNextScenes:(NSArray<RNNativeStackScene *> *)nextScenes
                        removedScenes:(NSMutableArray<RNNativeStackScene *> *)removedScenes
                               action:(RNNativeStackNavigatorAction)action {
    if (action == RNNativeStackNavigatorActionHide) {
        [self didBlurredWithNextScenes:nextScenes removedScenes:removedScenes];
        [self didFocusedWithNextScenes:nextScenes];
    } else {
        [self didFocusedWithNextScenes:nextScenes];
        [self didBlurredWithNextScenes:nextScenes removedScenes:removedScenes];
    }
}

- (void)willBlurWithNextScenes:(NSArray<RNNativeStackScene *> *)nextScenes
                 removedScenes:(NSMutableArray<RNNativeStackScene *> *)removedScenes {
    // removedScenes
    for (NSInteger index = 0, size = removedScenes.count; index < size; index++) {
        RNNativeStackScene *scene = removedScenes[index];
        [scene setStatus:RNNativeStackSceneStatusWillBlur];
    }
    
    // nextScenes
    for (NSInteger index = 0, size = nextScenes.count; index + 1 < size; index++) {
        RNNativeStackScene *scene = nextScenes[index];
        [scene setStatus:RNNativeStackSceneStatusWillBlur];
    }
}

- (void)didBlurredWithNextScenes:(NSArray<RNNativeStackScene *> *)nextScenes
                   removedScenes:(NSMutableArray<RNNativeStackScene *> *)removedScenes {
    // removedScenes
    for (NSInteger index = 0, size = removedScenes.count; index < size; index++) {
        RNNativeStackScene *scene = removedScenes[index];
        [scene setStatus:RNNativeStackSceneStatusDidBlur];
    }
    
    // nextScenes
    for (NSInteger index = 0, size = nextScenes.count; index + 1 < size; index++) {
        RNNativeStackScene *scene = nextScenes[index];
        [scene setStatus:RNNativeStackSceneStatusDidBlur];
    }
}

- (void)willFocusWithNextScenes:(NSArray<RNNativeStackScene *> *)nextScenes {
    NSInteger size = nextScenes.count;
    if (size > 0) {
        RNNativeStackScene *scene = nextScenes[size - 1];
        [scene setStatus:RNNativeStackSceneStatusWillFocus];
    }
}

- (void)didFocusedWithNextScenes:(NSArray<RNNativeStackScene *> *)nextScenes {
    NSInteger size = nextScenes.count;
    if (size > 0) {
        RNNativeStackScene *scene = nextScenes[size - 1];
        [scene setStatus:RNNativeStackSceneStatusDidFocus];
    }
}

@end
