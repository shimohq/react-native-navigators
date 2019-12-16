//
//  RNNativeModalNavigatorTransitionManager.h
//  react-native-navigators
//
//  Created by Bell Zhong on 2019/10/29.
//

#import <Foundation/Foundation.h>
#import "RNNativeConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface RNNativeModalNavigatorTransitionManager : NSObject

@property (nonatomic, copy) RNNativeNavigatorTransitionBlock endTransition;

- (void)decreaseAndHandleEndTransition;
- (NSInteger)decrease;
- (NSInteger)increment;

- (void)presentViewController:(UIViewController *)viewController
         parentViewController:(UIViewController *)parentViewController
                     animated:(BOOL)animated
                   completion:(void (^ __nullable)(void))completion;
- (void)dismissViewController:(UIViewController *)viewController
                     animated:(BOOL)animated
                   completion:(void (^ __nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END
