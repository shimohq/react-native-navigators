#import <React/RCTViewManager.h>
#import <React/RCTView.h>

#import "RNNativeConst.h"
#import "RNNativeSceneController.h"

@class RNNativeScene;

@protocol RNNativeSceneListener <NSObject>

- (void)scene:(RNNativeScene *)scene didUpdateStatus:(RNNativeSceneStatus) status;

@end

@protocol RNNativeSceneDelegate <NSObject>

- (void)needUpdateForScene:(RNNativeScene *)scene;

@end

@interface RNNativeScene : RCTView <RCTInvalidating>

/**
 切换 scene 的动画
 
 * "default": 默认动画，stack 显示的时候从右往左，隐藏的时候从左往右。card 显示的时候从下往上，隐藏的时候从上往下
 * "none": 无动画
 * "slideFromTop": 显示的时候从上往下，隐藏的时候从下往上
 * "slideFromRight": 显示的时候从右往左，隐藏的时候从左往右
 * "slideFromBottom": 显示的时候从下往上，隐藏的时候从上往下
 * "slideFromLeft": 显示的时候从左往右，隐藏的时候从右往左
 
 默认：default
 */
@property (nonatomic, assign) RNNativeSceneTransition transition;

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
 适用于  Card：
 
 默认: NO
 */
@property (nonatomic, assign) BOOL transparent;

@property (nonatomic, copy) RCTDirectEventBlock onWillFocus;
@property (nonatomic, copy) RCTDirectEventBlock onDidFocus;
@property (nonatomic, copy) RCTDirectEventBlock onWillBlur;
@property (nonatomic, copy) RCTDirectEventBlock onDidBlur;

/**
 status bar 样式
 */
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

/**
 是否隐藏 status bar
 */
@property (nonatomic, assign) BOOL statusBarHidden;

/**
 分屏模式是否显示在左边的主屏幕
 */
@property (nonatomic, assign) BOOL splitPrimary;

/**
 Whether enable ViewController life cycle to update status
 */
@property (nonatomic, assign) BOOL enableLifeCycle;

@property (nonatomic, assign) RNNativeSceneStatus status;
/**
 是否已经从原生界面移除
 */
@property (nonatomic, assign, readonly) BOOL dismissed;
@property (nonatomic, weak) id<RNNativeSceneDelegate> delegate;
@property (nonatomic, strong, readonly) RNNativeSceneController *controller;

- (instancetype)initWithBridge:(RCTBridge *)bridge;
- (void)registerListener:(id<RNNativeSceneListener>)listener;
- (void)unregisterListener:(id<RNNativeSceneListener>)listener;
- (void)remove;

@end

