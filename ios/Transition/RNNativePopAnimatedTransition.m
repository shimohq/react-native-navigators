//
//  RNNativePopAnimatedTransition.m
//  owl
//
//  Created by Bell Zhong on 2019/10/18.
//  Copyright © 2019 shimo.im. All rights reserved.
//

#import "RNNativePopAnimatedTransition.h"

@implementation RNNativePopAnimatedTransition

- (instancetype)initWithTransition:(RNNativeSceneTransition)transition
{
    self = [super init];
    if (self) {
        _transition = transition;
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning


// This is used for percent driven interactive transitions, as well as for
// container controllers that have companion animations that might need to
// synchronize with the main animation.
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return [transitionContext isAnimated] && _transition != RNNativeSceneTransitionNone ? 0.35 : 0;
}

// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = transitionContext.containerView;
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    // This will be the current frame of fromViewController.view.
    CGRect __unused fromViewInitialFrame = [transitionContext initialFrameForViewController:fromViewController];
    CGRect fromViewFinalFrame = [transitionContext finalFrameForViewController:fromViewController];
    CGRect toViewInitialFrame = [transitionContext initialFrameForViewController:toViewController];
    CGRect toViewFinalFrame = [transitionContext finalFrameForViewController:toViewController];
    CGSize fromViewFromShadowOffset = CGSizeZero;
    
    [containerView insertSubview:toView belowSubview:fromView];
    
    switch (_transition) {
        case RNNativeSceneTransitionSlideFormLeft:
            toViewInitialFrame.origin = CGPointMake(CGRectGetMaxX(containerView.bounds)/3.0, CGRectGetMinY(toViewFinalFrame));
            fromViewFinalFrame = CGRectOffset(fromView.frame, -CGRectGetWidth(fromView.frame), 0);
            fromViewFromShadowOffset = CGSizeMake(3, 0);
            break;
        case RNNativeSceneTransitionSlideFormRight:
        case RNNativeSceneTransitionDefault:
            toViewInitialFrame.origin = CGPointMake(-CGRectGetMaxX(containerView.bounds)/3.0, CGRectGetMinY(toViewFinalFrame));
            fromViewFinalFrame = CGRectOffset(fromView.frame, CGRectGetWidth(fromView.frame), 0);
            fromViewFromShadowOffset = CGSizeMake(-3, 0);
            break;
        case RNNativeSceneTransitionSlideFormTop:
            toViewInitialFrame.origin = toViewFinalFrame.origin;
            fromViewFinalFrame = CGRectOffset(fromView.frame, 0, -CGRectGetHeight(fromView.frame));
            fromViewFromShadowOffset = CGSizeMake(0, 3);
            break;
        case RNNativeSceneTransitionSlideFormBottom:
            toViewInitialFrame.origin = toViewFinalFrame.origin;
            fromViewFinalFrame = CGRectOffset(fromView.frame, 0, CGRectGetHeight(fromView.frame));
            fromViewFromShadowOffset = CGSizeMake(0, -3);
            break;
        default:
            break;
    }
    toViewInitialFrame.size = toViewFinalFrame.size;
    toView.frame = toViewInitialFrame;
    
    CGFloat fromViewOriginalShadowOpacity = fromView.layer.shadowOpacity;
    CGColorRef fromViewOriginalShadowColor = fromView.layer.shadowColor;
    CGFloat fromViewOriginalShadowRadius = fromView.layer.shadowRadius;
    CGSize fromViewOriginalShadowOffset = fromView.layer.shadowOffset;
    
    fromView.layer.shadowOpacity = 0.2;
    fromView.layer.shadowColor = [UIColor blackColor].CGColor;
    fromView.layer.shadowRadius = 0;
    fromView.layer.shadowOffset = fromViewFromShadowOffset;
    
    NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:transitionDuration animations:^{
        toView.frame = toViewFinalFrame;
        fromView.frame = fromViewFinalFrame;
    } completion:^(BOOL finished) {
        // When we complete, tell the transition context
        // passing along the BOOL that indicates whether the transition
        // finished or not.
        
        fromView.layer.shadowOpacity = fromViewOriginalShadowOpacity;
        fromView.layer.shadowColor = fromViewOriginalShadowColor;
        fromView.layer.shadowRadius = fromViewOriginalShadowRadius;
        fromView.layer.shadowOffset = fromViewOriginalShadowOffset;
        
        BOOL wasCancelled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!wasCancelled];
    }];
}

@end
