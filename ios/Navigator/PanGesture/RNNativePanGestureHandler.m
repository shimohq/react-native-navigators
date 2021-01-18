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
        self.beginX = CGRectGetMinX(self.upScene.frame);
        
        if (self.primaryScene) {
            [self.primaryScene.superview bringSubviewToFront:self.primaryScene];
        }
        
        [self.upScene.controller viewWillDisappear:YES];
        [self.downScene.controller viewWillAppear:YES];
        
        CGRect downFrame = self.downScene.frame;
        downFrame.origin.x = self.beginX - CGRectGetWidth(downFrame) / 3.0;
        self.downScene.frame = downFrame;
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        // up scene
        CGRect upFrame = self.upScene.frame;
        upFrame.origin.x += point.x;
        self.upScene.frame = upFrame;
        
        // down scene
        CGRect downFrame = self.downScene.frame;
        downFrame.origin.x += point.x / 3.0;
        self.downScene.frame = downFrame;
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity =[gesture velocityInView:gesture.view];
        BOOL success;
        if (velocity.x > 500) {
            success = YES;
        } else if (velocity.x < -500) {
            success = NO;
        } else {
            CGRect frame = self.upScene.frame;
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
        CGRect upSceneFrame = self.upScene.frame;
        upSceneFrame.origin.x = self.beginX + CGRectGetWidth(upSceneFrame);
        self.upScene.frame = upSceneFrame;
        
        // down scene
        CGRect downSceneFrame = self.downScene.frame;
        downSceneFrame.origin.x = self.beginX;
        self.downScene.frame = downSceneFrame;
    } completion:^(BOOL finished) {
        if (self.didGoBack) {
            self.didGoBack();
        }
        
        [self.upScene removeFromSuperview];
        [self.upScene.controller removeFromParentViewController];
        [self.upScene.controller viewDidDisappear:YES];
        
        [self.downScene.controller viewDidAppear:YES];
        
        if (self.primaryScene) {
            [self.primaryScene.superview sendSubviewToBack:self.primaryScene];
        }
    }];
}

- (void)cancelGoBack {
    [self.upScene.controller viewWillAppear:YES];
    [self.downScene.controller viewWillDisappear:YES];
    [UIView animateWithDuration:RNNativeNavigateDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        // up scene
        CGRect upSceneFrame = self.upScene.frame;
        upSceneFrame.origin.x = self.beginX;
        self.upScene.frame = upSceneFrame;
        
        // down scene
        CGRect downFrame = self.downScene.frame;
        downFrame.origin.x = self.beginX - CGRectGetWidth(downFrame) / 3.0;
        self.downScene.frame = downFrame;
    } completion:^(BOOL finished) {
        // down scene
        CGRect downFrame = self.downScene.frame;
        downFrame.origin.x = self.beginX;
        self.downScene.frame = downFrame;
        
        [self.upScene.controller viewDidAppear:YES];
        [self.downScene.controller viewDidDisappear:YES];
        
        if (self.primaryScene) {
            [self.primaryScene.superview sendSubviewToBack:self.primaryScene];
        }
    }];
}

@end
