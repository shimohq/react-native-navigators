//
//  RNNativeTransitionUtils.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/3/3.
//

#import "RNNativeTransitionUtils.h"

@implementation RNNativeTransitionUtils

+ (CGRect)getDownViewFrameWithView:(UIView *)view
                        transition:(RNNativeSceneTransition)transition {
    CGRect frame = view.frame;
    CGFloat width = CGRectGetWidth(frame);
    CGFloat endX = CGRectGetMinX(frame);
    switch (transition) {
        case RNNativeSceneTransitionSlideFormRight:
            frame.origin.x = endX - width / 3.0;
            break;
        case RNNativeSceneTransitionSlideFormLeft:
            frame.origin.x = endX + width / 3.0;
            break;
        default:
            break;
    }
    return frame;
}

@end
