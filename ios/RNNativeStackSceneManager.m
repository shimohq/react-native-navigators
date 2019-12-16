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


RCT_EXPORT_VIEW_PROPERTY(onWillFocus, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onDidFocus, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onWillBlur, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onDidBlur, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(transition, RNNativeStackSceneTransition)
RCT_EXPORT_VIEW_PROPERTY(gestureEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(closing, BOOL)
RCT_EXPORT_VIEW_PROPERTY(translucent, BOOL)
RCT_EXPORT_VIEW_PROPERTY(transparent, BOOL)
RCT_EXPORT_VIEW_PROPERTY(popover, NSDictionary)
RCT_EXPORT_VIEW_PROPERTY(statusBarStyle, NSInteger)
RCT_EXPORT_VIEW_PROPERTY(statusBarHidden, NSInteger)

@end
