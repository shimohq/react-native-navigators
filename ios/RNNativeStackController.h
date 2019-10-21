#import <UIKit/UIKit.h>

#import "RNNativeStackController.h"

@class RNNativeStackScene;

@interface RNNativeStackController : UIViewController

@property (nonatomic, weak) RNNativeStackScene *scene;

- (instancetype)initWithScene:(RNNativeStackScene *)scene;

@end
