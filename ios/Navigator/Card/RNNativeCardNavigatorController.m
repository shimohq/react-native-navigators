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
    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return NO;
    }
    
    UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
    CGPoint point = [panGestureRecognizer translationInView:panGestureRecognizer.view];
    if (point.x <= 0) {
        return NO;
    }
    
    NSArray<RNNativeScene *> *topTwoScenes = [self rnn_getTopScenesWithCount:2];
    if (topTwoScenes.count < 2 || !topTwoScenes[0].gestureEnabled) {
        return NO;
    }
    CGPoint location = [gestureRecognizer locationInView:self.view];
    if (location.x > RNNativePanGestureEdgeWidth) {
        return NO;
    }
    [[RNNativePanGestureRecognizerManager sharedInstance] cancelTouchesInParent:self.view];
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
        self.panGestureHandler = [[RNNativePanGestureHandler alloc] init];
        self.panGestureHandler.firstScene = currentScenes[count - 1];
        self.panGestureHandler.secondScene = currentScenes[count - 2];
        __weak typeof(self) weakSelf = self;
        self.panGestureHandler.completeBolck = ^(BOOL goBack) {
            weakSelf.panGestureHandler = nil;
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
