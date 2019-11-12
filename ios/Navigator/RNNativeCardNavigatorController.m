//
//  RNNativeCardNavigatorController.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2019/11/12.
//

#import "RNNativeCardNavigatorController.h"
#import "RNNativeStackScene.h"

@interface RNNativeCardNavigatorController ()

@end

@implementation RNNativeCardNavigatorController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // INFO: 切换 viewController 的同时旋转屏幕，新的 viewController 可能也会保持屏幕旋转之前的 frame。
    // 为了修复这个问题，重新布局的时候重新设置 frame。
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[RNNativeStackScene class]]) {
            [self updateFrameWithView:view parentView:self.view];
        }
    }
}

#pragma mark - Private

- (void)updateFrameWithView:(UIView *)view parentView:(UIView *)parentView {
    CGRect parentFrame = parentView.frame;
    CGRect frame = view.frame;
    if (!CGRectEqualToRect(frame, parentFrame)) {
        view.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(parentFrame), CGRectGetHeight(parentFrame));
    }
}

@end
