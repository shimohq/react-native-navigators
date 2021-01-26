//
//  RNNativeBaseNavigator+Layout.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/7.
//

#import "RNNativeBaseNavigator+Layout.h"
#import "RNNativeSceneController.h"
#import "RNNativeScene.h"
#import "RNNativeSplitNavigator.h"

#import "UIView+RNNativeNavigator.h"

@implementation RNNativeBaseNavigator (Layout)

- (void)addScene:(RNNativeScene *)scene {
    [self addScene:scene index:0 split:NO primarySceneWidth:0];
}

- (void)addScene:(RNNativeScene *)scene index:(NSInteger)index split:(BOOL)split primarySceneWidth:(CGFloat)primarySceneWidth {
    UIViewController *targetViewController;
    if (scene.splitFullScreen) {
        targetViewController = [self rnn_nearestSplitNavigatorController] ?: self.viewController;
    } else {
        targetViewController = self.viewController;
    }
    
    UIView *superView = [scene superview];
    if (superView && superView != targetViewController.view) {
        [scene removeFromSuperview];
        superView = nil;
    }
    
    UIViewController *parentViewController = [scene.controller parentViewController];
    if (parentViewController && parentViewController != targetViewController) {
        [scene.controller removeFromParentViewController];
        parentViewController = nil;
    }
    
    // add view
    if (!parentViewController) {
        [targetViewController addChildViewController:scene.controller];
    }
    
    if (superView) {
        [targetViewController.view bringSubviewToFront:scene];
    } else {
        [targetViewController.view addSubview:scene];
    }
}

- (void)removeScenesWithRemovedScenes:(NSArray<RNNativeScene *> *)removedScenes nextScenes:(NSArray<RNNativeScene *> *)nextScenes {
    [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes split:NO];
}

- (void)removeScenesWithRemovedScenes:(NSArray<RNNativeScene *> *)removedScenes nextScenes:(NSArray<RNNativeScene *> *)nextScenes split:(BOOL)split {
    for (RNNativeScene *scene in removedScenes) {
        [self removeScene:scene];
    }
    // 顶部两层 scene 必须显示，否则手势返回不好处理
    for (NSInteger index = 0, size = nextScenes.count; index < size - 2; index++) {
        // 分屏状态第一页必须显示
        if (split && index == 0) {
            continue;
        }
        RNNativeScene *scene = nextScenes[index];
        RNNativeScene *nextScene = nextScenes[index + 1];
        if (!nextScene.transparent) { // 上层 scene 不透明时移除
            [self removeScene:scene];
        }
    }
}

#pragma mark - Private

- (void)removeScene:(RNNativeScene *)scene {
    [scene removeFromSuperview];
    [scene.controller removeFromParentViewController];
}

- (void)removeScenes:(NSArray<RNNativeScene *> *)scenes {
    for (RNNativeScene *scene in scenes) {
        [self removeScene:scene];
    }
}

@end
