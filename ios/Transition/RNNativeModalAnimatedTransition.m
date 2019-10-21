//
//  RNNativeModalAnimatedTransition.m
//  owl
//
//  Created by Bell Zhong on 2019/10/15.
//  Copyright © 2019 shimo.im. All rights reserved.
//

#import "RNNativeModalAnimatedTransition.h"
#import "RNNativeStackScene.h"

@implementation RNNativeModalAnimatedTransition

- (instancetype)initWithTransition:(RNNativeStackSceneTransition)transition presenting:(BOOL)presenting
{
    self = [super init];
    if (self) {
        _transition = transition;
        _presenting = presenting;
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning


// This is used for percent driven interactive transitions, as well as for
// container controllers that have companion animations that might need to
// synchronize with the main animation.
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return [transitionContext isAnimated] && _transition != RNNativeStackSceneTransitionNone ? 0.35 : 0;
}

// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = transitionContext.containerView;
    
    // For a Presentation:
    //      fromView = The presenting view.
    //      toView   = The presented view.
    // For a Dismissal:
    //      fromView = The presented view.
    //      toView   = The presenting view.
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    // If NO is returned from -shouldRemovePresentersView, the view associated
    // with UITransitionContextFromViewKey is nil during presentation.  This
    // intended to be a hint that your animator should NOT be manipulating the
    // presenting view controller's view.  For a dismissal, the -presentedView
    // is returned.
    //
    // Why not allow the animator manipulate the presenting view controller's
    // view at all times?  First of all, if the presenting view controller's
    // view is going to stay visible after the animation finishes during the
    // whole presentation life cycle there is no need to animate it at all — it
    // just stays where it is.  Second, if the ownership for that view
    // controller is transferred to the presentation controller, the
    // presentation controller will most likely not know how to layout that
    // view controller's view when needed, for example when the orientation
    // changes, but the original owner of the presenting view controller does.
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    BOOL isPresenting = _presenting;
    
    // This will be the current frame of fromViewController.view.
    CGRect __unused fromViewInitialFrame = [transitionContext initialFrameForViewController:fromViewController];
    // For a presentation which removes the presenter's view, this will be
    // CGRectZero.  Otherwise, the current frame of fromViewController.view.
    CGRect fromViewFinalFrame = [transitionContext finalFrameForViewController:fromViewController];
    // This will be CGRectZero.
    CGRect toViewInitialFrame = [transitionContext initialFrameForViewController:toViewController];
    // For a presentation, this will be the value returned from the
    // presentation controller's -frameOfPresentedViewInContainerView method.
    CGRect toViewFinalFrame = [transitionContext finalFrameForViewController:toViewController];
    
    // We are responsible for adding the incoming view to the containerView
    // for the presentation (will have no effect on dismissal because the
    // presenting view controller's view was not removed).
    [containerView addSubview:toView];
    
    if (isPresenting) {
        switch (_transition) {
            case RNNativeStackSceneTransitionSlideFormLeft:
                toViewInitialFrame.origin = CGPointMake(-CGRectGetMaxX(containerView.bounds), CGRectGetMinY(containerView.bounds));
                break;
            case RNNativeStackSceneTransitionSlideFormRight:
                toViewInitialFrame.origin = CGPointMake(CGRectGetMaxX(containerView.bounds), CGRectGetMinY(containerView.bounds));
                break;
            case RNNativeStackSceneTransitionSlideFormTop:
                toViewInitialFrame.origin = CGPointMake(CGRectGetMinX(containerView.bounds), -CGRectGetMaxY(containerView.bounds));
                break;
            case RNNativeStackSceneTransitionSlideFormBottom:
                toViewInitialFrame.origin = CGPointMake(CGRectGetMinX(containerView.bounds), CGRectGetMaxY(containerView.bounds));
                break;
            default:
                break;
        }
        toViewInitialFrame.size = toViewFinalFrame.size;
        toView.frame = toViewInitialFrame;
    } else {
        // Because our presentation wraps the presented view controller's view
        // in an intermediate view hierarchy, it is more accurate to rely
        // on the current frame of fromView than fromViewInitialFrame as the
        // initial frame (though in this example they will be the same).
        switch (_transition) {
            case RNNativeStackSceneTransitionSlideFormLeft:
                fromViewFinalFrame = CGRectOffset(fromView.frame, -CGRectGetWidth(fromView.frame), 0);
                break;
            case RNNativeStackSceneTransitionSlideFormRight:
                fromViewFinalFrame = CGRectOffset(fromView.frame, CGRectGetWidth(fromView.frame), 0);
                break;
            case RNNativeStackSceneTransitionSlideFormTop:
                fromViewFinalFrame = CGRectOffset(fromView.frame, 0, -CGRectGetHeight(fromView.frame));
                break;
            case RNNativeStackSceneTransitionSlideFormBottom:
                fromViewFinalFrame = CGRectOffset(fromView.frame, 0, CGRectGetHeight(fromView.frame));
                break;
            default:
                break;
        }
    }
    
    NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:transitionDuration animations:^{
        if (isPresenting) {
            toView.frame = toViewFinalFrame;
        } else {
            fromView.frame = fromViewFinalFrame;
        }
    } completion:^(BOOL finished) {
        // When we complete, tell the transition context
        // passing along the BOOL that indicates whether the transition
        // finished or not.
        BOOL wasCancelled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!wasCancelled];
    }];
}

@end
