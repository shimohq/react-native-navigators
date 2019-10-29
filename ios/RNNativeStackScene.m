#import "RNNativeStackScene.h"
#import "RNNativeModalAnimatedTransition.h"
#import "RNNativeStackController.h"
#import "RNNativeNavigatorInsetsData.h"
#import "RNNativeNavigatorFrameData.h"
#import "RNNativeStackHeader.h"
#import "RNNativeModalPresentationController.h"

#import <React/RCTUIManager.h>
#import <React/RCTUIManagerUtils.h>
#import <React/RCTTouchHandler.h>

@interface RNNativeStackScene() <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) RNNativeStackController *controller;

@end

@implementation RNNativeStackScene
{
    __weak RCTBridge *_bridge;
    RCTTouchHandler *_touchHandler;
}

- (instancetype)initWithBridge:(RCTBridge *)bridge
{
    
    if (self = [super init]) {
        _transition = RNNativeStackSceneTransitionDefault;
        _closing = NO;
        _translucent = NO;
        _bridge = bridge;
        _controller = [[RNNativeStackController alloc] initWithScene:self];
        _controller.transitioningDelegate = self;
    }
    return self;
}

- (void)insertReactSubview:(UIView *)subview atIndex:(NSInteger)atIndex
{
    [super insertReactSubview:subview atIndex:atIndex];
    if ([subview isKindOfClass:[RNNativeStackHeader class]] && _controller.navigationController != nil) {
        [_controller.navigationController setNavigationBarHidden:NO];
        [(RNNativeStackHeader *)subview attachViewController:_controller];
        [self updateBounds];
    }
}

- (void)removeReactSubview:(UIView *)subview
{
    [super removeReactSubview:subview];
    if ([subview isKindOfClass:[RNNativeStackHeader class]] && _controller.navigationController != nil) {
        [_controller.navigationController setNavigationBarHidden:YES];
        [(RNNativeStackHeader *)subview detachViewController];
        [self updateBounds];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    RNNativeNavigatorFrameData *data = [[RNNativeNavigatorFrameData alloc] initWithFrame:self.frame];
    [_bridge.uiManager setLocalData:data forView:self];
}

#pragma mark - TouchHandler

- (void)didMoveToWindow
{
    // For RN touches to work we need to instantiate and connect RCTTouchHandler. This only applies
    // for screens that aren't mounted under RCTRootView e.g., modals that are mounted directly to
    // root application window.
    if (self.window != nil && ![self isMountedUnderScreenOrReactRoot]) {
        if (_touchHandler == nil) {
            _touchHandler = [[RCTTouchHandler alloc] initWithBridge:_bridge];
        }
        [_touchHandler attachToView:self];
    } else {
        [_touchHandler detachFromView:self];
    }
}

#pragma mark - RCTInvalidating

- (void)invalidate {
    
}

#pragma mark - UIViewControllerTransitioningDelegate
// 自定义 present dismiss 动画

/**
 present 动画
 */
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    if (_transition == RNNativeStackSceneTransitionDefault || _transition == RNNativeStackSceneTransitionNone) {
        return nil;
    }
    return [[RNNativeModalAnimatedTransition alloc] initWithTransition:_transition presenting:YES];
}

/**
 dismiss 动画
 */
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if (_transition == RNNativeStackSceneTransitionDefault || _transition == RNNativeStackSceneTransitionNone) {
        return nil;
    }
    return [[RNNativeModalAnimatedTransition alloc] initWithTransition:_transition presenting:NO];
}

/**
 present 手势动画
 TODO: 未实现
 */
- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

/**
 dismiss 手势动画
 TODO: 未实现
 */
- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source {
    if (presented.modalPresentationStyle == UIModalPresentationCustom) {
        RNNativeModalPresentationController *presentationController = [[RNNativeModalPresentationController alloc] initWithPresentedViewController:presented presentingViewController:source];
        if ([presented.view isKindOfClass:[RNNativeStackScene class]]) {
            RNNativeStackScene *scene = (RNNativeStackScene *)presented.view;
            presentationController.transparent  = scene.transparent;
        }
        return presentationController;
    } else {
        return nil;
    }
}

#pragma mark - Setter

- (void)setClosing:(BOOL)closing
{
    if (_closing == closing) {
        return;
    }
    _closing = closing;
    [_delegate needUpdateForScene:self];
}

- (void)setTranslucent:(BOOL)translucent
{
    if (_translucent == translucent) {
        return;
    }
    _translucent = translucent;
    
    if (_controller.navigationController) {
        _controller.navigationController.navigationBar.translucent = translucent;
    }
}

- (void)setPopover:(NSDictionary *)popover {
    _popover = popover;
    _popoverParams = [[RNNativePopoverParams alloc] initWithParams:popover];
}

- (void)setStatus:(RNNativeStackSceneStatus)status {
    if (_status == status) {
        return;
    }
    if (_status == RNNativeStackSceneStatusDidBlur && status == RNNativeStackSceneStatusWillBlur) {
        return;
    }
    if (_status == RNNativeStackSceneStatusDidFocus && status == RNNativeStackSceneStatusWillFocus) {
        return;
    }
    _status = status;
    switch (_status) {
        case RNNativeStackSceneStatusWillFocus:
            if (_onWillFocus) {
                _onWillFocus(nil);
            }
            break;
        case RNNativeStackSceneStatusDidFocus:
            if (_onDidFocus) {
                _onDidFocus(nil);
            }
            break;
        case RNNativeStackSceneStatusWillBlur:
            if (_onWillBlur) {
                _onWillBlur(nil);
            }
            break;
        case RNNativeStackSceneStatusDidBlur:
            if (_onDidBlur) {
                _onDidBlur(@{
                    @"dimissed": @([_delegate isDismissedForScene:self])
                });
            }
            break;
        default:
            break;
    }
}

#pragma mark - Private

- (BOOL)isMountedUnderScreenOrReactRoot
{
    for (UIView *parent = self.superview; parent != nil; parent = parent.superview) {
        if ([parent isKindOfClass:[RCTRootView class]] || [parent isKindOfClass:[RNNativeStackScene class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)updateBounds
{
    CGFloat offset = 0;
    UINavigationController *navigationController = _controller.navigationController;
    if (!navigationController.isNavigationBarHidden && !_translucent) {
        CGRect frame = navigationController.navigationBar.frame;
        offset = frame.origin.y + frame.size.height;
    }
    [_bridge.uiManager setLocalData:[[RNNativeNavigatorInsetsData alloc] initWithInsets:UIEdgeInsetsMake(offset, 0, 0, 0)]
                            forView:self];
}

@end

@implementation RCTConvert (RNNativeStackScene)

RCT_ENUM_CONVERTER(RNNativeStackSceneTransition, (@{
    @"default": @(RNNativeStackSceneTransitionDefault),
    @"none": @(RNNativeStackSceneTransitionNone),
    @"slideFromTop": @(RNNativeStackSceneTransitionSlideFormTop),
    @"slideFromRight": @(RNNativeStackSceneTransitionSlideFormRight),
    @"slideFromBottom": @(RNNativeStackSceneTransitionSlideFormBottom),
    @"slideFromLeft": @(RNNativeStackSceneTransitionSlideFormLeft)
}), RNNativeStackSceneTransitionNone, integerValue)

@end
