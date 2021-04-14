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
@property (nonatomic, assign) CGFloat firstSceneMinX;
@property (nonatomic, assign) CGFloat firstSceneMaxX;

@property (nonatomic, assign) CGFloat secondSceneBeginX;
@property (nonatomic, assign) CGFloat secondSceneMinX;
@property (nonatomic, assign) CGFloat secondSceneMaxX;
@property (nonatomic, assign) CGFloat coverViewOriginZPosition;

@end

@implementation RNNativePanGestureHandler

- (void)panWithGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    CGPoint point = [gesture translationInView:gesture.view];
    [gesture setTranslation:CGPointZero inView:gesture.view];

    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.firstSceneBeginX = CGRectGetMinX(self.firstScene.frame);
        self.secondSceneBeginX = CGRectGetMinX(self.secondScene.frame);
        
        [self.firstScene setStatus:RNNativeSceneStatusWillBlur];
        [self.secondScene setStatus:RNNativeSceneStatusWillFocus];
        
        CGRect secondSceneFrame = self.secondScene.frame;
        secondSceneFrame.origin.x = self.secondSceneBeginX - CGRectGetWidth(secondSceneFrame) / 3.0;
        self.secondScene.frame = secondSceneFrame;
        
        self.firstSceneMinX = CGRectGetMinX(self.firstScene.frame);
        self.firstSceneMaxX = CGRectGetMaxX(self.firstScene.frame);
        
        self.secondSceneMinX = CGRectGetMinX(self.secondScene.frame);
        self.secondSceneMaxX = CGRectGetMaxX(self.secondScene.frame);
        
        if (self.coverView) {
            self.coverViewOriginZPosition = self.coverView.layer.zPosition;
            self.coverView.layer.zPosition = 1000;
        }
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        // first scene
        CGRect firstSceneFrame = self.firstScene.frame;
        CGFloat firstSceneX = firstSceneFrame.origin.x + point.x;
        if (firstSceneX < self.firstSceneBeginX || firstSceneX > self.firstSceneMaxX) {
            return;
        }
        firstSceneFrame.origin.x = firstSceneX;
        self.firstScene.frame = firstSceneFrame;
        
        // second scene
        CGRect secondSceneFrame = self.secondScene.frame;
        CGFloat secondSceneX = secondSceneFrame.origin.x + point.x / 3.0;
        if (secondSceneX < self.secondSceneMinX || secondSceneX > self.secondSceneMaxX) {
            return;
        }
        secondSceneFrame.origin.x = secondSceneX;
        self.secondScene.frame = secondSceneFrame;
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
            [self goBackWithGestureView:gesture.view];
        } else {
            [self cancelGoBackWithGestureView:gesture.view];
        }
    } else if (gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed) {
        [self cancelGoBackWithGestureView:gesture.view];
    }
}

#pragma mark - Private

- (void)goBackWithGestureView:(UIView *)gestureView {
    BOOL originalUserInteractionEnabled = gestureView.userInteractionEnabled;
    gestureView.userInteractionEnabled = NO;
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
        [self.firstScene removeFromSuperview];
        [self.firstScene.controller removeFromParentViewController];
        [self.firstScene remove];
        
        [self.secondScene setStatus:RNNativeSceneStatusDidFocus];
        
        if (self.coverView) {
            self.coverView.layer.zPosition = self.coverViewOriginZPosition;
        }
        
        gestureView.userInteractionEnabled = originalUserInteractionEnabled;
        self.completeBolck(YES);
    }];
}

- (void)cancelGoBackWithGestureView:(UIView *)gestureView {
    [self.firstScene setStatus:RNNativeSceneStatusWillFocus];
    [self.secondScene setStatus:RNNativeSceneStatusWillBlur];
    
    BOOL originalUserInteractionEnabled = gestureView.userInteractionEnabled;
    gestureView.userInteractionEnabled = NO;
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
        
        if (self.coverView) {
            self.coverView.layer.zPosition = self.coverViewOriginZPosition;
        }
        
        gestureView.userInteractionEnabled = originalUserInteractionEnabled;
        self.completeBolck(NO);
    }];
}

@end
