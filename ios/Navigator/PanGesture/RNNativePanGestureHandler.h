//
//  RNNativePanGestureHandler.h
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RNNativeScene;

@interface RNNativePanGestureHandler : NSObject

@property (nonatomic, weak) UIView *coverView;
@property (nonatomic, weak) RNNativeScene *firstScene;
@property (nonatomic, weak) RNNativeScene *secondScene;

- (void)panWithGestureRecognizer:(UIPanGestureRecognizer *)gesture;

@end

NS_ASSUME_NONNULL_END
