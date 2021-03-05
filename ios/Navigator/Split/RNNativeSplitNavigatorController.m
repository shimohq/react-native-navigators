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

-(UIViewController *)childViewControllerForStatusBarStyle {
    return [self rnn_topSceneController];
}

-(UIViewController *)childViewControllerForStatusBarHidden {
    return [self rnn_topSceneController];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    __block NSArray<RNNativeScene *> *targetScenes = nil;;
    [self computePanInfoWithGestureRecognizer:gestureRecognizer completion:^(NSArray<RNNativeScene *> *theTargetScenes, __kindof UIView *coverView) {
        targetScenes = theTargetScenes;
    }];
    NSInteger count = targetScenes.count;
    if (count < 1) {
        return NO;
    }
    
    RNNativeScene *topScene = targetScenes.lastObject;
    if (count < 2 && topScene.splitPrimary) {
        return NO;
    }
    if (!topScene.gestureEnabled) {
        return NO;
    }
    CGFloat topSceneMinX = CGRectGetMinX(topScene.frame);
    CGPoint location = [gestureRecognizer locationInView:self.view];
    if (location.x < topSceneMinX || location.x > topSceneMinX + 120) {
        return NO;
    }
    return YES;
}

#pragma mark - UIPanGestureRecognizer - Action

- (void)panWithGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        __block NSArray<RNNativeScene *> *targetScenes = nil;
        __block UIView *coverView = nil;
        [self computePanInfoWithGestureRecognizer:gestureRecognizer completion:^(NSArray<RNNativeScene *> *theTargetScenes, __kindof UIView *theCoverView) {
            targetScenes = theTargetScenes;
            coverView = theCoverView;
        }];
        
        NSInteger count = targetScenes.count;
        if (count < 1) {
            return;
        }
        
        RNNativeScene *firstScene = targetScenes[count - 1];
        if (count < 2) {
            if (firstScene.splitPrimary) {
                return;
            }
        } else {
            self.panGestureHandler.secondScene = targetScenes[count - 2];
        }
        self.panGestureHandler = [[RNNativePanGestureHandler alloc] init];
        self.panGestureHandler.firstScene = firstScene;
        self.panGestureHandler.coverView = coverView;
        __weak typeof(self) weakSelf = self;
        self.panGestureHandler.didGoBack = ^{
            [weakSelf.delegate didRemoveController:firstScene.controller];
        };
    }
    [self.panGestureHandler panWithGestureRecognizer:gestureRecognizer];
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded
        || gestureRecognizer.state == UIGestureRecognizerStateCancelled
        || gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        self.panGestureHandler = nil;
    }
}

#pragma mark - Private

- (void)computePanInfoWithGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer completion:(void (^ __nonnull)(NSArray<RNNativeScene *> * __nonnull targetScenes, __kindof UIView * __nullable coverView))completion {
    CGPoint location = [gestureRecognizer locationInView:self.view];
    NSArray<RNNativeScene *> *currentScenes = [self.dataSource getCurrentScenes];
    
    NSArray<RNNativeScene *> *targetScenes;
    UIView *coverView = nil;
    if ([self.dataSource isSplit]) {
        NSMutableArray<RNNativeScene *> *primaryScenes = [NSMutableArray array];
        NSMutableArray<RNNativeScene *> *secondaryScenes = [NSMutableArray array];
        for (RNNativeScene *scene in currentScenes) {
            if (scene.splitPrimary) {
                [primaryScenes addObject:scene];
            } else {
                [secondaryScenes addObject:scene];
            }
        }
        if ([self.dataSource isSplitFullScreen]) {
            if (secondaryScenes.count) {
                targetScenes = secondaryScenes;
            } else {
                targetScenes = primaryScenes;
            }
        } else {
            if (location.x > [self.dataSource getPrimarySceneWidth]) {
                targetScenes = secondaryScenes;
            } else {
                targetScenes = primaryScenes;
            }
        }
        if (targetScenes == primaryScenes) {
            coverView = secondaryScenes.count > 0 ? secondaryScenes.lastObject : [self.dataSource getSplitPlaceholder];
        } else {
            coverView = primaryScenes.lastObject;
        }
    } else {
        targetScenes = currentScenes;
    }
    completion(targetScenes, coverView);
}

@end
