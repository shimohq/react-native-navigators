//
//  RNNativeSplitNavigator.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/6.
//

#import "RNNativeSplitNavigator.h"
#import "RNNativeSplitNavigatorController.h"
#import "RNNativeScene.h"
#import "RNNativeSplitPlaceholder.h"
#import "RNNativeSplitRule.h"
#import "RNNativeSplitUtils.h"

#import <React/RCTShadowView.h>
#import <React/RCTRootShadowView.h>
#import <React/RCTUIManager.h>
#import <React/RCTUIManagerUtils.h>

#import "RNNativeBaseNavigator+Layout.h"

@interface RNNativeSplitNavigator() <RNNativeSplitNavigatorControllerDelegate, RNNativeSplitNavigatorControllerDataSource>

@property (nonatomic, strong) NSMutableArray<UIViewController *> *viewControllers;
@property (nonatomic, assign) BOOL updating;
@property (nonatomic, strong) NSArray<RNNativeSplitRule *> *rules;
@property (nonatomic, assign) CGFloat navigatorWidth;
@property (nonatomic, assign) CGFloat primarySceneWidth;
// whether split mode
@property (nonatomic, assign) BOOL split;
@property (nullable, nonatomic, strong) RNNativeSplitPlaceholder *splitPlaceholder;

@end

@implementation RNNativeSplitNavigator

- (instancetype)initWithBridge:(RCTBridge *)bridge {
    RNNativeSplitNavigatorController *viewController = [RNNativeSplitNavigatorController new];
    viewController.delegate = self;
    viewController.dataSource = self;
    self = [super initWithBridge:bridge viewController:viewController];
    if (self) {
        _viewControllers = [NSMutableArray array];
        _updating = NO;
        
        _splitFullScreen = NO;
        _splitRules = nil;
        _rules = [RNNativeSplitUtils parseSplitRules:_splitRules];
        _navigatorWidth = CGRectGetWidth(self.frame);
        _primarySceneWidth = [RNNativeSplitUtils getPrimarySceneWidthWithRules:_rules navigatorWidth:_navigatorWidth];
        _split = _primarySceneWidth > 0;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setNavigatorWidth:CGRectGetWidth(self.bounds)];
}

#pragma mark - Setter

- (void)setSplitRules:(NSArray<NSDictionary *> *)splitRules {
    if ([_splitRules isEqualToArray:splitRules]) {
        return;
    }
    _splitRules = splitRules;
    _rules = [RNNativeSplitUtils parseSplitRules:_splitRules];
    [self setPrimarySceneWidth:[RNNativeSplitUtils getPrimarySceneWidthWithRules:_rules navigatorWidth:_navigatorWidth]];
}

- (void)setNavigatorWidth:(CGFloat)navigatorWidth {
    if (_navigatorWidth == navigatorWidth) {
        return;
    }
    _navigatorWidth = navigatorWidth;
    [self setPrimarySceneWidth:[RNNativeSplitUtils getPrimarySceneWidthWithRules:_rules navigatorWidth:_navigatorWidth]];
}

- (void)setPrimarySceneWidth:(CGFloat)primarySceneWidth {
    if (_primarySceneWidth == primarySceneWidth) {
        return;
    }
    _primarySceneWidth = primarySceneWidth;
    [self setSplit:primarySceneWidth > 0];
}

- (void)setSplit:(BOOL)split {
    if (_split == split) {
        return;
    }
    _split = split;
    [self updateScenesOrder];
}

- (void)setSplitPlaceholder:(nullable RNNativeSplitPlaceholder *)splitPlaceholder {
    if (_splitPlaceholder == splitPlaceholder) {
        return;
    }
    _splitPlaceholder = splitPlaceholder;
   
    [self addSplitPlaceholder];
}

#pragma mark - RNNativeSplitNavigatorControllerDelegate

- (void)didRemoveController:(nonnull UIViewController *)viewController {
    [_viewControllers removeObject:viewController];
}

#pragma mark - RNNativeSplitNavigatorControllerDataSource

- (BOOL)isSplit {
    return self.split;
}

- (BOOL)isSplitFullScreen {
    return self.splitFullScreen;
}

- (CGFloat)getPrimarySceneWidth {
    return self.primarySceneWidth;
}

- (NSArray<RNNativeScene *> *)getCurrentScenes {
    return self.currentScenes;
}

- (__kindof UIView *)getSplitPlaceholder {
    return self.splitPlaceholder;
}

#pragma mark - RNNativeBaseNavigator

- (void)insertReactSubview:(UIView *)subview atIndex:(NSInteger)atIndex {
    [super insertReactSubview:subview atIndex:atIndex];
    if ([subview isKindOfClass:[RNNativeSplitPlaceholder class]]) {
        [self setSplitPlaceholder:(RNNativeSplitPlaceholder *)subview];
    }
}

- (void)removeReactSubview:(UIView *)subview {
    [super removeReactSubview:subview];
    if ([subview isKindOfClass:[RNNativeSplitPlaceholder class]]) {
        [self setSplitPlaceholder:nil];
    }
}

