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

+ (instancetype)sharedInstance;
- (void)panWithGestureRecognizer:(UIPanGestureRecognizer *)gesture upScene:(RNNativeScene *)upScene downScene:(RNNativeScene *)downScene didGoBack:(void (^)(void))didGoBack;

@end

NS_ASSUME_NONNULL_END
