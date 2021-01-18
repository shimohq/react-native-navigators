//
//  RNNativeSplitPlaceholderManager.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/7.
//

#import "RNNativeSplitPlaceholderManager.h"
#import "RNNativeSplitPlaceholder.h"
#import "RNNativeSplitPlaceholderShadowView.h"

@implementation RNNativeSplitPlaceholderManager

RCT_EXPORT_MODULE()

- (UIView *)view {
    return [RNNativeSplitPlaceholder new];
}

- (RCTShadowView *)shadowView
{
  return [RNNativeSplitPlaceholderShadowView new];
}

@end
