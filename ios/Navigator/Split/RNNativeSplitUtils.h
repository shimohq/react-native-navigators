//
//  RNNativeSplitUtils.h
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/14.
//

#import <Foundation/Foundation.h>
#import "RNNativeSplitRule.h"

NS_ASSUME_NONNULL_BEGIN

@interface RNNativeSplitUtils : NSObject

+ (NSArray<RNNativeSplitRule *> *)parseSplitRules:(NSArray<NSDictionary *> *)splitRules;
+ (CGFloat)getPrimarySceneWidthWithRules:(NSArray<RNNativeSplitRule *> *)rules navigatorWidth:(CGFloat)navigatorWidth;

@end

NS_ASSUME_NONNULL_END
