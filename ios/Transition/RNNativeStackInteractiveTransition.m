//
//  RNNativeStackInteractiveTransition.m
//  owl
//
//  Created by Bell Zhong on 2019/10/15.
//  Copyright © 2019 shimo.im. All rights reserved.
//

#import "RNNativeStackInteractiveTransition.h"

@implementation RNNativeStackInteractiveTransition

@synthesize completionSpeed = _completionSpeed;
@synthesize completionCurve = _completionCurve;
@synthesize wantsInteractiveStart = _wantsInteractiveStart;

#pragma mark - UIViewControllerInteractiveTransitioning

- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
}

@end
