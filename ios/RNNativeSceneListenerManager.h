//
//  RNNativeSceneListenerManager.h
//  react-native-navigators
//
//  Created by Bell Zhong on 2019/12/16.
//

#import <Foundation/Foundation.h>
#import "RNNativeScene.h"

NS_ASSUME_NONNULL_BEGIN

@interface RNNativeSceneListenerManager : NSObject

+ (void)registerListener:(nonnull UIView<RNNativeSceneListener> *)listener;
+ (void)unregisterListener:(nonnull UIView<RNNativeSceneListener> *)listener;

@end

NS_ASSUME_NONNULL_END
