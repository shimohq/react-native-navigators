//
//  RNNativeSplitNavigatorManager.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/6.
//

#import "RNNativeSplitNavigatorManager.h"
#import "RNNativeSplitNavigator.h"

@interface RNNativeSplitNavigatorManager() {
    NSPointerArray *_hostViews;
}

@end

@implementation RNNativeSplitNavigatorManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    RNNativeSplitNavigator *view = [[RNNativeSplitNavigator alloc] initWithBridge:self.bridge];
    if (!_hostViews) {
        _hostViews = [NSPointerArray weakObjectsPointerArray];
    }
    [_hostViews addPointer:(__bridge void *)view];
    return view;
}

RCT_EXPORT_VIEW_PROPERTY(splitRules, NSArray)

#pragma mark - RCTInvalidating

- (void)invalidate {
    for (RNNativeSplitNavigator *view in _hostViews) {
        [view invalidate];
    }
}

@end