- (BOOL)isDismissedForViewController:(UIViewController *)viewController {
    return viewController && ![_viewControllers containsObject:viewController];
}

- (void)updateSceneWithCurrentScenes:(NSArray<RNNativeScene *> *)currentScenes
                          NextScenes:(NSArray<RNNativeScene *> *)nextScenes
                           comoplete:(nonnull RNNativeNavigatorUpdateCompleteBlock)comoplete {
    // update viewControllers
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (RNNativeScene *scene in nextScenes) {
        [viewControllers addObject:scene.controller];
    }
    [_viewControllers setArray:viewControllers];
    
    if (self.split) {
        NSMutableArray *currentPrimaryScenes = [NSMutableArray array];
        NSMutableArray *nextPrimaryScenes = [NSMutableArray array];
        NSMutableArray *currentSecondaryScenes = [NSMutableArray array];
        NSMutableArray *nextSecondaryScenes = [NSMutableArray array];
        for (RNNativeScene *scene in currentScenes) {
            if (scene.splitPrimary) {
                [currentPrimaryScenes addObject:scene];
            } else {
                [currentSecondaryScenes addObject:scene];
            }
        }
        for (RNNativeScene *scene in nextScenes) {
            if (scene.splitPrimary) {
                [nextPrimaryScenes addObject:scene];
            } else {
                [nextSecondaryScenes addObject:scene];
            }
        }
        
        __block BOOL updated = NO;
        RNNativeNavigatorUpdateCompleteBlock completeBlock = ^(void) {
            if (updated) {
                comoplete();
            } else {
                updated = YES;
            }
        };
        [super updateSceneWithCurrentScenes:currentPrimaryScenes NextScenes:nextPrimaryScenes comoplete:completeBlock];
        [super updateSceneWithCurrentScenes:currentSecondaryScenes NextScenes:nextSecondaryScenes comoplete:completeBlock];
    } else {
        [super updateSceneWithCurrentScenes:currentScenes NextScenes:nextScenes comoplete:comoplete];
    }
}

/**
 addChildViewController removeFromParentViewController
 */
- (void)updateSceneWithTransition:(RNNativeSceneTransition)transition
                           action:(RNNativeStackNavigatorAction)action
                    currentScenes:(NSArray<RNNativeScene *> *)currentScenes
                       nextScenes:(NSArray<RNNativeScene *> *)nextScenes
                    removedScenes:(NSArray<RNNativeScene *> *)removedScenes
                   insertedScenes:(NSArray<RNNativeScene *> *)insertedScenes
                  beginTransition:(RNNativeNavigatorTransitionBlock)beginTransition
                    endTransition:(RNNativeNavigatorTransitionBlock)endTransition {
    beginTransition(YES);
    
    // nextTopScene 用于进场动画
    NSInteger nextTopSceneIndex = nextScenes.count - 1;
    RNNativeScene *nextTopScene = nextTopSceneIndex >= 0 ? nextScenes[nextTopSceneIndex] : nil;
    
    // currentTopScene 用于退场动画
    NSInteger currentTopSceneIndex = currentScenes.count - 1;
    RNNativeScene *currentTopScene = currentTopSceneIndex >= 0 ? currentScenes[currentTopSceneIndex] : nil;
    
    // update will show view frame
    if (action == RNNativeStackNavigatorActionShow) {
        nextTopScene.frame = [self getBeginFrameWithScene:nextTopScene transition:transition];
    }
    
    // add scene
    for (NSInteger index = 0, size = nextScenes.count; index < size; index++) {
        RNNativeScene *scene = nextScenes[index];
        // 顶部两层 scene 必须显示，否则手势返回不好处理
        if (index + 2 < size) {
            RNNativeScene *nextScene = nextScenes[index + 1];
            if (!nextScene.transparent) { // 上层 scene 透明时才显示
                continue;
            }
        }
        [self addScene:scene];
    }
    
    // transition
    CGRect nextTopSceneEndFrame = [self getEndFrameWithScene:nextTopScene];
    if (transition == RNNativeSceneTransitionNone || action == RNNativeStackNavigatorActionNone) {
        nextTopScene.frame = nextTopSceneEndFrame;
        [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes];
        endTransition(YES);
    } else if (action == RNNativeStackNavigatorActionShow) {
        [UIView animateWithDuration:RNNativeNavigateDuration animations:^{
            nextTopScene.frame = nextTopSceneEndFrame;
        } completion:^(BOOL finished) {
            if (!finished) {
                nextTopScene.frame = nextTopSceneEndFrame;
            }
            [nextTopScene setStatus:RNNativeSceneStatusDidFocus];
            [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes];
            endTransition(YES);
        }];
    } else if (action == RNNativeStackNavigatorActionHide) {
        [currentTopScene.superview bringSubviewToFront:currentTopScene];
        [currentTopScene setStatus:RNNativeSceneStatusWillBlur];
        [UIView animateWithDuration:RNNativeNavigateDuration animations:^{
            currentTopScene.frame = [self getBeginFrameWithScene:currentTopScene
                                                      transition:transition];
        } completion:^(BOOL finished) {
            [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes];
            endTransition(YES);
        }];
    }
}

