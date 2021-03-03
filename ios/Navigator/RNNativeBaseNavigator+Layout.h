//
//  RNNativeBaseNavigator+Layout.h
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/7.
//

#import "RNNativeBaseNavigator.h"

NS_ASSUME_NONNULL_BEGIN

@class RNNativeScene;

@interface RNNativeBaseNavigator (Layout)

- (void)addScene:(RNNativeScene *)scene;

- (void)removeScenesWithRemovedScenes:(NSArray<RNNativeScene *> *)removedScenes nextScenes:(NSArray<RNNativeScene *> *)nextScenes;

@end

NS_ASSUME_NONNULL_END
