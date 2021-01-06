//
//  RNNativeCardNavigatorController.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2019/11/12.
//

#import "RNNativeCardNavigatorController.h"
#import "RNNativeScene.h"
#import "RNNativePanGestureHandler.h"
#import "RNNativePanGestureRecognizerManager.h"

@interface RNNativeCardNavigatorController () <UIGestureRecognizerDelegate>

@end

@implementation RNNativeCardNavigatorController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panWithGestureRecognizer:)];
    panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    [[RNNativePanGestureRecognizerManager sharedInstance] addPanGestureRecognizer:panGestureRecognizer];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // INFO: 切换 viewController 的同时旋转屏幕，新的 viewController 可能也会保持屏幕旋转之前的 frame。
    // 为了修复这个问题，重新布局的时候重新设置 frame。
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[RNNativeScene class]]) {
            [self updateFrameWithView:view parentView:self.view];
        }
    }
}

-(UIViewController *)childViewControllerForStatusBarStyle {
    return [self topSceneController];
}

-(UIViewController *)childViewControllerForStatusBarHidden {
    return [self topSceneController];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    NSArray<RNNativeScene *> *topTwoScenes = [self topTwoScenes];
    if (topTwoScenes.count < 2 || !topTwoScenes[0].gestureEnabled) {
        return NO;
    }
    CGPoint location = [gestureRecognizer locationInView:self.view];
    if (location.x > 120) {
        return NO;
    }
    return YES;
}

#pragma mark - UIPanGestureRecognizer - Action

- (void)panWithGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    NSArray<RNNativeScene *> *topTwoScenes = [self topTwoScenes];
    if (topTwoScenes.count < 2) {
        return;
    }
    RNNativeScene *upScene = topTwoScenes[0];
    RNNativeScene *downScene = topTwoScenes[1];
    
    CGPoint point = [gesture translationInView:gesture.view];
    [gesture setTranslation:CGPointZero inView:gesture.view];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [upScene.controller viewWillDisappear:YES];
        [downScene.controller viewWillAppear:YES];
        
        CGRect downFrame = downScene.frame;
        downFrame.origin.x = - CGRectGetWidth(downFrame) / 3.0;
        downScene.frame = downFrame;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        // up scene
        CGRect upFrame = upScene.frame;
        upFrame.origin.x += point.x;
        upScene.frame = upFrame;
        
        // down scene
        CGRect downFrame = downScene.frame;
        downFrame.origin.x += point.x / 3.0;
        downScene.frame = downFrame;
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity =[gesture velocityInView:gesture.view];
        BOOL success;
        if (velocity.x > 500) {
            success = YES;
        } else if (velocity.x < -500) {
            success = NO;
        } else {
            CGRect frame = upScene.frame;
            success = CGRectGetMinX(frame) + point.x >= CGRectGetWidth(frame) / 2.0;
        }
        if (success) {
            [self goBackWithUpScene:upScene downScene:downScene];
        } else {
            [self cancelGoBackWithUpScene:upScene downScene:downScene];
        }
    } else if (gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed) {
        [self cancelGoBackWithUpScene:upScene downScene:downScene];
    }
}

#pragma mark - Private

- (void)goBackWithUpScene:(RNNativeScene *)upScene downScene:(RNNativeScene *)downScene {
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        // up scene
        CGRect upSceneFrame = upScene.frame;
        upSceneFrame.origin.x = CGRectGetWidth(upSceneFrame);
        upScene.frame = upSceneFrame;
        
        // down scene
        CGRect downSceneFrame = downScene.frame;
        downSceneFrame.origin.x = 0;
        downScene.frame = downSceneFrame;
    } completion:^(BOOL finished) {
        [self.delegate didRemoveController:upScene.controller];
        
        [upScene removeFromSuperview];
        [upScene.controller removeFromParentViewController];
        [upScene.controller viewDidDisappear:YES];
        
        [downScene.controller viewDidAppear:YES];
    }];
}

- (void)cancelGoBackWithUpScene:(RNNativeScene *)upScene downScene:(RNNativeScene *)downScene {
    [upScene.controller viewWillAppear:YES];
    [downScene.controller viewWillDisappear:YES];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        upScene.frame = self.view.frame;
        
        CGRect downFrame = downScene.frame;
        downFrame.origin.x = - CGRectGetWidth(downFrame) / 3.0;
        downScene.frame = downFrame;
    } completion:^(BOOL finished) {
        downScene.frame = self.view.frame;
        
        [upScene.controller viewDidAppear:YES];
        [downScene.controller viewDidDisappear:YES];
    }];
}

- (void)updateFrameWithView:(UIView *)view parentView:(UIView *)parentView {
    CGRect parentFrame = parentView.frame;
    CGRect frame = view.frame;
    if (!CGRectEqualToRect(frame, parentFrame)) {
        view.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(parentFrame), CGRectGetHeight(parentFrame));
    }
}

- (RNNativeSceneController *)topSceneController {
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

- (NSArray<RNNativeScene *> *)topTwoScenes {
    NSMutableArray<RNNativeScene *> *topTwoScenes = [NSMutableArray array];
    NSArray *subviews = [self.view subviews];
    for (NSInteger index = 0, size = subviews.count; index < size; index++) {
        UIView *view = subviews[size - index - 1];
        if ([view isKindOfClass:[RNNativeScene class]]) {
            RNNativeScene *scene = (RNNativeScene *)view;
            [topTwoScenes addObject:scene];
            if (topTwoScenes.count >= 2) {
                break;
            }
        }
    }
    return topTwoScenes;
}

@end
