#import "RNNativeStackNavigatorManager.h"
#import "RNNativeStackNavigator.h"

@interface RNNativeStackNavigatorManager() {
    NSPointerArray *_hostViews;
}

@end

@implementation RNNativeStackNavigatorManager


RCT_EXPORT_MODULE()

- (UIView *)view
{
    RNNativeStackNavigator *view = [RNNativeStackNavigator new];
    if (!_hostViews) {
        _hostViews = [NSPointerArray weakObjectsPointerArray];
    }
    [_hostViews addPointer:(__bridge void *)view];
    return view;
}

#pragma mark - RCTInvalidating

- (void)invalidate {
    for (RNNativeStackNavigator *view in _hostViews) {
        [view invalidate];
    }
}

@end
