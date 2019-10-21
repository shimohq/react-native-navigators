//
//  RNNativeModalNavigatorManager.m
//  owl
//
//  Created by Bell Zhong on 2019/10/16.
//  Copyright © 2019 shimo.im. All rights reserved.
//

#import "RNNativeModalNavigatorManager.h"
#import "RNNativeModalNavigator.h"

@interface RNNativeModalNavigatorManager() {
    NSPointerArray *_hostViews;
}

@end

@implementation RNNativeModalNavigatorManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    RNNativeModalNavigator *view = [RNNativeModalNavigator new];
    if (!_hostViews) {
        _hostViews = [NSPointerArray weakObjectsPointerArray];
    }
    [_hostViews addPointer:(__bridge void *)view];
    return view;
}

#pragma mark - RCTInvalidating

- (void)invalidate {
    for (RNNativeModalNavigator *view in _hostViews) {
        [view invalidate];
    }
}

@end
