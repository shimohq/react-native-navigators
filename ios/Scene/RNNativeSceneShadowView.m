#import "RNNativeSceneShadowView.h"
#import "RNNativeNavigatorInsetsData.h"
#import "RNNativeNavigatorFrameData.h"

@implementation RNNativeSceneShadowView

- (void)setLocalData:(NSObject *)data
{
    if ([data isKindOfClass:[RNNativeNavigatorInsetsData class]]) {
        RNNativeNavigatorInsetsData *insets = (RNNativeNavigatorInsetsData *)data;
        self.top = (YGValue){insets.topInset, YGUnitPoint};
        self.right = (YGValue){insets.rightInset, YGUnitPoint};
        self.bottom = (YGValue){insets.bottomInset, YGUnitPoint};
        self.left = (YGValue){insets.leftInset, YGUnitPoint};
        [self didSetProps:@[@"top", @"right", @"bottom", @"left"]];
    } else if ([data isKindOfClass:[RNNativeNavigatorFrameData class]]) {
        RNNativeNavigatorFrameData *frame = (RNNativeNavigatorFrameData *)data;
        self.top = (YGValue){frame.frame.origin.y, YGUnitPoint};
        self.left = (YGValue){frame.frame.origin.x, YGUnitPoint};
        self.width = (YGValue){frame.frame.size.width, YGUnitPoint};
        self.height = (YGValue){frame.frame.size.height, YGUnitPoint};
        [self didSetProps:@[@"top", @"left", @"width", @"height"]];
    }
}

@end