#pragma mark - Layout

- (void)addSplitPlaceholder {
    // remove splitPlaceholder
    if (!_splitPlaceholder) {
        for (UIView *view in self.reactSubviews) {
            if ([view isKindOfClass:[RNNativeSplitPlaceholder class]]) {
                [view removeFromSuperview];
            }
        }
        return;
    }
    
    // add splitPlaceholder
    UIView *splitPlaceholderParent = [_splitPlaceholder superview];
    if (splitPlaceholderParent && splitPlaceholderParent != self.viewController.view) {
        [_splitPlaceholder removeFromSuperview];
        splitPlaceholderParent = nil;
    }
    if (!splitPlaceholderParent) {
        [self.viewController.view addSubview:_splitPlaceholder];
    }
    [self.viewController.view sendSubviewToBack:_splitPlaceholder];
}

- (void)updateScenesOrder {
    NSArray<RNNativeScene *> *orderedScenes;
    if (self.split) {
        // 分栏模式所有 primary scene 放在 secondary scene 下面
        NSMutableArray<RNNativeScene *> *primaryScenes = [NSMutableArray array];
        NSMutableArray<RNNativeScene *> *secondaryScenes = [NSMutableArray array];
        for (RNNativeScene *scene in self.currentScenes) {
            if (scene.splitPrimary) {
                [primaryScenes addObject:scene];
            } else {
                [secondaryScenes addObject:scene];
            }
        }
        orderedScenes = [primaryScenes arrayByAddingObjectsFromArray:secondaryScenes];
    } else {
        // 非分栏模式按 currentScenes 顺序显示
        orderedScenes = self.currentScenes;
    }
    for (NSInteger index = 0, size = orderedScenes.count; index < size; index++) {
        RNNativeScene *scene = orderedScenes[size - index - 1];
        if (index == 0) {
            [self.viewController.view bringSubviewToFront:scene];
        } else {
            [self.viewController.view sendSubviewToBack:scene];
        }
    }
}

#pragma mark - Private

- (CGRect)getBeginFrameWithScene:(RNNativeScene *)scene
                      transition:(RNNativeSceneTransition)transition{
    return [self getBeginFrameWithFrame:scene.frame transition:transition primary:scene.splitPrimary placeHolder:NO];
}

- (CGRect)getBeginFrameWithSplitPlaceholder:(RNNativeSplitPlaceholder *)splitPlaceholder
                      transition:(RNNativeSceneTransition)transition{
    return [self getBeginFrameWithFrame:splitPlaceholder.frame transition:transition primary:NO placeHolder:YES];
}

- (CGRect)getBeginFrameWithFrame:(CGRect)frame
                      transition:(RNNativeSceneTransition)transition
                         primary:(BOOL)primary
                     placeHolder:(BOOL)placeHolder {
    
    CGFloat width = CGRectGetWidth(frame);
    CGFloat height = CGRectGetHeight(frame);
    
    CGRect endFrame = [self getEndFrameWithFrame:frame primary:primary placeHolder:placeHolder];
    CGFloat endY = CGRectGetMinY(endFrame);
    CGFloat endX = CGRectGetMinX(endFrame);
    
    frame.origin.x = endX;
    frame.origin.y = endY;
    switch (transition) {
        case RNNativeSceneTransitionSlideFormRight:
            frame.origin.x = endX + width;
            break;
        case RNNativeSceneTransitionSlideFormLeft:
            frame.origin.x = endX - width;
            break;
        case RNNativeSceneTransitionSlideFormTop:
            frame.origin.y = endY - height;
            break;
        case RNNativeSceneTransitionSlideFormBottom:
        case RNNativeSceneTransitionDefault:
            frame.origin.y = endY + height;
        case RNNativeSceneTransitionNone:
        default:
            break;
    }
    return frame;
}

- (CGRect)getEndFrameWithScene:(RNNativeScene *)scene {
    return [self getEndFrameWithFrame:scene.frame primary:scene.splitPrimary placeHolder:NO];
}

- (CGRect)getEndFrameWithSplitPlaceholder:(RNNativeSplitPlaceholder *)splitPlaceholder {
    return [self getEndFrameWithFrame:splitPlaceholder.frame primary:NO placeHolder:YES];
}

- (CGRect)getEndFrameWithFrame:(CGRect)frame
                       primary:(BOOL)primary
                   placeHolder:(BOOL)placeHolder {
    if (self.split) {
        if (primary) {
            frame.origin.x = 0;
        } else if (placeHolder) {
            frame.origin.x = self.primarySceneWidth;
        } else {
            frame.origin.x = self.splitFullScreen ? 0 : self.primarySceneWidth;
        }
    } else {
        frame.origin.x = 0;
    }
    frame.origin.y = 0;
    return frame;
}

@end
