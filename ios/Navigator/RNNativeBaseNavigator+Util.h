//
//  RNNativeBaseNavigator+Util.h
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/7.
//

#import "RNNativeBaseNavigator.h"

NS_ASSUME_NONNULL_BEGIN

@interface RNNativeBaseNavigator (Extension)

#pragma mark - Utils

- (CGRect)getBeginFrameWithParentBounds:(CGRect)bounds
                             transition:(RNNativeSceneTransition)transition;
- (CGRect)getBeginFrameWithParentBounds:(CGRect)bounds
                             transition:(RNNativeSceneTransition)transition
                                  index:(NSInteger)index
                             fullScreen:(BOOL)fullScreen
                                  split:(BOOL)split
                      primarySceneWidth:(CGFloat)primarySceneWidth;

- (CGRect)getFrameWithParentBounds:(CGRect)bounds;
- (CGRect)getFrameWithParentBounds:(CGRect)bounds
                             index:(NSInteger)index
                        fullScreen:(BOOL)fullScreen
                             split:(BOOL)split
                 primarySceneWidth:(CGFloat)primarySceneWidth;

@end

NS_ASSUME_NONNULL_END
