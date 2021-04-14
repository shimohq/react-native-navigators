//
//  RNNativeBaseNavigator.m
//  owl
//
//  Created by Bell Zhong on 2019/10/16.
//  Copyright © 2019 shimo.im. All rights reserved.
//

#import "RNNativeBaseNavigator.h"

#import <objc/runtime.h>
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
@property (nonatomic, assign) BOOL needUpdate;

@end

@implementation RNNativeBaseNavigator

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
    // INFO 调用 [super insertReactSubview] 更新 reactSubviews
    // 但是 didUpdateReactSubviews 不做任何操作，防止调用 addSubview
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
    // INFO 不调用 [super removeReactSubview] 防止调用 removeFromSuperview,
    // 但是 为了更新 reactSubviews，拷贝了下面代码
    NSMutableArray *subviews = objc_getAssociatedObject(self, @selector(reactSubviews));
    [subviews removeObject:subview];
    
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
    if (self.updatingScenes || !self.needUpdateScenes) {
        return;
    }
    self.updatingScenes = YES;
    NSArray<RNNativeScene *> *nextScenes = [NSArray arrayWithArray:self.needUpdateScenes];
    self.needUpdateScenes = nil;
    
    [self updateSceneWithCurrentScenes:self.currentScenes
                            nextScenes:nextScenes
                          checkUpdated:YES
                             comoplete:^{
        [self setUpdatingScenes:NO];
    }];
    
    [self.currentScenes setArray:nextScenes];
}

- (void)reloadScenes {
    if (self.updatingScenes) {
        return;
    }
    self.updatingScenes = YES;
    [self updateSceneWithCurrentScenes:self.currentScenes
                            nextScenes:self.currentScenes
                          checkUpdated:NO
                             comoplete:^{
        [self setUpdatingScenes:NO];
    }];
}

- (void)updateSceneWithCurrentScenes:(NSArray<RNNativeScene *> *)currentScenes
                          nextScenes:(NSArray<RNNativeScene *> *)nextScenes
                        checkUpdated:(BOOL)checkUpdated
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
    
    if (checkUpdated) {
        if (removedScenes.count == 0 && insertedScenes.count == 0) {
            // 没有 scene 添加或删除
            BOOL orderChanged = NO;
            // 检查顺序是否产生变化
            for (int i = 0; i < currentScenes.count; i++) {
                if (currentScenes[i] != nextScenes[i]) {
                    orderChanged = YES;
                    break;
                }
            }
            if (!orderChanged) {
                // 顺序无更新
                comoplete();
                return;
            }
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
            if (!currentTopScene.dismissed && currentTopScene.controller) {
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
        [scene remove];
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
