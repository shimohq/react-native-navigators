#import <React/RCTShadowView.h>

@class RNNativeSceneShadowView;

@protocol RNNativeSceneShadowViewDelegate <NSObject>

- (void)didSplitPrimaryChanged:(RNNativeSceneShadowView *)sceneShadowView;

@end

@interface RNNativeSceneShadowView : RCTShadowView

/**
 分屏模式是否显示在左边的主屏幕
 */
@property (nonatomic, assign) BOOL splitPrimary;

/**
 Whether in StackNavigator
 */
@property (nonatomic, assign) BOOL inStack;

/**
 scene 顶部距 window 顶部距离
 
 超过状态栏高度时，header 不预留状态栏高度
 */
@property (nonatomic, assign) CGFloat topToWindow;

@property (nonatomic, weak) id<RNNativeSceneShadowViewDelegate> delegate;

- (instancetype)initWithHeaderHeight:(CGFloat)headerHeight headerTop:(CGFloat)headerTop;

@end
