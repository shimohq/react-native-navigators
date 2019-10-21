#import <React/RCTViewManager.h>
#import <React/RCTView.h>

#import "RNNativeStackConst.h"
#import "RNNativeStackController.h"

@class RNNativeStackScene;
@protocol RNNativeStackSceneDelegate <NSObject>

- (void)needUpdateForScene:(RNNativeStackScene *)scene;

@end

@interface RNNativeStackScene : RCTView <RCTInvalidating>

@property (nonatomic, assign) RNNativeStackSceneTransition transition;
// TODO: 是否开启 pop 手势
@property (nonatomic, assign) BOOL gestureEnabled;
@property (nonatomic, assign) BOOL closing;
// 导航条是否沉浸
@property (nonatomic, assign) BOOL translucent;

@property (nonatomic, strong) RNNativeStackController *controller;
@property (nonatomic, copy) RCTDirectEventBlock onTransitionEnd;
@property (nonatomic, copy) RCTDirectEventBlock onDismissed;

@property (nonatomic, weak) id<RNNativeStackSceneDelegate> delegate;

- (instancetype)initWithBridge:(RCTBridge *)bridge;
- (void)updateBounds;
- (void)transitionEnd:(BOOL)closing;
- (void)dismiss;

@end

