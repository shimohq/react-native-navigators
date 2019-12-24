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

/// 注册 listener
///
///  弱引用，所以可以不注销
/// @param listener 监听器
+ (void)registerListener:(nonnull UIView<RNNativeSceneListener> *)listener;

/// 注销 listener
///
/// @param listener 监听器
+ (void)unregisterListener:(nonnull UIView<RNNativeSceneListener> *)listener;

@end

NS_ASSUME_NONNULL_END
