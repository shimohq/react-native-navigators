#import "RNNativeSceneManager.h"
#import "RNNativeScene.h"
#import "RNNativeSceneShadowView.h"

@interface RNNativeSceneManager()

@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat headerTop;

@end

@implementation RNNativeSceneManager


RCT_EXPORT_MODULE()

- (instancetype)init {
    self = [super init];
    if (self) {
        UINavigationController *navigationController = [[UINavigationController alloc] init];
        _headerHeight = CGRectGetHeight(navigationController.navigationBar.frame);
        _headerTop = [UIApplication sharedApplication].delegate.window.rootViewController.view.safeAreaInsets.top;
    }
    return self;
}

- (UIView *)view {
  return [[RNNativeScene alloc] initWithBridge:self.bridge];
}

- (RCTShadowView *)shadowView {
  return [RNNativeSceneShadowView new];
}

// for view
RCT_EXPORT_VIEW_PROPERTY(onWillFocus, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onDidFocus, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onWillBlur, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onDidBlur, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(transition, RNNativeSceneTransition)
RCT_EXPORT_VIEW_PROPERTY(gestureEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(closing, BOOL)
RCT_EXPORT_VIEW_PROPERTY(translucent, BOOL)
RCT_EXPORT_VIEW_PROPERTY(transparent, BOOL)
RCT_EXPORT_VIEW_PROPERTY(statusBarStyle, UIStatusBarStyle)
RCT_EXPORT_VIEW_PROPERTY(statusBarHidden, BOOL)
RCT_EXPORT_VIEW_PROPERTY(splitFullScreen, BOOL)

// for shadow view
RCT_EXPORT_SHADOW_PROPERTY(splitFullScreen, BOOL)

@end

@implementation RCTConvert (RNNativeSceneManager)

RCT_ENUM_CONVERTER(RNNativeSceneTransition, (@{
    @"default": @(RNNativeSceneTransitionDefault),
    @"none": @(RNNativeSceneTransitionNone),
    @"slideFromTop": @(RNNativeSceneTransitionSlideFormTop),
    @"slideFromRight": @(RNNativeSceneTransitionSlideFormRight),
    @"slideFromBottom": @(RNNativeSceneTransitionSlideFormBottom),
    @"slideFromLeft": @(RNNativeSceneTransitionSlideFormLeft)
}), RNNativeSceneTransitionNone, integerValue)

RCT_ENUM_CONVERTER(UIStatusBarStyle, (@{
    @"default": @(UIStatusBarStyleDefault),
    @"darkContent": @(UIStatusBarStyleDarkContent),
    @"lightContent": @(UIStatusBarStyleLightContent)
        }), UIStatusBarStyleDefault, integerValue)

@end
