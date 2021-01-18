//
//  RNNativeNavigatorUtils.h
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/14.
//

#import <Foundation/Foundation.h>
#import "RNNativeConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface RNNativeNavigatorUtils : NSObject

+ (CGRect)getBeginFrameWithFrame:(CGRect)frame
                    parentBounds:(CGRect)parentBounds
                      transition:(RNNativeSceneTransition)transition;
+ (CGRect)getBeginFrameWithFrame:(CGRect)frame
                    parentBounds:(CGRect)parentBounds
                      transition:(RNNativeSceneTransition)transition
                           index:(NSInteger)index
                      fullScreen:(BOOL)fullScreen
                           split:(BOOL)split
               primarySceneWidth:(CGFloat)primarySceneWidth;

+ (CGRect)getEndFrameFrame:(CGRect)frame;
+ (CGRect)getEndFrameWithFrame:(CGRect)frame
                         index:(NSInteger)index
                    fullScreen:(BOOL)fullScreen
                         split:(BOOL)split
             primarySceneWidth:(CGFloat)primarySceneWidth;

+ (CGRect)getFrameWithParentBounds:(CGRect)bounds;
+ (CGRect)getFrameWithParentBounds:(CGRect)bounds
                             index:(NSInteger)index
                        fullScreen:(BOOL)fullScreen
                             split:(BOOL)split
                 primarySceneWidth:(CGFloat)primarySceneWidth;

@end

NS_ASSUME_NONNULL_END
