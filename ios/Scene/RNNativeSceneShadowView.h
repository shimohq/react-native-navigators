#import <React/RCTShadowView.h>
#import "RNNativeConst.h"

@class RNNativeSceneShadowView;

@protocol RNNativeSceneShadowViewDelegate <NSObject>

- (void)didHeaderUpdated:(RNNativeSceneShadowView *)shadow;

@end

@interface RNNativeSceneShadowView : RCTShadowView

/**
 分屏模式是否全屏显示
 */
@property (nonatomic, assign) BOOL splitFullScreen;

@property (nonatomic, assign) RNNativeSceneStatus status;

- (void)updateWithHeaderTop:(CGFloat)headerTop headerHeight:(CGFloat)headerHeight;

@end
