//
//  RNNativePanGestureHandler.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/7.
//

#import "RNNativePanGestureHandler.h"
#import "RNNativeScene.h"

@interface RNNativePanGestureHandler()

@property (nonatomic, assign) CGFloat firstSceneBeginX;
@property (nonatomic, assign) CGFloat secondSceneBeginX;

@end

@implementation RNNativePanGestureHandler

- (void)panWithGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    CGPoint point = [gesture translationInView:gesture.view];
    [gesture setTranslation:CGPointZero inView:gesture.view];

    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.firstSceneBeginX = CGRectGetMinX(self.firstScene.frame);
        self.secondSceneBeginX = CGRectGetMinX(self.secondScene.frame);
        
        if (self.primaryScene && !self.firstScene.splitFullScreen && !self.secondScene.splitFullScreen) {
            [self.primaryScene.superview bringSubviewToFront:self.primaryScene];
        }
        
        [self.firstScene setStatus:RNNativeSceneStatusWillBlur];
        [self.secondScene setStatus:RNNativeSceneStatusWillFocus];
        
        CGRect secondSceneFrame = self.secondScene.frame;
        secondSceneFrame.origin.x = self.secondSceneBeginX - CGRectGetWidth(secondSceneFrame) / 3.0;
        self.secondScene.frame = secondSceneFrame;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        // first scene
        CGRect firstSceneFrame = self.firstScene.frame;
        CGFloat firstSceneFrameX = firstSceneFrame.origin.x + point.x;
        if (firstSceneFrameX < self.firstSceneBeginX) {
            return;
        }
        firstSceneFrame.origin.x = firstSceneFrameX;
        self.firstScene.frame = firstSceneFrame;
        
        // second scene
        CGRect secondSceneFrame = self.secondScene.frame;
        CGFloat secondSceneFrameX = secondSceneFrame.origin.x + point.x / 3.0;
        if (secondSceneFrameX >= self.secondSceneBeginX - CGRectGetWidth(secondSceneFrame) / 3.0
            && secondSceneFrameX <= self.secondSceneBeginX) {
            secondSceneFrame.origin.x = secondSceneFrameX;
            self.secondScene.frame = secondSceneFrame;
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [gesture velocityInView:gesture.view];
        BOOL success;
        if (velocity.x > 500) {
            success = YES;
        } else if (velocity.x < -500) {
            success = NO;
        } else {
            CGRect frame = self.firstScene.frame;
            success = CGRectGetMinX(frame) + point.x >= self.firstSceneBeginX + CGRectGetWidth(frame) / 2.0;
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
        // first scene
        CGRect firstSceneFrame = self.firstScene.frame;
        firstSceneFrame.origin.x = self.firstSceneBeginX + CGRectGetWidth(firstSceneFrame);
        self.firstScene.frame = firstSceneFrame;
        
        // second scene
        CGRect secondSceneFrame = self.secondScene.frame;
        secondSceneFrame.origin.x = self.secondSceneBeginX;
        self.secondScene.frame = secondSceneFrame;
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
        // first scene
        CGRect firstSceneFrame = self.firstScene.frame;
        firstSceneFrame.origin.x = self.firstSceneBeginX;
        self.firstScene.frame = firstSceneFrame;
        
        // second scene
        CGRect secondSceneFrame = self.secondScene.frame;
        secondSceneFrame.origin.x = self.secondSceneBeginX - CGRectGetWidth(secondSceneFrame) / 3.0;
        self.secondScene.frame = secondSceneFrame;
    } completion:^(BOOL finished) {
        // second scene
        CGRect secondSceneFrame = self.secondScene.frame;
        secondSceneFrame.origin.x = self.secondSceneBeginX;
        self.secondScene.frame = secondSceneFrame;
        
        [self.firstScene setStatus:RNNativeSceneStatusDidFocus];
        [self.secondScene setStatus:RNNativeSceneStatusDidBlur];
        
        if (self.primaryScene) {
            [self.primaryScene.superview sendSubviewToBack:self.primaryScene];
        }
    }];
}

@end
