//
//  RNNativeModalNavigator.m
//  owl
//
//  Created by Bell Zhong on 2019/10/16.
//  Copyright © 2019 shimo.im. All rights reserved.
//

#import "RNNativeModalNavigator.h"
#import "RNNativeStackScene.h"
#import <React/RCTUIManager.h>

@interface RNNativeModalNavigator()

@property (nonatomic, strong) UIViewController *controller;

@end

@implementation RNNativeModalNavigator

- (instancetype)initWithBridge:(RCTBridge *)bridge {
    _controller = [UIViewController new];
    return [super initWithBridge:bridge viewController:_controller];
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
                    [self presentViewController:presentedViewController parentViewController:scene.controller animated:NO completion:nil];
                    [self presentViewController:scene.controller parentViewController:parentController animated:animated completion:nil];
                }];
            } else {
                [self presentViewController:scene.controller parentViewController:parentController animated:animated completion:nil];
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
                    [self presentViewController:scene.controller.presentedViewController parentViewController:parentViewController animated:NO completion:nil];
                }
            }];
        } else if (scene.controller.parentViewController) {
            [scene.controller removeFromParentViewController];
            [scene.controller.view removeFromSuperview];
        }
    }
}

#pragma mark - Private

- (void)presentViewController:(UIViewController *)viewController parentViewController:(UIViewController *)parentViewController animated: (BOOL)flag completion:(void (^ __nullable)(void))completion {
    
    if ([viewController.view isKindOfClass:[RNNativeStackScene class]]) {
        RNNativeStackScene *scene = (RNNativeStackScene *)viewController.view;
        RNNativePopoverParams *popoverParams = scene.popoverParams;
        if (popoverParams) { // popover
            viewController.modalPresentationStyle = UIModalPresentationPopover;
            [self getSourceView:scene completion:^(UIView *view) {
                RNNativePopoverParams *popoverParams = scene.popoverParams;
                if (!CGRectEqualToRect(CGRectZero, popoverParams.sourceRect)) {
                    viewController.popoverPresentationController.sourceRect = popoverParams.sourceRect;
                }
                viewController.popoverPresentationController.sourceView = view ?: parentViewController.view;
                viewController.popoverPresentationController.permittedArrowDirections = popoverParams.directions;
                if (!CGSizeEqualToSize(CGSizeZero, popoverParams.contentSize)) {
                    viewController.preferredContentSize = popoverParams.contentSize;
                }
                [parentViewController presentViewController:viewController animated:flag completion:completion];
            }];
            return;
        } else {
            parentViewController.definesPresentationContext = !scene.transparent;
            if (scene.transition == RNNativeStackSceneTransitionNone || scene.transition == RNNativeStackSceneTransitionDefault) { // system modal style
                viewController.modalPresentationStyle = scene.transparent ? UIModalPresentationOverCurrentContext : UIModalPresentationCurrentContext;
            } else { // custom modal style
                viewController.modalPresentationStyle = UIModalPresentationCustom;
            }
            [parentViewController presentViewController:viewController animated:flag completion:completion];
        }
    } else {
        [parentViewController presentViewController:viewController animated:flag completion:completion];
    }
}

- (void)getSourceView:(RNNativeStackScene *)screenView completion:(void (^)(UIView *view))completion {
    RNNativePopoverParams *popoverParams = screenView.popoverParams;
    if (popoverParams.sourceViewNativeID) {
        RCTUIManager *uiManager = self.bridge.uiManager;
        [uiManager rootViewForReactTag:screenView.reactTag withCompletion:^(UIView *view) {
            UIView *target = [uiManager viewForNativeID:popoverParams.sourceViewNativeID withRootTag:view.reactTag];
            completion(target);
        }];
    } else {
        completion(nil);
    }
}

@end
