//
//  RNNativeModalNavigatorController.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2019/12/16.
//

#import "RNNativeModalNavigatorController.h"

@interface RNNativeModalNavigatorController ()

@end

@implementation RNNativeModalNavigatorController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(UIViewController *)childViewControllerForStatusBarStyle {
    return self.childViewControllers.count > 0 ? self.childViewControllers.lastObject : nil;
}

-(UIViewController *)childViewControllerForStatusBarHidden {
    return self.childViewControllers.count > 0 ? self.childViewControllers.lastObject : nil;
}

@end
