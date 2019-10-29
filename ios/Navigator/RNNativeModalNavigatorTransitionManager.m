//
//  RNNativeModalNavigatorTransitionManager.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2019/10/29.
//

#import "RNNativeModalNavigatorTransitionManager.h"

@interface RNNativeModalNavigatorTransitionManager()

@property (nonatomic, assign) NSInteger number;

@end

@implementation RNNativeModalNavigatorTransitionManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _number = 0;
    }
    return self;
}

- (void)presentViewController:(UIViewController *)viewController
         parentViewController:(UIViewController *)parentViewController
                     animated:(BOOL)animated
                   completion:(void (^ __nullable)(void))completion {
    [self increment];
    [parentViewController presentViewController:viewController animated:animated completion:^{
        if (completion) {
            completion();
        }
        [self decreaseAndHandleEndTransition];
    }];
}

- (void)dismissViewController:(UIViewController *)viewController
                     animated:(BOOL)animated
                   completion:(void (^ __nullable)(void))completion {
    [self increment];
    [viewController dismissViewControllerAnimated:animated completion:^{
        if (completion) {
            completion();
        }
        [self decreaseAndHandleEndTransition];
    }];
}

#pragma mark - Number Manager

- (void)decreaseAndHandleEndTransition {
    if ([self decrease] <= 0 && _endTransition) {
        _endTransition();
    }
}

- (NSInteger)decrease {
    return --_number;
}

- (NSInteger)increment {
    return ++_number;
}

@end
