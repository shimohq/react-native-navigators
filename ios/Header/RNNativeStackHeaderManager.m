#import "RNNativeStackHeaderManager.h"
#import "RNNativeStackHeader.h"
#import "RNNativeStackHeaderShadowView.h"

@implementation RNNativeStackHeaderManager


RCT_EXPORT_MODULE()

- (UIView *)view {
    return [RNNativeStackHeader new];
}

- (RCTShadowView *)shadowView {
    return [RNNativeStackHeaderShadowView new];
}

RCT_EXPORT_VIEW_PROPERTY(headerBackgroundColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(headerBorderColor, UIColor)

@end
