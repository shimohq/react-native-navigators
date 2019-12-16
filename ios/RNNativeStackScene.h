#import <React/RCTViewManager.h>
#import <React/RCTView.h>

#import "RNNativeStackConst.h"
#import "RNNativeStackController.h"
#import "RNNativePopoverParams.h"

@class RNNativeStackScene;

@protocol RNNativeStackSceneListener <NSObject>

- (void)scene:(RNNativeStackScene *)scene didUpdateStatus:(RNNativeStackSceneStatus) status;

@end

@protocol RNNativeStackSceneDelegate <NSObject>

- (void)needUpdateForScene:(RNNativeStackScene *)scene;
- (BOOL)isDismissedForScene:(RNNativeStackScene *)scene;

@end

@interface RNNativeStackScene : RCTView <RCTInvalidating>

/**
 切换 scene 的动画
 
 * "default": 默认动画，stack 显示的时候从右往左，隐藏的时候从左往右。modal card 显示的时候从下往上，隐藏的时候从上往下
 * "none": 无动画
 * "slideFromTop": 显示的时候从上往下，隐藏的时候从下往上
 * "slideFromRight": 显示的时候从右往左，隐藏的时候从左往右
 * "slideFromBottom": 显示的时候从下往上，隐藏的时候从上往下
 * "slideFromLeft": 显示的时候从左往右，隐藏的时候从右往左
 
 默认：default
 */
@property (nonatomic, assign) RNNativeStackSceneTransition transition;

/**
 是否开启手势返回
 
 默认：NO
 */
@property (nonatomic, assign) BOOL gestureEnabled;

/**
 是否关闭 scene
 
 * YES: 关闭该 scene
 
 默认：NO
 */
@property (nonatomic, assign) BOOL closing;

/**
 导航条是否沉浸
 
 默认：NO
 */
@property (nonatomic, assign) BOOL translucent;

/**
 是否透明
  
 YES:  scene 显示之后下层的 scene 不会移除。
 NO:  scene 显示之后下层的 scene 会移除，有利于内存释放。
 
 不适用于 stack，因为 stack 默认 YES，不可修改
 适用于 modal  Card：
 
 默认: NO
 */
@property (nonatomic, assign) BOOL transparent;

/**
 popover 信息
 
 只适用于 iPad
 */
@property (nonatomic, strong) NSDictionary *popover;
@property (nonatomic, copy) RCTDirectEventBlock onWillFocus;
@property (nonatomic, copy) RCTDirectEventBlock onDidFocus;
@property (nonatomic, copy) RCTDirectEventBlock onWillBlur;
@property (nonatomic, copy) RCTDirectEventBlock onDidBlur;

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@property (nonatomic, assign) RNNativeStackSceneStatus status;
@property (nonatomic, assign) BOOL dismissed;
@property (nonatomic, weak) id<RNNativeStackSceneDelegate> delegate;
@property (nonatomic, strong, readonly) RNNativeStackController *controller;
@property (nonatomic, strong, readonly) RNNativePopoverParams *popoverParams;

- (instancetype)initWithBridge:(RCTBridge *)bridge;
- (void)updateBounds;
- (void)registerListener:(id<RNNativeStackSceneListener>)listener;
- (void)unregisterListener:(id<RNNativeStackSceneListener>)listener;

@end

