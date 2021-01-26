#import <React/RCTShadowView.h>

@class RNNativeSceneShadowView;

@protocol RNNativeSceneShadowViewDelegate <NSObject>

- (void)didSplitFullScrennChanged:(RNNativeSceneShadowView *)sceneShadowView;

@end

@interface RNNativeSceneShadowView : RCTShadowView

/**
 分屏模式是否全屏显示
 */
@property (nonatomic, assign) BOOL splitFullScreen;

/**
 Whether in StackNavigator
 */
@property (nonatomic, assign) BOOL inStack;

@property (nonatomic, weak) id<RNNativeSceneShadowViewDelegate> delegate;

- (instancetype)initWithHeaderHeight:(CGFloat)headerHeight headerTop:(CGFloat)headerTop;

@end
