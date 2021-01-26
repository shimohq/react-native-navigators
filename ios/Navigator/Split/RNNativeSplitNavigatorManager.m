//
//  RNNativeSplitNavigatorManager.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/6.
//

#import "RNNativeSplitNavigatorManager.h"
#import "RNNativeSplitNavigator.h"
#import "RNNativeSplitNavigatorShadowView.h"

@interface RNNativeSplitNavigatorManager()

@property (nonatomic, strong) NSPointerArray *hostViews;

@end

@implementation RNNativeSplitNavigatorManager

RCT_EXPORT_MODULE()

- (void)setBridge:(RCTBridge *)bridge {
    [super setBridge:bridge];
    
    _hostViews = [NSPointerArray weakObjectsPointerArray];
}

- (UIView *)view {
    RNNativeSplitNavigator *view = [[RNNativeSplitNavigator alloc] initWithBridge:self.bridge];
    [_hostViews addPointer:(__bridge void *)view];
    return view;
}

- (RCTShadowView *)shadowView {
    return [[RNNativeSplitNavigatorShadowView alloc] initWithBridge:self.bridge];
}

RCT_EXPORT_VIEW_PROPERTY(splitRules, NSArray)
RCT_EXPORT_SHADOW_PROPERTY(splitRules, NSArray)

#pragma mark - RCTInvalidating

- (void)invalidate {
    for (RNNativeSplitNavigator *view in _hostViews) {
        [view invalidate];
    }
}

@end
