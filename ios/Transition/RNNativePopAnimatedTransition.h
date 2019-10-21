//
//  RNNativePopAnimatedTransition.h
//  owl
//
//  Created by Bell Zhong on 2019/10/18.
//  Copyright © 2019 shimo.im. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNNativeStackConst.h"

NS_ASSUME_NONNULL_BEGIN

/**
 pop 动画
 */
@interface RNNativePopAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) RNNativeStackSceneTransition transition;

- (instancetype)initWithTransition:(RNNativeStackSceneTransition)transition;

@end

NS_ASSUME_NONNULL_END
