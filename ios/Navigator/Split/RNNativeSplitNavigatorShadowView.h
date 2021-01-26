//
//  RNNativeSplitNavigatorShadowView.h
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/14.
//

#import <React/RCTShadowView.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNNativeSplitNavigatorShadowView : RCTShadowView

@property (nonatomic, strong) NSArray<NSDictionary *> *splitRules;

- (instancetype)initWithBridge:(RCTBridge *)bridge;

@end

NS_ASSUME_NONNULL_END
