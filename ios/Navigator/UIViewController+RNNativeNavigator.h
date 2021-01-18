//
//  UIViewController+RNNativeNavigator.h
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RNNativeSceneController;
@class RNNativeScene;

@interface UIViewController (RNNativeNavigator)

- (RNNativeSceneController *)rnn_topSceneController;
- (RNNativeScene *)rnn_firstScene;
- (NSArray<RNNativeScene *> *)rnn_getTopScenesWithCount:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
