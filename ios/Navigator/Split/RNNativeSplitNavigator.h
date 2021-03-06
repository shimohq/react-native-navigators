//
//  RNNativeSplitNavigator.h
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/6.
//

#import "RNNativeBaseNavigator.h"

NS_ASSUME_NONNULL_BEGIN

@interface RNNativeSplitNavigator : RNNativeBaseNavigator

@property (nonatomic, strong) NSArray<NSDictionary *> *splitRules;
@property (nonatomic, assign) BOOL splitFullScreen;

/// enable gesture to return when splitFullScreen is enabled. default NO
@property (nonatomic, assign) BOOL enableGestureWhenSplitFullScreen;
@property (nonatomic, strong) UIColor *splitLineColor;

- (instancetype)initWithBridge:(RCTBridge *)bridge;

@end

NS_ASSUME_NONNULL_END
