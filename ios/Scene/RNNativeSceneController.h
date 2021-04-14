#import <UIKit/UIKit.h>

#import "RNNativeSceneController.h"
#import "RNNativeConst.h"

@class RNNativeScene;

@interface RNNativeSceneController : UIViewController

@property (nonatomic, weak) RNNativeScene *nativeScene;
@property (nonatomic, assign) RNNativeSceneStatus status;

/**
 status bar 样式
 */
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

/**
 是否隐藏 status bar
 */
@property (nonatomic, assign) BOOL statusBarHidden;

/**
 是否监听 ViewController 的生命周期
 
 * Card Split 模式可以直接处理 scene.status，不需要监听
 * Stack 模式无法直接监听手势返回，需要通过监听 scene.viewController 的生命周期来更新 scene.status
 */
@property (nonatomic, assign) BOOL enableLifeCycle;

- (instancetype)initWithNativeScene:(RNNativeScene *)nativeScene;

@end

