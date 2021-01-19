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

@property (nonatomic, strong) RNNativePanGestureHandler *panGestureHandler;

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
    NSArray<RNNativeScene *> *currentScenes = [self.dataSource getCurrentScenes];
    BOOL split = [self.dataSource isSplit];
    if (currentScenes.count < (split ? 3 : 2)) {
        return NO;
    }
    RNNativeScene *topScene = currentScenes.lastObject;
    if (!topScene.gestureEnabled) {
        return NO;
    }
    CGPoint location = [gestureRecognizer locationInView:self.view];
    CGFloat topSceneMinX = CGRectGetMinX(topScene.frame);
    if (location.x < topSceneMinX || location.x > topSceneMinX + 120) {
        return NO;
    }
    return YES;
}

#pragma mark - UIPanGestureRecognizer - Action

- (void)panWithGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        NSArray<RNNativeScene *> *currentScenes = [self.dataSource getCurrentScenes];
        NSInteger count = currentScenes.count;
        if (count < 2) {
            return;
        }
        RNNativeScene *firstScene = currentScenes[count - 1];
        RNNativeScene *secondScene = currentScenes[count - 2];
        self.panGestureHandler = [[RNNativePanGestureHandler alloc] init];
        self.panGestureHandler.firstScene = firstScene;
        self.panGestureHandler.secondScene = secondScene;
        if ([self.dataSource isSplit]) {
            self.panGestureHandler.primaryScene = currentScenes[0];
        }
        self.panGestureHandler.didGoBack = ^{
            [self.delegate didRemoveController:firstScene.controller];
        };
    }
    [self.panGestureHandler panWithGestureRecognizer:gesture];
    if (gesture.state == UIGestureRecognizerStateEnded
        || gesture.state == UIGestureRecognizerStateCancelled
        || gesture.state == UIGestureRecognizerStateFailed) {
        self.panGestureHandler = nil;
    }
}

@end
