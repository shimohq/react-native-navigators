//
//  RNNativeModalAnimatedTransition.h
//  owl
//
//  Created by Bell Zhong on 2019/10/15.
//  Copyright © 2019 shimo.im. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNNativeStackConst.h"

NS_ASSUME_NONNULL_BEGIN

/**
 present dismiss 动画
 */
@interface RNNativeModalAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) RNNativeStackSceneTransition transition;
@property (nonatomic, assign) BOOL presenting;

- (instancetype)initWithTransition:(RNNativeStackSceneTransition)transition presenting:(BOOL)presenting;

@end

NS_ASSUME_NONNULL_END
