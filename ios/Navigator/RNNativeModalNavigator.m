//
//  RNNativeModalNavigator.m
//  owl
//
//  Created by Bell Zhong on 2019/10/16.
//  Copyright © 2019 shimo.im. All rights reserved.
//

#import "RNNativeModalNavigator.h"
#import "RNNativeStackScene.h"
#import "RNNativeModalNavigatorTransitionManager.h"

#import <React/RCTUIManager.h>

@interface RNNativeModalNavigator()

@property (nonatomic, strong) UIViewController *controller;

@end

@implementation RNNativeModalNavigator {
    NSMutableDictionary *_numberDict;
}

- (instancetype)initWithBridge:(RCTBridge *)bridge {
    _controller = [UIViewController new];
    _numberDict = [NSMutableDictionary new];
    return [super initWithBridge:bridge viewController:_controller];
}


#pragma mark - RNNativeBaseNavigator

- (BOOL)isDismissedForViewController:(UIViewController *)viewController {
    if (!viewController) {
        return NO;
    }
    if ([_controller.childViewControllers containsObject:viewController]) {
        return NO;
    }
    UIViewController *presentingViewController = _controller;
    while (presentingViewController.presentedViewController) {
        if (presentingViewController.presentedViewController == viewController) {
            return YES;
        }
        presentingViewController = presentingViewController.presentedViewController;
    }
    return NO;
}

/**
 present or dismiss
 TODO: 不支持 ViewController 互换位置
 */
- (void)updateSceneWithTransition:(RNNativeStackSceneTransition)transition
                           action:(RNNativeStackNavigatorAction)action
                       nextScenes:(NSArray<RNNativeStackScene *> *)nextScenes
                    removedScenes:(NSArray<RNNativeStackScene *> *)removedScenes
                   insertedScenes:(NSArray<RNNativeStackScene *> *)insertedScenes
                  beginTransition:(RNNativeNavigatorTransitionBlock)beginTransition
                    endTransition:(RNNativeNavigatorTransitionBlock)endTransition {
    beginTransition();
    RNNativeModalNavigatorTransitionManager *transitionManager = [[RNNativeModalNavigatorTransitionManager alloc] init];
    [transitionManager setEndTransition:endTransition];
    [transitionManager increment];
    // show
    for (NSInteger index = 0, size = insertedScenes.count; index < size; index++) {
        RNNativeStackScene *scene = insertedScenes[index];
        NSInteger willShowIndex = [nextScenes indexOfObject:scene];
        if (willShowIndex == 0 || self.currentScenes.count == 0) {
            [self.controller addChildViewController:scene.controller];
            [self.controller.view addSubview:scene.controller.view];
        } else {
            UIViewController *parentController = nextScenes[willShowIndex - 1].controller;
            BOOL animated = action == RNNativeStackNavigatorActionShow && index == size - 1 && transition != RNNativeStackSceneTransitionNone;
            if (parentController.presentedViewController) {
                UIViewController *presentedViewController = parentController.presentedViewController;
                [transitionManager dismissViewController: parentController animated:NO completion:^{
                    [self presentViewController:presentedViewController parentViewController:scene.controller transitionManager:transitionManager animated:NO completion:nil];
                    [self presentViewController:scene.controller parentViewController:parentController transitionManager:transitionManager animated:animated completion:nil];
                }];
            } else {
                [self presentViewController:scene.controller parentViewController:parentController transitionManager:transitionManager animated:animated completion:nil];
            }
        }
    }
    
    // hide
    for (NSInteger index = 0, size = removedScenes.count; index < size; index++) {
        RNNativeStackScene *scene = removedScenes[index];
        BOOL animated = action == RNNativeStackNavigatorActionHide && index == size - 1 && transition != RNNativeStackSceneTransitionNone;
        UIViewController *parentViewController = scene.controller.presentingViewController;
        if (parentViewController) {
            [transitionManager dismissViewController:parentViewController animated:animated completion:^{
                if (scene.controller.presentedViewController) {
                    [self presentViewController:scene.controller.presentedViewController parentViewController:parentViewController transitionManager:transitionManager animated:NO completion:nil];
                }
            }];
        } else if (scene.controller.parentViewController) {
            [scene.controller removeFromParentViewController];
            [scene.controller.view removeFromSuperview];
        }
    }
    [transitionManager decreaseAndHandleEndTransition];
}

#pragma mark - Private

- (void)presentViewController:(UIViewController *)viewController
         parentViewController:(UIViewController *)parentViewController
            transitionManager:(RNNativeModalNavigatorTransitionManager *)transitionManager
                     animated:(BOOL)animated
                   completion:(void (^ __nullable)(void))completion {
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
                [transitionManager presentViewController:viewController parentViewController:parentViewController animated:animated completion:completion];
            }];
            return;
        } else {
            parentViewController.definesPresentationContext = !scene.transparent;
            if (scene.transition == RNNativeStackSceneTransitionNone || scene.transition == RNNativeStackSceneTransitionDefault) { // system modal style
                viewController.modalPresentationStyle = scene.transparent ? UIModalPresentationOverCurrentContext : UIModalPresentationCurrentContext;
            } else { // custom modal style
                viewController.modalPresentationStyle = UIModalPresentationCustom;
            }
            [transitionManager presentViewController:viewController parentViewController:parentViewController animated:animated completion:completion];
        }
    } else {
        [transitionManager presentViewController:viewController parentViewController:parentViewController animated:animated completion:completion];
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
