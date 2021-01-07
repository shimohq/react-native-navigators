//
//  RNNativeSplitPlaceholderShadowView.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/7.
//

#import "RNNativeSplitPlaceholderShadowView.h"
#import "RNNativeNavigatorFrameData.h"

@implementation RNNativeSplitPlaceholderShadowView

- (void)setLocalData:(NSObject *)data {
    if ([data isKindOfClass:[RNNativeNavigatorFrameData class]]) {
        RNNativeNavigatorFrameData *frame = (RNNativeNavigatorFrameData *)data;
        self.top = (YGValue){frame.frame.origin.y, YGUnitPoint};
        self.left = (YGValue){frame.frame.origin.x, YGUnitPoint};
        self.width = (YGValue){frame.frame.size.width, YGUnitPoint};
        self.height = (YGValue){frame.frame.size.height, YGUnitPoint};
        [self didSetProps:@[@"top", @"left", @"width", @"height"]];
    }
}

@end
