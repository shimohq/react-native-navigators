//
//  RNNativeConst.h
//  owl
//
//  Created by Bell Zhong on 2019/10/15.
//  Copyright © 2019 shimo.im. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RNNativeScene;

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

typedef void (^RNNativeNavigatorTransitionBlock)(BOOL updateStatus, NSArray<RNNativeScene *> * _Nullable primaryScene);

static const float RNNativeNavigateDuration = 0.3;

@interface RNNativeConst : NSObject

@end

NS_ASSUME_NONNULL_END
