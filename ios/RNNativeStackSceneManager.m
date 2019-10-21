#import "RNNativeStackSceneManager.h"
#import "RNNativeStackScene.h"
#import "RNNativeStackSceneShadowView.h"

@implementation RNNativeStackSceneManager


RCT_EXPORT_MODULE()

- (UIView *)view
{
  return [[RNNativeStackScene alloc] initWithBridge:self.bridge];
}

- (RCTShadowView *)shadowView
{
  return [RNNativeStackSceneShadowView new];
}


RCT_EXPORT_VIEW_PROPERTY(onTransitionEnd, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onDismissed, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(transition, RNNativeStackSceneTransition)
RCT_EXPORT_VIEW_PROPERTY(gestureEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(closing, BOOL)
RCT_EXPORT_VIEW_PROPERTY(translucent, BOOL)

@end
