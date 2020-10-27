#import <UIKit/UIKit.h>

#import "RNNativeSceneController.h"
#import "RNNativeConst.h"

@class RNNativeScene;

@interface RNNativeSceneController : UIViewController

@property(nonatomic, weak) RNNativeScene *rnScene;
@property(nonatomic, assign) RNNativeSceneStatus status;

/**
 status bar 样式
 */
@property(nonatomic, assign) UIStatusBarStyle statusBarStyle;

/**
 是否隐藏 status bar
 */
@property(nonatomic, assign) BOOL statusBarHidden;

- (instancetype)initWithScene:(RNNativeScene *)scene;

@end
