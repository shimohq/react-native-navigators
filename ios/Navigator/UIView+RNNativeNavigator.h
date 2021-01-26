//
//  UIView+RNNativeNavigator.h
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (RNNativeNavigator)

- (nullable UIViewController *)rnn_nearestSplitNavigatorController;

@end

NS_ASSUME_NONNULL_END
