//
//  RNNativePanGestureHandler.h
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static CGFloat const RNNativePanGestureEdgeWidth = 60;

@class RNNativeScene;

@interface RNNativePanGestureHandler : NSObject

@property (nonatomic, weak) UIView *coverView;
@property (nonatomic, weak) RNNativeScene *firstScene;
@property (nonatomic, weak) RNNativeScene *secondScene;
@property (nonnull, nonatomic, copy) void(^completeBolck)(BOOL goBack);

- (void)panWithGestureRecognizer:(UIPanGestureRecognizer *)gesture;
/**
 滑动手势触发时，取消点击事件
 @see https://github.com/software-mansion/react-native-screens/blob/1a7019be8ad7e62cfa68d3b59b90c103eda66dc4/ios/RNSScreenStack.mm#L578
 */
- (void)cancelTouchesInParent:(UIView *)parent;

@end

NS_ASSUME_NONNULL_END
