//
//  RNNativeNavigatorFrameData.h
//  owl
//
//  Created by Bell Zhong on 2019/10/21.
//  Copyright © 2019 shimo.im. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNNativeNavigatorFrameData : NSObject

@property (nonatomic, assign, readonly) CGRect frame;

- (instancetype)initWithFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
