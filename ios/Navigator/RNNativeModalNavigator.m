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
    NSNumber *key = [NSNumber numberWithDouble:[[[NSDate alloc] init] timeIntervalSince1970]];
    [self incrementNumberWithKey:key];
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
                [self dismissViewController: parentController key:key animated:NO completion:^{
                    [self presentViewController:presentedViewController parentViewController:scene.controller key:key animated:NO completion:nil endTransition:endTransition];
                    [self presentViewController:scene.controller parentViewController:parentController key:key animated:animated completion:nil endTransition:endTransition];
                } endTransition:endTransition];
            } else {
                [self presentViewController:scene.controller parentViewController:parentController key:key animated:animated completion:nil endTransition:endTransition];
            }
        }
    }
    
    // hide
    for (NSInteger index = 0, size = removedScenes.count; index < size; index++) {
        RNNativeStackScene *scene = removedScenes[index];
        BOOL animated = action == RNNativeStackNavigatorActionHide && index == size - 1 && transition != RNNativeStackSceneTransitionNone;
        UIViewController *parentViewController = scene.controller.presentingViewController;
        if (parentViewController) {
            [self dismissViewController:parentViewController key:key animated:animated completion:^{
                if (scene.controller.presentedViewController) {
                    [self presentViewController:scene.controller.presentedViewController parentViewController:parentViewController key:key animated:NO completion:nil endTransition:endTransition];
                }
            } endTransition:endTransition];
        } else if (scene.controller.parentViewController) {
            [scene.controller removeFromParentViewController];
            [scene.controller.view removeFromSuperview];
        }
    }
    [self decreaseAndHandleEndTransition:endTransition withKey:key];
}

#pragma mark - Present And Dismiss

- (void)presentViewController:(UIViewController *)viewController
         parentViewController:(UIViewController *)parentViewController
                          key:(NSNumber *)key
                     animated:(BOOL)animated
                   completion:(void (^ __nullable)(void))completion
                endTransition:(RNNativeNavigatorTransitionBlock)endTransition {
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
                [self customPresentViewController:viewController parentViewController:parentViewController key:key animated:animated completion:completion endTransition:endTransition];
            }];
            return;
        } else {
            parentViewController.definesPresentationContext = !scene.transparent;
            if (scene.transition == RNNativeStackSceneTransitionNone || scene.transition == RNNativeStackSceneTransitionDefault) { // system modal style
                viewController.modalPresentationStyle = scene.transparent ? UIModalPresentationOverCurrentContext : UIModalPresentationCurrentContext;
            } else { // custom modal style
                viewController.modalPresentationStyle = UIModalPresentationCustom;
            }
            [self customPresentViewController:viewController parentViewController:parentViewController key:key animated:animated completion:completion endTransition:endTransition];
        }
    } else {
        [self customPresentViewController:viewController parentViewController:parentViewController key:key animated:animated completion:completion endTransition:endTransition];
    }
}

- (void)customPresentViewController:(UIViewController *)viewController
               parentViewController:(UIViewController *)parentViewController
                                key:(NSNumber *)key
                           animated:(BOOL)animated
                         completion:(void (^ __nullable)(void))completion
                      endTransition:(RNNativeNavigatorTransitionBlock)endTransition {
    [self incrementNumberWithKey:key];
    [parentViewController presentViewController:viewController animated:animated completion:^{
        if (completion) {
            completion();
        }
        [self decreaseAndHandleEndTransition:endTransition withKey:key];
    }];
}

- (void)dismissViewController:(UIViewController *)viewController
                          key:(NSNumber *)key
                     animated:(BOOL)animated
                   completion:(void (^ __nullable)(void))completion
                endTransition:(RNNativeNavigatorTransitionBlock)endTransition {
    [self incrementNumberWithKey:key];
    [viewController dismissViewControllerAnimated:animated completion:^{
        if (completion) {
            completion();
        }
        [self decreaseAndHandleEndTransition:endTransition withKey:key];
    }];
}

#pragma mark - Number Manager

- (void)decreaseAndHandleEndTransition:(RNNativeNavigatorTransitionBlock)endTransition withKey:(NSNumber *)key {
    NSInteger number = [self decreaseNumberWithKey:key];
    if (number <= 0) {
        [_numberDict removeObjectForKey:key];
        endTransition();
    }
}

- (NSInteger)decreaseNumberWithKey:(NSNumber *)key {
    NSInteger number = [self getNumberWithKey:key];
    number--;
    [_numberDict setObject:[NSNumber numberWithInteger:number] forKey:key];
    return number;
}

- (NSInteger)incrementNumberWithKey:(NSNumber *)key {
    NSInteger number = [self getNumberWithKey:key];
    number++;
    [_numberDict setObject:[NSNumber numberWithInteger:number] forKey:key];
    return number;
}

- (NSInteger)getNumberWithKey:(NSNumber *)key {
    NSNumber *number = [_numberDict objectForKey:key];
    if (!number) {
        number = [NSNumber numberWithInteger:0];
        [_numberDict setObject:number forKey:key];
    }
    return [number integerValue];
}

#pragma mark - Private

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
