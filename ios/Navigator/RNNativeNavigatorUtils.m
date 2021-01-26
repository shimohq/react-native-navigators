//
//  RNNativeNavigatorUtils.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/14.
//

#import "RNNativeNavigatorUtils.h"

@implementation RNNativeNavigatorUtils

+ (CGRect)getBeginFrameWithFrame:(CGRect)frame
                      transition:(RNNativeSceneTransition)transition {
    return [self getBeginFrameWithFrame:frame
                             transition:transition
                                  index:0
                             fullScreen:NO
                                  split:NO
                      primarySceneWidth:0];
}

+ (CGRect)getBeginFrameWithFrame:(CGRect)frame
                      transition:(RNNativeSceneTransition)transition
                           index:(NSInteger)index
                      fullScreen:(BOOL)fullScreen
                           split:(BOOL)split
               primarySceneWidth:(CGFloat)primarySceneWidth {
    
    CGFloat width = CGRectGetWidth(frame);
    CGFloat height = CGRectGetHeight(frame);
    
    CGFloat endY = 0;
    CGFloat endX;
    if (split && !fullScreen) {
        endX = index == 0 ? 0 : primarySceneWidth;
    } else {
        endX = 0;
    }
    
    frame.origin.x = endX;
    frame.origin.y = endY;
    switch (transition) {
        case RNNativeSceneTransitionSlideFormRight:
            frame.origin.x = endX + width;
            break;
        case RNNativeSceneTransitionSlideFormLeft:
            frame.origin.x = endX - width;
            break;
        case RNNativeSceneTransitionSlideFormTop:
            frame.origin.y = endY - height;
            break;
        case RNNativeSceneTransitionSlideFormBottom:
        case RNNativeSceneTransitionDefault:
            frame.origin.y = endY + height;
        case RNNativeSceneTransitionNone:
        default:
            break;
    }
    return frame;
}

+ (CGRect)getEndFrameWithFrame:(CGRect)frame {
    return [self getEndFrameWithFrame:frame index:0 fullScreen:NO split:NO primarySceneWidth:0];
}

+ (CGRect)getEndFrameWithFrame:(CGRect)frame
                         index:(NSInteger)index
                    fullScreen:(BOOL)fullScreen
                         split:(BOOL)split
             primarySceneWidth:(CGFloat)primarySceneWidth {
    if (split && !fullScreen) {
        frame.origin.x = index == 0 ? 0 : primarySceneWidth;
    } else {
        frame.origin.x = 0;
    }
    frame.origin.y = 0;
    return frame;
}

@end
