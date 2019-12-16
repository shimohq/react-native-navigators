#import <UIKit/UIKit.h>

#import "RNNativeStackController.h"
#import "RNNativeStackConst.h"

@class RNNativeStackScene;

@interface RNNativeStackController : UIViewController

@property (nonatomic, weak) RNNativeStackScene *scene;
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

- (instancetype)initWithScene:(RNNativeStackScene *)scene;

- (void)updateForStatus:(RNNativeStackSceneStatus)status;

@end
