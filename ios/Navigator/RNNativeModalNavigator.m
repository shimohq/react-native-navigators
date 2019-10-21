//
//  RNNativeModalNavigator.m
//  owl
//
//  Created by Bell Zhong on 2019/10/16.
//  Copyright © 2019 shimo.im. All rights reserved.
//

#import "RNNativeModalNavigator.h"
#import "RNNativeStackScene.h"

@interface RNNativeModalNavigator()

@property (nonatomic, strong) UIViewController *controller;

@end

@implementation RNNativeModalNavigator

- (instancetype)init
{
    _controller = [UIViewController new];
    return [super initWithViewController:_controller];
}

#pragma mark - RNNativeBaseNavigator

/**
 present or dismiss
 TODO: 不支持 ViewController 互换位置
 */
- (void)updateSceneWithTransition:(RNNativeStackSceneTransition)transition
                           action:(RNNativeStackNavigatorAction)action
                      nextScrenes:(NSArray<RNNativeStackScene *> *)nextScrenes
                    removedScenes:(NSMutableArray<RNNativeStackScene *> *)removedScenes
                   insertedScenes:(NSMutableArray<RNNativeStackScene *> *)insertedScenes {
    // show
    for (NSInteger index = 0, size = insertedScenes.count; index < size; index++) {
        RNNativeStackScene *scene = insertedScenes[index];
        scene.controller.modalPresentationStyle = UIModalPresentationCustom;
        
        NSInteger willShowIndex = [nextScrenes indexOfObject:scene];
        if (willShowIndex == 0 || self.currentScenes.count == 0) {
            [self.controller addChildViewController:scene.controller];
            [self.controller.view addSubview:scene.controller.view];
            
        } else {
            UIViewController *parentController = nextScrenes[willShowIndex - 1].controller;
            BOOL animated = action == RNNativeStackNavigatorActionShow && index == size - 1 && transition != RNNativeStackSceneTransitionNone;
            if (parentController.presentedViewController) {
                UIViewController *presentedViewController = parentController.presentedViewController;
                [parentController dismissViewControllerAnimated:NO completion:^{
                    [scene.controller presentViewController:presentedViewController animated:NO completion:nil];
                    [parentController presentViewController:scene.controller animated:animated completion:nil];
                }];
            } else {
                [parentController presentViewController:scene.controller animated:animated completion:nil];
            }
        }
    }
    
    // hide
    for (NSInteger index = 0, size = removedScenes.count; index < size; index++) {
        RNNativeStackScene *scene = removedScenes[index];
        BOOL animated = action == RNNativeStackNavigatorActionHide && index == size - 1 && transition != RNNativeStackSceneTransitionNone;
        UIViewController *parentViewController = scene.controller.presentingViewController;
        if (parentViewController) {
            [parentViewController dismissViewControllerAnimated:animated completion:^{
                if (scene.controller.presentedViewController) {
                    [parentViewController presentViewController:scene.controller.presentedViewController animated:NO completion:nil];
                }
            }];
        } else if (scene.controller.parentViewController) {
            [scene.controller removeFromParentViewController];
            [scene.controller.view removeFromSuperview];
        }
    }
}

/**
 自定义 push pop 动画
 TODO: 暂时使用系统动画
 */
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    return nil;
}

@end
