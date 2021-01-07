//
//  RNNativeSplitNavigatorController.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/6.
//

#import "RNNativeSplitNavigatorController.h"
#import "RNNativeScene.h"
#import "RNNativePanGestureRecognizerManager.h"
#import "RNNativePanGestureHandler.h"

#import "UIViewController+RNNativeNavigator.h"

@interface RNNativeSplitNavigatorController () <UIGestureRecognizerDelegate>

@end

@implementation RNNativeSplitNavigatorController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panWithGestureRecognizer:)];
    panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    [[RNNativePanGestureRecognizerManager sharedInstance] addPanGestureRecognizer:panGestureRecognizer];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.delegate willLayoutSubviews:self.view.bounds];
}

-(UIViewController *)childViewControllerForStatusBarStyle {
    return [self rnn_topSceneController];
}

-(UIViewController *)childViewControllerForStatusBarHidden {
    return [self rnn_topSceneController];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    NSArray<RNNativeScene *> *topScenes = [self rnn_getTopScenesWithCount:3];
    BOOL split = [self.dataSource isSplit];
    if (topScenes.count < (split ? 3 : 2)) {
        return NO;
    }
    if (!topScenes[0].gestureEnabled) {
        return NO;
    }
    CGPoint location = [gestureRecognizer locationInView:self.view];
    RNNativeScene *topScene = topScenes[0];
    CGFloat topSceneMinX = CGRectGetMinX(topScene.frame);
    if (location.x < topSceneMinX || location.x > topSceneMinX + 120) {
        return NO;
    }
    return YES;
}

#pragma mark - UIPanGestureRecognizer - Action

- (void)panWithGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    NSArray<RNNativeScene *> *topTwoScenes = [self rnn_getTopScenesWithCount:2];
    if (topTwoScenes.count < 2) {
        return;
    }
    RNNativeScene *upScene = topTwoScenes[0];
    RNNativeScene *downScene = topTwoScenes[1];
    [[RNNativePanGestureHandler sharedInstance] panWithGestureRecognizer:gesture upScene:upScene downScene:downScene didGoBack:^{
        [self.delegate didRemoveController:upScene.controller];
    }];
}

@end
