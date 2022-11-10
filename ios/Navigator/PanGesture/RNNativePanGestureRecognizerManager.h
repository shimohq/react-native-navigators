//
//  RNNativePanGestureRecognizerManager.h
//  react-native-navigators
//
//  Created by Bell Zhong on 2020/12/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNNativePanGestureRecognizerManager : NSObject

+ (instancetype)sharedInstance;

- (void)addPanGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer;
- (NSArray<UIPanGestureRecognizer *> *)getAllPanGestureRecognizers;

/**
 滑动手势触发时，取消点击事件
 @see https://github.com/software-mansion/react-native-screens/blob/1a7019be8ad7e62cfa68d3b59b90c103eda66dc4/ios/RNSScreenStack.mm#L578
 */
- (void)cancelTouchesInParent:(UIView *)parent;

@end

NS_ASSUME_NONNULL_END
