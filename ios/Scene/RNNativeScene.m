#import "RNNativeScene.h"
#import "RNNativeSceneController.h"
#import "RNNativeStackHeader.h"
#import "RNNativeSceneShadowView.h"

#import <React/RCTUIManager.h>
#import <React/RCTUIManagerUtils.h>
#import <React/RCTTouchHandler.h>

@interface RNNativeScene() <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) RNNativeSceneController *controller;
@property (nonatomic, strong) NSPointerArray *listeners;
@property (nonatomic, weak) RCTBridge *bridge;

@end

@implementation RNNativeScene {
    RCTTouchHandler *_touchHandler;
    __weak UIView *_firstResponderView;
    BOOL _dismissed;
}

- (instancetype)initWithBridge:(RCTBridge *)bridge {
    if (self = [super init]) {
        _transition = RNNativeSceneTransitionDefault;
        _closing = NO;
        _translucent = NO;
        _bridge = bridge;
        _dismissed = NO;
        _controller = [[RNNativeSceneController alloc] initWithNativeScene:self];
        _controller.transitioningDelegate = self;
        _listeners = [NSPointerArray weakObjectsPointerArray];
    }
    return self;
}

#pragma mark - Public

- (void)registerListener:(id<RNNativeSceneListener>)listener {
    [_listeners addPointer:(__bridge void *)(listener)];
    [listener scene:self didUpdateStatus:_status];
}

- (void)unregisterListener:(id<RNNativeSceneListener>)listener {
    NSInteger index = [_listeners indexOfAccessibilityElement:listener];
    if (index != NSNotFound) {
        [_listeners removePointerAtIndex:index];
    }
}

#pragma mark - RCTInvalidating

- (void)invalidate {
    _controller = nil;
}

#pragma mark - React Native

- (void)insertReactSubview:(UIView *)subview atIndex:(NSInteger)atIndex {
    [super insertReactSubview:subview atIndex:atIndex];
    if ([subview isKindOfClass:[RNNativeStackHeader class]]
        && _controller.navigationController != nil
        && (_status == RNNativeSceneStatusWillFocus || _status == RNNativeSceneStatusDidFocus)) {
        [_controller.navigationController setNavigationBarHidden:NO];
        [(RNNativeStackHeader *)subview attachViewController:_controller];
    }
}

- (void)removeReactSubview:(UIView *)subview {
    [super removeReactSubview:subview];
    if ([subview isKindOfClass:[RNNativeStackHeader class]]
        && _controller.navigationController != nil
        && (_status == RNNativeSceneStatusWillFocus || _status == RNNativeSceneStatusDidFocus)) {
        [_controller.navigationController setNavigationBarHidden:YES];
        [(RNNativeStackHeader *)subview detachViewController];
    }
}

#pragma mark - UIView

- (BOOL)resignFirstResponder {
    _firstResponderView = [self findFirstResponderView:self];
    if (_firstResponderView) {
        return [_firstResponderView resignFirstResponder];
    } else {
        return [super resignFirstResponder];
    }
}

- (BOOL)becomeFirstResponder {
    if (_firstResponderView) {
        UIView *firstResponder = _firstResponderView;
        _firstResponderView = nil;
        return [firstResponder becomeFirstResponder];
    } else {
        return [super becomeFirstResponder];
    }
}

#pragma mark - TouchHandler

- (void)didMoveToWindow
{
    if (self.window) {
        _dismissed = NO;
    }
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
    _controller = nil;
}

#pragma mark - Getter

- (BOOL)statusBarHidden {
    return _controller.statusBarHidden;
}

- (UIStatusBarStyle)statusBarStyle {
    return _controller.statusBarStyle;
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

- (void)setStatus:(RNNativeSceneStatus)status {
    BOOL dismissed = false;
    if (status == RNNativeSceneStatusDidBlur && !_dismissed) {
        dismissed = [_delegate isDismissedForScene:self];
        _dismissed = dismissed;
    }
    BOOL statusChanged = _status != status
    && !(_status == RNNativeSceneStatusDidBlur && status == RNNativeSceneStatusWillBlur)
    && !(_status == RNNativeSceneStatusDidFocus && status == RNNativeSceneStatusWillFocus);
    if (statusChanged) {
        _status = status;
        [_controller setStatus:status];
        
        // send status to all listeners
        for (id<RNNativeSceneListener> listener in _listeners) {
            [listener scene:self didUpdateStatus:status];
        }
    }
    if (statusChanged || dismissed) {
        [self sendStatus:_status andDismissed:dismissed];
    }
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    [_controller setStatusBarStyle:statusBarStyle];
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden {
    [_controller setStatusBarHidden:statusBarHidden];
}

- (void)setSplitFullScreen:(BOOL)splitFullScreen {
    if (_splitFullScreen == splitFullScreen) {
        return;
    }
    _splitFullScreen = splitFullScreen;
    if ([self.delegate respondsToSelector:@selector(didFullScreenChangedWithScene:)]) {
        [self.delegate didFullScreenChangedWithScene:self];
    }
}

- (void)setEnableLifeCycle:(BOOL)enableLifeCycle {
    [_controller setEnableLifeCycle:enableLifeCycle];
}

#pragma mark - Private

- (void)sendStatus:(RNNativeSceneStatus)status andDismissed:(BOOL)dismissed {
    switch (status) {
        case RNNativeSceneStatusWillFocus:
            if (_onWillFocus) {
                _onWillFocus(nil);
            }
            break;
        case RNNativeSceneStatusDidFocus:
            if (_onDidFocus) {
                _onDidFocus(nil);
            }
            break;
        case RNNativeSceneStatusWillBlur:
            if (_onWillBlur) {
                _onWillBlur(nil);
            }
            break;
        case RNNativeSceneStatusDidBlur:
            if (_onDidBlur) {
                _onDidBlur(@{
                    @"dismissed": @(dismissed)
                });
            }
            break;
        default:
            break;
    }
}

- (BOOL)isMountedUnderScreenOrReactRoot {
    for (UIView *parent = self.superview; parent != nil; parent = parent.superview) {
        if ([parent isKindOfClass:[RCTRootView class]] || [parent isKindOfClass:[RNNativeScene class]]) {
            return YES;
        }
    }
    return NO;
}

- (UIView *)findFirstResponderView:(UIView *)view {
    if ([view isFirstResponder]) {
        return view;
    }
    for (UIView *subview in view.subviews) {
        UIView *result = [self findFirstResponderView:subview];
        if (result) {
            return result;
        }
    }
    return nil;
}

@end
