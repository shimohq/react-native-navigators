//
//  RNNativeBaseNavigator+Layout.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/7.
//

#import "RNNativeBaseNavigator+Layout.h"
#import "RNNativeSceneController.h"
#import "RNNativeScene.h"

#import "UIView+RNNativeNavigator.h"

@implementation RNNativeBaseNavigator (Layout)

- (void)addScene:(RNNativeScene *)scene {
    UIView *superView = [scene superview];
    if (superView && superView != self.viewController.view) {
        [scene removeFromSuperview];
        superView = nil;
    }
    UIViewController *parentViewController = [scene.controller parentViewController];
    if (parentViewController && parentViewController != self.viewController) {
        [scene.controller removeFromParentViewController];
        parentViewController = nil;
    }
    
    // add view
    if (!parentViewController) {
        [self.viewController addChildViewController:scene.controller];
    }
    if (superView) {
        [self.viewController.view bringSubviewToFront:scene];
    } else {
        [self.viewController.view addSubview:scene];
    }
}

- (void)removeScenesWithRemovedScenes:(NSArray<RNNativeScene *> *)removedScenes nextScenes:(NSArray<RNNativeScene *> *)nextScenes {
    for (RNNativeScene *scene in removedScenes) {
        [self removeScene:scene];
    }
    // 顶部两层 scene 必须显示，否则手势返回不好处理
    for (NSInteger index = 0, size = nextScenes.count; index < size - 2; index++) {
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
