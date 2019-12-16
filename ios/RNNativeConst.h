//
//  RNNativeConst.h
//  owl
//
//  Created by Bell Zhong on 2019/10/15.
//  Copyright © 2019 shimo.im. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RNNativeSceneTransition) {
    RNNativeSceneTransitionDefault,
    RNNativeSceneTransitionNone,
    RNNativeSceneTransitionSlideFormTop,
    RNNativeSceneTransitionSlideFormRight,
    RNNativeSceneTransitionSlideFormBottom,
    RNNativeSceneTransitionSlideFormLeft
};

typedef NS_ENUM(NSInteger, RNNativeSceneStatus) {
    RNNativeSceneStatusDidBlur,
    RNNativeSceneStatusWillBlur,
    RNNativeSceneStatusDidFocus,
    RNNativeSceneStatusWillFocus
};

typedef void (^RNNativeNavigatorTransitionBlock)(BOOL updateStatus);

@interface RNNativeConst : NSObject

@end

NS_ASSUME_NONNULL_END
