#import <React/RCTViewManager.h>
#import <React/RCTView.h>

#import "RNNativeStackConst.h"
#import "RNNativeStackController.h"
#import "RNNativePopoverParams.h"

@class RNNativeStackScene;
@protocol RNNativeStackSceneDelegate <NSObject>

- (void)needUpdateForScene:(RNNativeStackScene *)scene;

@end

@interface RNNativeStackScene : RCTView <RCTInvalidating>

@property (nonatomic, assign) RNNativeStackSceneTransition transition;
// 是否开启 pop 手势
@property (nonatomic, assign) BOOL gestureEnabled;
@property (nonatomic, assign) BOOL closing;
// 导航条是否沉浸
@property (nonatomic, assign) BOOL translucent;
/**
 是否透明
 
 不适用于 stack
 适用于 modal：
 YES:  present 之后 presenting viewcontroller 不会移除
 NO:  present 之后 presenting viewcontroller 会被移除，有利于内存释放。
 默认: NO
 */
@property (nonatomic, assign) BOOL transparent;
@property (nonatomic, strong) NSDictionary *popover;
@property (nonatomic, copy) RCTDirectEventBlock onTransitionEnd;
@property (nonatomic, copy) RCTDirectEventBlock onDismissed;

@property (nonatomic, weak) id<RNNativeStackSceneDelegate> delegate;
@property (nonatomic, strong, readonly) RNNativeStackController *controller;
@property (nonatomic, strong, readonly) RNNativePopoverParams *popoverParams;

- (instancetype)initWithBridge:(RCTBridge *)bridge;
- (void)updateBounds;
- (void)transitionEnd:(BOOL)closing;
- (void)dismiss;

@end

