//
//  RNNativePanGestureHandler.h
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^RNNativePanGestureHandlerDidGoBackBlock)(void);

@class RNNativeScene;

@interface RNNativePanGestureHandler : NSObject

/**
 only for split mode
 */
@property (nonatomic, weak) RNNativeScene *primaryScene;
@property (nonatomic, weak) RNNativeScene *firstScene;
@property (nonatomic, weak) RNNativeScene *secondScene;
@property (nonatomic, copy) RNNativePanGestureHandlerDidGoBackBlock didGoBack;

- (void)panWithGestureRecognizer:(UIPanGestureRecognizer *)gesture;

@end

NS_ASSUME_NONNULL_END
