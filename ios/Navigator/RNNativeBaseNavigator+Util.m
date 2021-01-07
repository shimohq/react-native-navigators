//
//  RNNativeBaseNavigator+Util.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/7.
//

#import "RNNativeBaseNavigator+Util.h"

@implementation RNNativeBaseNavigator (Extension)

- (CGRect)getBeginFrameWithParentBounds:(CGRect)bounds
                             transition:(RNNativeSceneTransition)transition {
    return [self getBeginFrameWithParentBounds:bounds
                                    transition:transition
                                         index:0
                                    fullScreen:NO
                                         split:NO
                             primarySceneWidth:0];
}

- (CGRect)getBeginFrameWithParentBounds:(CGRect)bounds
                             transition:(RNNativeSceneTransition)transition
                                  index:(NSInteger)index
                             fullScreen:(BOOL)fullScreen
                                  split:(BOOL)split
                      primarySceneWidth:(CGFloat)primarySceneWidth {
    CGRect frame;
    CGFloat width;
    CGFloat minX;
    if (split && !fullScreen) {
        minX = index == 0 ? 0 : primarySceneWidth;
        width = index == 0 ? primarySceneWidth : (CGRectGetWidth(bounds) - primarySceneWidth);
    } else {
        minX = CGRectGetMinX(bounds);
        width = CGRectGetWidth(bounds);
    }
    
    switch (transition) {
        case RNNativeSceneTransitionSlideFormRight:
            frame = CGRectMake(CGRectGetMaxX(bounds), CGRectGetMinY(bounds), width, CGRectGetHeight(bounds));
            break;
        case RNNativeSceneTransitionSlideFormLeft:
            frame = CGRectMake(-CGRectGetMaxX(bounds), CGRectGetMinY(bounds), width, CGRectGetHeight(bounds));
            break;
        case RNNativeSceneTransitionSlideFormTop:
            frame = CGRectMake(minX, -CGRectGetMaxY(bounds), width, CGRectGetHeight(bounds));
            break;
        case RNNativeSceneTransitionSlideFormBottom:
        case RNNativeSceneTransitionDefault:
            frame = CGRectMake(minX, CGRectGetMaxY(bounds), width, CGRectGetHeight(bounds));
            break;
        default:
            frame = bounds;
            break;
    }
    return frame;
}

- (CGRect)getFrameWithParentBounds:(CGRect)bounds {
    return [self getFrameWithParentBounds:bounds
                                    index:0
                               fullScreen:NO
                                    split:NO
                        primarySceneWidth:0];
}

- (CGRect)getFrameWithParentBounds:(CGRect)bounds
                             index:(NSInteger)index
                        fullScreen:(BOOL)fullScreen
                             split:(BOOL)split
                 primarySceneWidth:(CGFloat)primarySceneWidth {
    if (split && !fullScreen) {
        if (index == 0) {
            return CGRectMake(0, 0, primarySceneWidth, CGRectGetHeight(bounds));
        } else {
            return CGRectMake(primarySceneWidth, 0, CGRectGetWidth(bounds) - primarySceneWidth, CGRectGetHeight(bounds));
        }
    } else {
        return bounds;
    }
}

@end
