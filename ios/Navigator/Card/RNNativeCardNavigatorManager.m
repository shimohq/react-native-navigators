//
//  RNNativeCardNavigatorManager.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2019/10/25.
//

#import "RNNativeCardNavigatorManager.h"
#import "RNNativeCardNavigator.h"
#import "RNNativeCardNavigatorShadowView.h"

@interface RNNativeCardNavigatorManager() {
    NSPointerArray *_hostViews;
}

@end

@implementation RNNativeCardNavigatorManager

RCT_EXPORT_MODULE()

- (UIView *)view {
    RNNativeCardNavigator *view = [[RNNativeCardNavigator alloc] initWithBridge:self.bridge];
    if (!_hostViews) {
        _hostViews = [NSPointerArray weakObjectsPointerArray];
    }
    [_hostViews addPointer:(__bridge void *)view];
    return view;
}

- (RCTShadowView *)shadowView {
    return [RNNativeCardNavigatorShadowView new];
}

#pragma mark - RCTInvalidating

- (void)invalidate {
    for (RNNativeCardNavigator *view in _hostViews) {
        [view invalidate];
    }
}

@end
