//
//  RNNativeSplitRule.h
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNNativeSplitRule : NSObject

@property(nonatomic, assign) CGFloat primarySceneWidth;
@property(nonatomic, assign) CGFloat navigatorWidthBegin;
@property(nonatomic, assign) CGFloat navigatorWidthEnd;

@end

NS_ASSUME_NONNULL_END
