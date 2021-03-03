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
    NSArray<RNNativeScene *> *currentScenes = [self.dataSource getCurrentScenes];

    if ([self.dataSource isSplit] && ![self.dataSource isSplitFullScreen]) {
        NSArray<RNNativeScene *> *targetScenes;
        NSMutableArray<RNNativeScene *> *primaryScenes = [NSMutableArray array];
        NSMutableArray<RNNativeScene *> *sencondaryScenes = [NSMutableArray array];
        for (RNNativeScene *scene in currentScenes) {
            if (scene.splitPrimary) {
                [primaryScenes addObject:scene];
            } else {
                [sencondaryScenes addObject:scene];
            }
        }
        CGPoint location = [gestureRecognizer locationInView:self.view];
        if (location.x > [self.dataSource getPrimarySceneWidth]) {
            // in secondary
            targetScenes = sencondaryScenes;
        } else {
            // in primary
            targetScenes = primaryScenes;
        }
        if (targetScenes.count < 2) {
            return NO;
        }
        RNNativeScene *topScene = targetScenes.lastObject;
        if (!topScene.gestureEnabled) {
            return NO;
        }
        CGFloat topSceneMinX = CGRectGetMinX(topScene.frame);
        if (location.x < topSceneMinX || location.x > topSceneMinX + 120) {
            return NO;
        }
        return YES;
    } else {
        return currentScenes.count >=2;
    }
}

#pragma mark - UIPanGestureRecognizer - Action

- (void)panWithGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSArray<RNNativeScene *> *currentScenes = [self.dataSource getCurrentScenes];
        
        // find target scenes
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
                CGPoint location = [gestureRecognizer locationInView:self.view];
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
        
        NSInteger count = targetScenes.count;
        if (count < 2) {
            return;
        }
        
        RNNativeScene *firstScene = targetScenes[count - 1];
        RNNativeScene *secondScene = targetScenes[count - 2];
        self.panGestureHandler = [[RNNativePanGestureHandler alloc] init];
        self.panGestureHandler.firstScene = firstScene;
        self.panGestureHandler.secondScene = secondScene;
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

@end
