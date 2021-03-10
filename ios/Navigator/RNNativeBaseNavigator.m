//
//  RNNativeBaseNavigator.m
//  owl
//
//  Created by Bell Zhong on 2019/10/16.
//  Copyright © 2019 shimo.im. All rights reserved.
//

#import "RNNativeBaseNavigator.h"

#import <React/RCTBridge.h>
#import <React/RCTUIManager.h>
#import <React/RCTUIManagerUtils.h>

@interface RNNativeBaseNavigator () <UINavigationControllerDelegate>

@property (nonatomic, weak) RCTBridge *bridge;
@property (nonatomic, strong) __kindof UIViewController *viewController;
@property (nonatomic, strong) NSMutableArray<RNNativeScene *> *currentScenes;
@property (nonatomic, strong) NSMutableArray<__kindof UIView *> *nextViews;

@property (nullable, nonatomic, copy) NSArray<RNNativeScene *> *needUpdateScenes;
@property (nonatomic, assign) BOOL updatingScenes;

@end

@implementation RNNativeBaseNavigator
{
    BOOL _needUpdate;
}

- (instancetype)initWithBridge:(RCTBridge *)bridge viewController:(__kindof UIViewController *)viewController {
    if (self = [super init]) {
        _bridge = bridge;
        _currentScenes = [NSMutableArray array];
        _nextViews = [NSMutableArray array];
        
        viewController.view.frame = self.bounds;
        viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _viewController = viewController;
        [self addSubview:viewController.view];
    }
    return self;
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
    [_nextViews insertObject:subview atIndex:atIndex];
    
    if (![subview isKindOfClass:[RNNativeScene class]]) {
        return;
    }
    
    RNNativeScene *scene = (RNNativeScene *)subview;
    scene.delegate = self;
    
    [self markUpdated];
}

