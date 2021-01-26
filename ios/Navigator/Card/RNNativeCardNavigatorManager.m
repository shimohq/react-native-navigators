//
//  RNNativeCardNavigatorManager.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2019/10/25.
//

#import "RNNativeCardNavigatorManager.h"
#import "RNNativeCardNavigator.h"
#import "RNNativeCardNavigatorShadowView.h"

@interface RNNativeCardNavigatorManager()

@property (nonatomic, strong) NSPointerArray *hostViews;

@end

@implementation RNNativeCardNavigatorManager

RCT_EXPORT_MODULE()

- (void)setBridge:(RCTBridge *)bridge {
    [super setBridge:bridge];
    _hostViews = [NSPointerArray weakObjectsPointerArray];
}

- (UIView *)view {
    RNNativeCardNavigator *view = [[RNNativeCardNavigator alloc] initWithBridge:self.bridge];
    [_hostViews addPointer:(__bridge void *)view];
    return view;
}

- (RCTShadowView *)shadowView {
    return [[RNNativeCardNavigatorShadowView alloc] initWithBridge:self.bridge];
}

#pragma mark - RCTInvalidating

- (void)invalidate {
    for (RNNativeCardNavigator *view in _hostViews) {
        [view invalidate];
    }
}

@end
