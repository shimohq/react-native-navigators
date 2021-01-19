#import <React/RCTShadowView.h>

@class RNNativeSceneShadowView;

@interface RNNativeSceneShadowView : RCTShadowView

/**
 分屏模式是否全屏显示
 */
@property (nonatomic, assign) BOOL splitFullScreen;

/**
 Whether in StackNavigator
 */
@property (nonatomic, assign) BOOL inStack;

- (instancetype)initWithHeaderHeight:(CGFloat)headerHeight headerTop:(CGFloat)headerTop;

@end
