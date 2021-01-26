//
//  RNNativePanGestureHandler.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/7.
//

#import "RNNativePanGestureHandler.h"
#import "RNNativeScene.h"

@interface RNNativePanGestureHandler()

@property (nonatomic, assign) CGFloat beginX;

@end

@implementation RNNativePanGestureHandler

- (void)panWithGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    CGPoint point = [gesture translationInView:gesture.view];
    [gesture setTranslation:CGPointZero inView:gesture.view];

    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.beginX = CGRectGetMinX(self.firstScene.frame);
        
        if (self.primaryScene) {
            [self.primaryScene.superview bringSubviewToFront:self.primaryScene];
        }
        
        [self.firstScene setStatus:RNNativeSceneStatusWillBlur];
        [self.secondScene setStatus:RNNativeSceneStatusWillFocus];
        
        CGRect downFrame = self.secondScene.frame;
        downFrame.origin.x = self.beginX - CGRectGetWidth(downFrame) / 3.0;
        self.secondScene.frame = downFrame;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        // up scene
        CGRect upFrame = self.firstScene.frame;
        upFrame.origin.x += point.x;
        self.firstScene.frame = upFrame;
        
        // down scene
        CGRect downFrame = self.secondScene.frame;
        downFrame.origin.x += point.x / 3.0;
        self.secondScene.frame = downFrame;
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity =[gesture velocityInView:gesture.view];
        BOOL success;
        if (velocity.x > 500) {
            success = YES;
        } else if (velocity.x < -500) {
            success = NO;
        } else {
            CGRect frame = self.firstScene.frame;
            success = CGRectGetMinX(frame) + point.x >= self.beginX + CGRectGetWidth(frame) / 2.0;
        }
        if (success) {
            [self goBack];
        } else {
            [self cancelGoBack];
        }
    } else if (gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed) {
        [self cancelGoBack];
    }
}

#pragma mark - Private

- (void)goBack {
    [UIView animateWithDuration:RNNativeNavigateDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        // up scene
        CGRect upSceneFrame = self.firstScene.frame;
        upSceneFrame.origin.x = self.beginX + CGRectGetWidth(upSceneFrame);
        self.firstScene.frame = upSceneFrame;
        
        // down scene
        CGRect downSceneFrame = self.secondScene.frame;
        downSceneFrame.origin.x = self.beginX;
        self.secondScene.frame = downSceneFrame;
    } completion:^(BOOL finished) {
        if (self.didGoBack) {
            self.didGoBack();
        }
        
        [self.firstScene removeFromSuperview];
        [self.firstScene.controller removeFromParentViewController];
        [self.firstScene setStatus:RNNativeSceneStatusDidBlur];
        
        [self.secondScene setStatus:RNNativeSceneStatusDidFocus];
        
        if (self.primaryScene) {
            [self.primaryScene.superview sendSubviewToBack:self.primaryScene];
        }
    }];
}

- (void)cancelGoBack {
    [self.firstScene setStatus:RNNativeSceneStatusWillFocus];
    [self.secondScene setStatus:RNNativeSceneStatusWillBlur];
    
    [UIView animateWithDuration:RNNativeNavigateDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        // up scene
        CGRect upSceneFrame = self.firstScene.frame;
        upSceneFrame.origin.x = self.beginX;
        self.firstScene.frame = upSceneFrame;
        
        // down scene
        CGRect downFrame = self.secondScene.frame;
        downFrame.origin.x = self.beginX - CGRectGetWidth(downFrame) / 3.0;
        self.secondScene.frame = downFrame;
    } completion:^(BOOL finished) {
        // down scene
        CGRect downFrame = self.secondScene.frame;
        downFrame.origin.x = self.beginX;
        self.secondScene.frame = downFrame;
        
        [self.firstScene setStatus:RNNativeSceneStatusDidFocus];
        [self.secondScene setStatus:RNNativeSceneStatusDidBlur];
        
        if (self.primaryScene) {
            [self.primaryScene.superview sendSubviewToBack:self.primaryScene];
        }
    }];
}

@end
