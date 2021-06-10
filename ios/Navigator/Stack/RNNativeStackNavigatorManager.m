#import "RNNativeStackNavigatorManager.h"
#import "RNNativeStackNavigator.h"
#import "RNNativeStackNavigatorShadowView.h"

@implementation RNNativeStackNavigatorManager {
    NSPointerArray *_hostViews;
}


RCT_EXPORT_MODULE()

- (UIView *)view {
    RNNativeStackNavigator *view = [[RNNativeStackNavigator alloc] initWithBridge:self.bridge];
    if (!_hostViews) {
        _hostViews = [NSPointerArray weakObjectsPointerArray];
    }
    [_hostViews addPointer:(__bridge void *)view];
    return view;
}

- (RCTShadowView *)shadowView {
  return [[RNNativeStackNavigatorShadowView alloc] initWithBridge:self.bridge];
}

#pragma mark - RCTInvalidating

- (void)invalidate {
    for (RNNativeStackNavigator *view in _hostViews) {
        [view invalidate];
    }
}

@end
