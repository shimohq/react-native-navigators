//
//  RNNativePanGestureHandler.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/7.
//

#import "RNNativePanGestureHandler.h"
#import "RNNativeScene.h"

@implementation RNNativePanGestureHandler

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)panWithGestureRecognizer:(UIPanGestureRecognizer *)gesture upScene:(RNNativeScene *)upScene downScene:(RNNativeScene *)downScene didGoBack:(void (^)(void))didGoBack {
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
            [self goBackWithUpScene:upScene downScene:downScene didGoBack:didGoBack];
        } else {
            [self cancelGoBackWithUpScene:upScene downScene:downScene];
        }
    } else if (gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed) {
        [self cancelGoBackWithUpScene:upScene downScene:downScene];
    }
}

#pragma mark - Private

- (void)goBackWithUpScene:(RNNativeScene *)upScene downScene:(RNNativeScene *)downScene didGoBack:(void (^)(void))didGoBack {
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
        if (didGoBack) {
            didGoBack();
        }
        
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
        // up scene
        CGRect upSceneFrame = upScene.frame;
        upSceneFrame.origin.x = 0;
        upScene.frame = upSceneFrame;
        
        // down scene
        CGRect downFrame = downScene.frame;
        downFrame.origin.x = - CGRectGetWidth(downFrame) / 3.0;
        downScene.frame = downFrame;
    } completion:^(BOOL finished) {
        // down scene
        CGRect downFrame = downScene.frame;
        downFrame.origin.x = 0;
        downScene.frame = downFrame;
        
        [upScene.controller viewDidAppear:YES];
        [downScene.controller viewDidDisappear:YES];
    }];
}

@end
