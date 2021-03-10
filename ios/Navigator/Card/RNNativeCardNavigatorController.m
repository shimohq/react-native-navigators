//
//  RNNativeCardNavigatorController.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2019/11/12.
//

#import "RNNativeCardNavigatorController.h"
#import "RNNativeScene.h"
#import "RNNativePanGestureRecognizerManager.h"
#import "RNNativePanGestureHandler.h"

#import "UIViewController+RNNativeNavigator.h"

@interface RNNativeCardNavigatorController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) RNNativePanGestureHandler *panGestureHandler;

@end

@implementation RNNativeCardNavigatorController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panWithGestureRecognizer:)];
    panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    [[RNNativePanGestureRecognizerManager sharedInstance] addPanGestureRecognizer:panGestureRecognizer];
}

-(UIViewController *)childViewControllerForStatusBarStyle {
    return [self rnn_topSceneController];
}

-(UIViewController *)childViewControllerForStatusBarHidden {
    return [self rnn_topSceneController];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    NSArray<RNNativeScene *> *topTwoScenes = [self rnn_getTopScenesWithCount:2];
    if (topTwoScenes.count < 2 || !topTwoScenes[0].gestureEnabled) {
        return NO;
    }
    CGPoint location = [gestureRecognizer locationInView:self.view];
    if (location.x > 120) {
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
    }
    [self.panGestureHandler panWithGestureRecognizer:gesture];
    if (gesture.state == UIGestureRecognizerStateEnded
        || gesture.state == UIGestureRecognizerStateCancelled
        || gesture.state == UIGestureRecognizerStateFailed) {
        self.panGestureHandler = nil;
    }
}

@end
