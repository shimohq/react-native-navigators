//
//  RNNativeModalPresentationController.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2019/10/25.
//

#import "RNNativeModalPresentationController.h"
@implementation RNNativeModalPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        _transparent = NO;
    }
    return self;
}

- (BOOL)shouldRemovePresentersView {
    return !_transparent;
}

@end
