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

- (instancetype)initWithBridge:(RCTBridge *)bridge;

@end

NS_ASSUME_NONNULL_END
