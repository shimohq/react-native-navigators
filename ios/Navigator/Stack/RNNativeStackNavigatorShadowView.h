//
//  RNNativeStackNavigatorShadowView.h
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/14.
//

#import <React/RCTShadowView.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNNativeStackNavigatorShadowView : RCTShadowView

- (instancetype)initWithHeaderHeight:(CGFloat)headerHeight headerTop:(CGFloat)headerTop;

@end

NS_ASSUME_NONNULL_END
