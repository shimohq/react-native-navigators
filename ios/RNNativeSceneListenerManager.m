//
//  RNNativeSceneListenerManager.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2019/12/16.
//

#import "RNNativeSceneListenerManager.h"

@implementation RNNativeSceneListenerManager

+ (void)registerListener:(nonnull UIView<RNNativeSceneListener> *)listener {
    RNNativeScene *oldScene = [[self sceneMap] objectForKey:listener];
    RNNativeScene *newScene = [self findSceneForView:listener];
    if (newScene != oldScene) {
        if (oldScene) {
            [oldScene unregisterListener:listener];
        }
        [[self sceneMap] setObject:newScene forKey:listener];
        if (newScene) {
            [newScene registerListener:listener];
        }
    }
}

+ (void)unregisterListener:(nonnull UIView<RNNativeSceneListener> *)listener {
    RNNativeScene *scene = [[self sceneMap] objectForKey:listener];
    if (scene) {
        [scene unregisterListener:listener];
        [[self sceneMap] removeObjectForKey:listener];
    }
}

#pragma mark - Private

+ (NSMapTable *)sceneMap {
    static NSMapTable *__sceneMap;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sceneMap = [NSMapTable weakToWeakObjectsMapTable];
    });
    return __sceneMap;
}

+ (RNNativeScene *)findSceneForView:(UIView *)view {
    UIView *targetView = view.superview;
    while (targetView && ![targetView isKindOfClass:[RNNativeScene class]]) {
        targetView = targetView.superview;
    }
    return (RNNativeScene *)targetView;
}

@end
