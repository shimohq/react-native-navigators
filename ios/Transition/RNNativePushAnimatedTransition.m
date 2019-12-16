//
//  RNNativePushAnimatedTransition.m
//  owl
//
//  Created by Bell Zhong on 2019/10/18.
//  Copyright © 2019 shimo.im. All rights reserved.
//

#import "RNNativePushAnimatedTransition.h"

@implementation RNNativePushAnimatedTransition

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
    CGRect fromViewInitialFrame = [transitionContext initialFrameForViewController:fromViewController];
    CGRect fromViewFinalFrame = [transitionContext finalFrameForViewController:fromViewController];
    CGRect toViewInitialFrame = [transitionContext initialFrameForViewController:toViewController];
    CGRect toViewFinalFrame = [transitionContext finalFrameForViewController:toViewController];
    CGSize toViewFromShadowOffset = CGSizeZero;
    
    [containerView addSubview:toView];
    
    switch (_transition) {
        case RNNativeSceneTransitionSlideFormLeft:
            toViewInitialFrame.origin = CGPointMake(-CGRectGetMaxX(containerView.bounds), CGRectGetMinY(toViewFinalFrame));
            fromViewFinalFrame = CGRectOffset(fromView.frame, CGRectGetWidth(fromView.frame)/3.0, 0);
            toViewFromShadowOffset = CGSizeMake(3, 0);
            break;
        case RNNativeSceneTransitionSlideFormRight:
        case RNNativeSceneTransitionDefault:
            toViewInitialFrame.origin = CGPointMake(CGRectGetMaxX(containerView.bounds), CGRectGetMinY(toViewFinalFrame));
            fromViewFinalFrame = CGRectOffset(fromView.frame, -CGRectGetWidth(fromView.frame)/3.0, 0);
            toViewFromShadowOffset = CGSizeMake(-3, 0);
            break;
        case RNNativeSceneTransitionSlideFormTop:
            toViewInitialFrame.origin = CGPointMake(CGRectGetMinX(toViewFinalFrame), -CGRectGetMaxY(containerView.bounds));
            fromViewFinalFrame = fromViewInitialFrame;
            toViewFromShadowOffset = CGSizeMake(0, 3);
            break;
        case RNNativeSceneTransitionSlideFormBottom:
            toViewInitialFrame.origin = CGPointMake(CGRectGetMinX(toViewFinalFrame), CGRectGetMaxY(containerView.bounds));
            fromViewFinalFrame = fromViewInitialFrame;
            toViewFromShadowOffset = CGSizeMake(0, -3);
            break;
        default:
            break;
    }
    toViewInitialFrame.size = toViewFinalFrame.size;
    
    CGFloat toViewOriginalShadowOpacity = toView.layer.shadowOpacity;
    CGColorRef toViewOriginalShadowColor = toView.layer.shadowColor;
    CGFloat toViewOriginalShadowRadius = toView.layer.shadowRadius;
    CGSize toViewOriginalShadowOffset = toView.layer.shadowOffset;
    
    toView.layer.shadowOpacity = 0.2;
    toView.layer.shadowColor = [UIColor blackColor].CGColor;
    toView.layer.shadowRadius = 1;
    toView.layer.shadowOffset = toViewFromShadowOffset;
    
    toView.frame = toViewInitialFrame;
    
    NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:transitionDuration animations:^{
        toView.frame = toViewFinalFrame;
        fromView.frame = fromViewFinalFrame;
    } completion:^(BOOL finished) {
        // When we complete, tell the transition context
        // passing along the BOOL that indicates whether the transition
        // finished or not.
        toView.layer.shadowOpacity = toViewOriginalShadowOpacity;
        toView.layer.shadowColor = toViewOriginalShadowColor;
        toView.layer.shadowRadius = toViewOriginalShadowRadius;
        toView.layer.shadowOffset = toViewOriginalShadowOffset;
        
        BOOL wasCancelled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!wasCancelled];
    }];
}

@end
