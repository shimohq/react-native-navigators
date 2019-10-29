#import <UIKit/UIKit.h>

#import "RNNativeStackController.h"
#import "RNNativeStackConst.h"

@class RNNativeStackScene;

@interface RNNativeStackController : UIViewController

@property (nonatomic, weak) RNNativeStackScene *scene;

- (instancetype)initWithScene:(RNNativeStackScene *)scene;

- (void)updateForStatus:(RNNativeStackSceneStatus)status;

@end
