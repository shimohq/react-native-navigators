//
//  RNNativeCardNavigatorShadowView.h
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/25.
//

#import "RCTShadowView.h"

NS_ASSUME_NONNULL_BEGIN

@class RNNativeSceneShadowView;

@interface RNNativeCardNavigatorShadowView : RCTShadowView

- (instancetype)initWithBridge:(RCTBridge *)bridge;

- (void)updateShadowView:(RNNativeSceneShadowView *)shadowView;

@end

NS_ASSUME_NONNULL_END
