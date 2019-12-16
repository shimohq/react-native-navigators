#import "RNNativeStackHeaderItem.h"

@implementation RNNativeStackHeaderItem

@end

@implementation RCTConvert (RNNativeScene)

RCT_ENUM_CONVERTER(RNNativeStackHeaderType, (@{
                    @"center": @(RNNativeStackHeaderTypeCenter),
                    @"left": @(RNNativeStackHeaderTypeLeft),
                    @"right": @(RNNativeStackHeaderTypeRight)
}), RNNativeStackHeaderTypeCenter, integerValue)

@end
