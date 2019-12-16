#import <UIKit/UIKit.h>

#import "RNNativeStackController.h"
#import "RNNativeStackConst.h"

@class RNNativeStackScene;

@interface RNNativeStackController : UIViewController

@property (nonatomic, weak) RNNativeStackScene *scene;

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

- (instancetype)initWithScene:(RNNativeStackScene *)scene;

- (void)updateForStatus:(RNNativeStackSceneStatus)status;

@end