- (void)removeReactSubview:(UIView *)subview
{
    [super removeReactSubview:subview];
    [_nextViews removeObject:subview];
    
    if (![subview isKindOfClass:[RNNativeScene class]]) {
        return;
    }
    
    RNNativeScene *scene = (RNNativeScene *)subview;
    scene.delegate = nil;
    
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

- (void)setNeedUpdateScenes:(nullable NSArray<RNNativeScene *> *)neededUpdateScenes {
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
    [self.nextViews removeAllObjects];
    RCTExecuteOnMainQueue(^{
        [self setNeedUpdateScenes:@[]];
    });
}

#pragma mark - RNNativeSceneDelegate

- (void)needUpdateForScene:(RNNativeScene *)scene {
    if ([_nextViews containsObject:scene]) {
        [self markUpdated];
    }
}

- (BOOL)isDismissedForScene:(RNNativeScene *)scene {
    return !scene.controller || scene.dismissed;
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
                
                NSMutableArray<RNNativeScene *> *nextScenes = [NSMutableArray new];
                for (UIView *view in self.nextViews) {
                    if ([view isKindOfClass:[RNNativeScene class]]) {
                        RNNativeScene *scene = (RNNativeScene *)view;
                        if (!scene.closing && ![nextScenes containsObject:scene]) {
                            [nextScenes addObject:scene];
                        }
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
    NSArray<RNNativeScene *> *nextScenes = [NSArray arrayWithArray:_needUpdateScenes];
    _needUpdateScenes = nil;
    
    [self updateSceneWithCurrentScenes:_currentScenes NextScenes:nextScenes comoplete:^{
        [self setUpdatingScenes:NO];
    }];
    
    [_currentScenes setArray:nextScenes];
}

- (void)updateSceneWithCurrentScenes:(NSArray<RNNativeScene *> *)currentScenes
                          NextScenes:(NSArray<RNNativeScene *> *)nextScenes
                           comoplete:(RNNativeNavigatorUpdateCompleteBlock)comoplete {
    NSMutableArray<RNNativeScene *> *removedScenes = [NSMutableArray new];
    NSMutableArray<RNNativeScene *> *insertedScenes = [NSMutableArray new];
    for (RNNativeScene *scene in currentScenes) {
        if (![nextScenes containsObject:scene]) {
            [removedScenes addObject:scene];
        }
    }
    for (RNNativeScene *scene in nextScenes) {
        if (![currentScenes containsObject:scene]) {
            [insertedScenes addObject:scene];
        }
    }
    
    if (removedScenes.count == 0 && insertedScenes.count == 0) {
        BOOL orderChanged = NO;
        // 检查顺序是否产生变化
        for (int i = 0; i < currentScenes.count; i++) {
            if (currentScenes[i] != nextScenes[i]) {
                orderChanged = YES;
                break;
            }
        }
        if (!orderChanged) {
            // 无更新
            comoplete();
            return;
        }
    }
    
    RNNativeScene *currentTopScene = [currentScenes lastObject];
    RNNativeScene *nextTopScene = [nextScenes lastObject];
    
    RNNativeStackNavigatorAction action = RNNativeStackNavigatorActionNone;
    RNNativeSceneTransition transition = RNNativeSceneTransitionNone;
    
    // 当前列表为空时，无动画
    // 即将显示的顶层 scene 在当前列表中，且当前显示的顶层 scene 在即将显示的列表中，无动画
    // 当前和即将显示的顶层 scene 为同一个，无动画
    if (currentTopScene && currentTopScene != nextTopScene) {
        // 当前和即将显示的顶层 scene 不是同一个，有动画
        if (nextTopScene && ![currentScenes containsObject:nextTopScene]) {
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
        if ([currentScenes containsObject:nextTopScene]) {
            [nextTopScene becomeFirstResponder];
        }
    }
    
    [self updateSceneWithTransition:transition
                             action:action
                      currentScenes:currentScenes
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
        comoplete();
    }];
}

- (void)updateSceneWithTransition:(RNNativeSceneTransition)transition
                           action:(RNNativeStackNavigatorAction)action
                    currentScenes:(NSArray<RNNativeScene *> *)currentScenes
                       nextScenes:(NSArray<RNNativeScene *> *)nextScenes
                    removedScenes:(NSArray<RNNativeScene *> *)removedScenes
                   insertedScenes:(NSArray<RNNativeScene *> *)insertedScenes
                  beginTransition:(RNNativeNavigatorTransitionBlock)beginTransition
                    endTransition:(RNNativeNavigatorTransitionBlock)endTransition {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"For `RNNativeBaseNavigator` subclass, you must override %@ method", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

#pragma mark - Status

- (void)willUpdateStatusWithNextScenes:(NSArray<RNNativeScene *> *)nextScenes
                         removedScenes:(NSArray<RNNativeScene *> *)removedScenes
                                action:(RNNativeStackNavigatorAction)action {
    if (action == RNNativeStackNavigatorActionHide) {
        [self willBlurWithNextScenes:nextScenes removedScenes:removedScenes];
        [self willFocusWithNextScenes:nextScenes];
    } else {
        [self willFocusWithNextScenes:nextScenes];
        [self willBlurWithNextScenes:nextScenes removedScenes:removedScenes];
    }
}

- (void)didUpdateStatusWithNextScenes:(NSArray<RNNativeScene *> *)nextScenes
                        removedScenes:(NSArray<RNNativeScene *> *)removedScenes
                               action:(RNNativeStackNavigatorAction)action {
    if (action == RNNativeStackNavigatorActionHide) {
        [self didBlurredWithNextScenes:nextScenes removedScenes:removedScenes];
        [self didFocusedWithNextScenes:nextScenes];
    } else {
        [self didFocusedWithNextScenes:nextScenes];
        [self didBlurredWithNextScenes:nextScenes removedScenes:removedScenes];
    }
}

- (void)willBlurWithNextScenes:(NSArray<RNNativeScene *> *)nextScenes
                 removedScenes:(NSArray<RNNativeScene *> *)removedScenes {
    // removedScenes
    for (NSInteger index = 0, size = removedScenes.count; index < size; index++) {
        RNNativeScene *scene = removedScenes[index];
        [scene setStatus:RNNativeSceneStatusWillBlur];
    }
    
    // nextScenes
    for (NSInteger index = 0, size = nextScenes.count; index + 1 < size; index++) {
        RNNativeScene *scene = nextScenes[index];
        [scene setStatus:RNNativeSceneStatusWillBlur];
    }
}

- (void)didBlurredWithNextScenes:(NSArray<RNNativeScene *> *)nextScenes
                   removedScenes:(NSArray<RNNativeScene *> *)removedScenes {
    // removedScenes
    for (NSInteger index = 0, size = removedScenes.count; index < size; index++) {
        RNNativeScene *scene = removedScenes[index];
        [scene setStatus:RNNativeSceneStatusDidBlur];
    }
    
    // nextScenes
    for (NSInteger index = 0, size = nextScenes.count; index + 1 < size; index++) {
        RNNativeScene *scene = nextScenes[index];
        [scene setStatus:RNNativeSceneStatusDidBlur];
    }
}

- (void)willFocusWithNextScenes:(NSArray<RNNativeScene *> *)nextScenes {
    NSInteger size = nextScenes.count;
    if (size > 0) {
        RNNativeScene *scene = nextScenes[size - 1];
        [scene setStatus:RNNativeSceneStatusWillFocus];
    }
}

- (void)didFocusedWithNextScenes:(NSArray<RNNativeScene *> *)nextScenes {
    NSInteger size = nextScenes.count;
    if (size > 0) {
        RNNativeScene *scene = nextScenes[size - 1];
        [scene setStatus:RNNativeSceneStatusDidFocus];
    }
}

@end
