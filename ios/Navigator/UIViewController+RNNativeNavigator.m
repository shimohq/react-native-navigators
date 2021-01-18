//
//  UIViewController+RNNativeNavigator.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/7.
//

#import "UIViewController+RNNativeNavigator.h"
#import "RNNativeSceneController.h"
#import "RNNativeScene.h"

@implementation UIViewController (RNNativeNavigator)

- (RNNativeSceneController *)rnn_topSceneController {
    NSArray *subviews = [self.view subviews];
    for (NSInteger index = 0, size = subviews.count; index < size; index++) {
        UIView *view = subviews[size - index - 1];
        if ([view isKindOfClass:[RNNativeScene class]]) {
            RNNativeScene *scene = (RNNativeScene *)view;
            return scene.controller;
        }
    }
    return nil;
}

- (RNNativeScene *)rnn_firstScene {
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[RNNativeScene class]]) {
            return (RNNativeScene *)view;
        }
    }
    return nil;
}

- (NSArray<RNNativeScene *> *)rnn_getTopScenesWithCount:(NSInteger)count {
    NSMutableArray<RNNativeScene *> *topScenes = [NSMutableArray array];
    if (count <= 0) {
        return topScenes;
    }
    NSArray *subviews = [self.view subviews];
    for (NSInteger index = 0, size = subviews.count; index < size; index++) {
        UIView *view = subviews[size - index - 1];
        if ([view isKindOfClass:[RNNativeScene class]]) {
            RNNativeScene *scene = (RNNativeScene *)view;
            [topScenes addObject:scene];
            if (topScenes.count >= count) {
                break;
            }
        }
    }
    return topScenes;
}

@end
