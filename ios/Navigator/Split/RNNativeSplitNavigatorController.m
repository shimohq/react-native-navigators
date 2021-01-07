//
//  RNNativeSplitNavigatorController.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/6.
//

#import "RNNativeSplitNavigatorController.h"
#import "RNNativeScene.h"
#import "RNNativePanGestureRecognizerManager.h"

@interface RNNativeSplitNavigatorController () <UIGestureRecognizerDelegate>

@end

@implementation RNNativeSplitNavigatorController

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
    [self.delegate willLayoutSubviews:self.view.bounds];
}

-(UIViewController *)childViewControllerForStatusBarStyle {
    return [self topSceneController];
}

-(UIViewController *)childViewControllerForStatusBarHidden {
    return [self topSceneController];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    NSArray<RNNativeScene *> *topScenes = [self getTopScenesWithCount:3];
    BOOL split = [self.dataSource isSplit];
    if (topScenes.count < (split ? 3 : 2)) {
        return NO;
    }
    if (!topScenes[0].gestureEnabled) {
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
    NSArray<RNNativeScene *> *topTwoScenes = [self getTopScenesWithCount:2];
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
    [UIView animateWithDuration:RNNativeNavigateDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
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
    [UIView animateWithDuration:RNNativeNavigateDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
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

- (NSArray<RNNativeScene *> *)getTopScenesWithCount:(NSInteger)count {
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
