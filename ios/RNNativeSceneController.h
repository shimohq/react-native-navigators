#import <UIKit/UIKit.h>

#import "RNNativeSceneController.h"
#import "RNNativeConst.h"

@class RNNativeScene;

@interface RNNativeSceneController : UIViewController

@property (nonatomic, weak) RNNativeScene *scene;

/**
 status bar 样式
 -1: 取系统的，默认值
 。。。
 */
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

/**
 是否隐藏 status bar
 -1: 取系统的，默认值
 0:  显示
 1: 隐藏
 */
@property (nonatomic, assign) NSInteger statusBarHidden;

- (instancetype)initWithScene:(RNNativeScene *)scene;

- (void)updateForStatus:(RNNativeSceneStatus)status;

@end
