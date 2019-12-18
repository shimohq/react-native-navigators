//
//  RootViewController.m
//  examples
//
//  Created by Bell Zhong on 2019/12/18.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

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
