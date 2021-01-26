//
//  UIView+RNNativeNavigator.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/21.
//

#import "UIView+RNNativeNavigator.h"
#import "RNNativeSplitNavigator.h"

@implementation UIView (RNNativeNavigator)

- (nullable UIViewController *)rnn_nearestSplitNavigatorController {
    if ([self isKindOfClass:[RNNativeSplitNavigator class]]) {
        RNNativeSplitNavigator *splitNavigator = (RNNativeSplitNavigator *)self;
        return splitNavigator.viewController;
    }
    return [self.superview rnn_nearestSplitNavigatorController];
}

@end
