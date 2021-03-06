#import "RNNativeSceneManager.h"
#import "RNNativeScene.h"
#import "RNNativeSceneShadowView.h"

@interface RNNativeSceneManager()

@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat headerTop;

@end

@implementation RNNativeSceneManager


RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        UINavigationController *navigationController = [[UINavigationController alloc] init];
        CGRect frame = navigationController.navigationBar.frame;
        _headerHeight = CGRectGetHeight(frame);
        if (@available(iOS 11.0, *)) {
            _headerTop = [UIApplication sharedApplication].delegate.window.rootViewController.view.safeAreaInsets.top;
        } else {
            _headerTop = [UIApplication sharedApplication].statusBarFrame.size.height;
        }
    }
    return self;
}

- (UIView *)view {
  return [[RNNativeScene alloc] initWithBridge:self.bridge];
}

- (RCTShadowView *)shadowView {
  return [[RNNativeSceneShadowView alloc] initWithHeaderHeight:_headerHeight headerTop:_headerTop];
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

RCT_REMAP_VIEW_PROPERTY(isSplitPrimary, splitPrimary, BOOL)

// for shadow view
RCT_REMAP_SHADOW_PROPERTY(isSplitPrimary, splitPrimary, BOOL)

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
