//
//  RNNativeStackConst.h
//  owl
//
//  Created by Bell Zhong on 2019/10/15.
//  Copyright © 2019 shimo.im. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RNNativeStackSceneTransition) {
    RNNativeStackSceneTransitionNone,
    RNNativeStackSceneTransitionSlideFormTop,
    RNNativeStackSceneTransitionSlideFormRight,
    RNNativeStackSceneTransitionSlideFormBottom,
    RNNativeStackSceneTransitionSlideFormLeft
};

@interface RNNativeStackConst : NSObject

@end

NS_ASSUME_NONNULL_END
