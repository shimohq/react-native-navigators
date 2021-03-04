//
//  RNNativeTransitionUtils.h
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/3/3.
//

#import <Foundation/Foundation.h>
#import "RNNativeConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface RNNativeTransitionUtils : NSObject

+ (CGRect)getDownViewFrameWithView:(UIView *)view
                        transition:(RNNativeSceneTransition)transition;

@end

NS_ASSUME_NONNULL_END
