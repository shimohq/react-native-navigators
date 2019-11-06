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
    RNNativeStackSceneTransitionDefault,
    RNNativeStackSceneTransitionNone,
    RNNativeStackSceneTransitionSlideFormTop,
    RNNativeStackSceneTransitionSlideFormRight,
    RNNativeStackSceneTransitionSlideFormBottom,
    RNNativeStackSceneTransitionSlideFormLeft
};

typedef NS_ENUM(NSInteger, RNNativeStackSceneStatus) {
    RNNativeStackSceneStatusDidBlur,
    RNNativeStackSceneStatusWillBlur,
    RNNativeStackSceneStatusDidFocus,
    RNNativeStackSceneStatusWillFocus
};

typedef void (^RNNativeNavigatorTransitionBlock)(BOOL updateStatus);

@interface RNNativeStackConst : NSObject

@end

NS_ASSUME_NONNULL_END
