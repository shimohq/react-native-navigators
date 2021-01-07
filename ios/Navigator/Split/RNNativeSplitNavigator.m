//
//  RNNativeSplitNavigator.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/6.
//

#import "RNNativeSplitNavigator.h"
#import "RNNativeSplitNavigatorController.h"
#import "RNNativeScene.h"

#import <React/RCTUIManager.h>

#import "RNNativeBaseNavigator+Util.h"
#import "RNNativeBaseNavigator+Layout.h"

@interface RNNativeSplitRule : NSObject

@property(nonatomic, assign) CGFloat primarySceneWidth;
@property(nonatomic, assign) CGFloat navigatorWidthBegin;
@property(nonatomic, assign) CGFloat navigatorWidthEnd;

@end

@implementation RNNativeSplitRule

@end

@interface RNNativeSplitNavigator() <RNNativeSplitNavigatorControllerDelegate, RNNativeSplitNavigatorControllerDataSource>

@property (nonatomic, strong) NSMutableArray<UIViewController *> *viewControllers;
@property (nonatomic, assign) BOOL updating;
@property (nonatomic, strong) NSArray<RNNativeSplitRule *> *rules;
@property (nonatomic, assign) CGRect navigatorBounds;
@property (nonatomic, assign) CGFloat navigatorWidth;
@property (nonatomic, assign) CGFloat primarySceneWidth;
// whether split mode
@property (nonatomic, assign) BOOL split;

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
        
        _splitRules = nil;
        _rules = [self parseSplitRules:_splitRules];
        _navigatorBounds = viewController.view.bounds;
        _navigatorWidth = CGRectGetWidth(viewController.view.frame);
        _primarySceneWidth = [self getPrimarySceneWidthWithRules:_rules navigatorWidth:_navigatorWidth];
        _split = _primarySceneWidth > 0;
    }
    return self;
}

#pragma mark - Setter

- (void)setSplitRules:(NSArray<NSDictionary *> *)splitRules {
    if ([_splitRules isEqualToArray:splitRules]) {
        return;
    }
    _splitRules = splitRules;
    _rules = [self parseSplitRules:_splitRules];
    [self setPrimarySceneWidth:[self getPrimarySceneWidthWithRules:_rules navigatorWidth:_navigatorWidth]];
}

- (void)setNavigatorBounds:(CGRect)navigatorBounds {
    if (CGRectEqualToRect(_navigatorBounds, navigatorBounds)) {
        return;
    }
    _navigatorBounds = navigatorBounds;
    [self updateScenesSize];
    [self setNavigatorWidth:CGRectGetWidth(navigatorBounds)];
}

- (void)setNavigatorWidth:(CGFloat)navigatorWidth {
    if (_navigatorWidth == navigatorWidth) {
        return;
    }
    _navigatorWidth = navigatorWidth;
    [self setPrimarySceneWidth:[self getPrimarySceneWidthWithRules:_rules navigatorWidth:_navigatorWidth]];
}

- (void)setPrimarySceneWidth:(CGFloat)primarySceneWidth {
    if (_primarySceneWidth == primarySceneWidth) {
        return;
    }
    _primarySceneWidth = primarySceneWidth;
    _split = primarySceneWidth > 0;
    [self updateScenesFrame];
}

#pragma mark - RNNativeSplitNavigatorControllerDelegate

- (void)didRemoveController:(nonnull UIViewController *)viewController {
    [_viewControllers removeObject:viewController];
}

- (void)willLayoutSubviews:(CGRect)parentBounds {
    [self setNavigatorBounds:parentBounds];
}

#pragma mark - RNNativeSplitNavigatorControllerDataSource

- (BOOL)isSplit {
    return _split;
}

#pragma mark - RNNativeBaseNavigator

- (void)didFullScreenChangedWithScene:(RNNativeScene *)scene {
    // fullScreen is valid only for split mode
    if (!_split) {
        return;
    }
    
    // determine whether scene is in the navigator
    NSInteger index = -1;
    for (UIView *view in [self.viewController.view subviews]) {
        if ([view isKindOfClass:[RNNativeScene class]]) {
            index++;
            if (scene == view) {
                break;
            }
        }
    }
    if (index < 0) {
        return;
    }
    
    // update frame
    CGRect frame = [self getFrameWithParentBounds:self.viewController.view.bounds index:index fullScreen:scene.splitFullScreen split:self.split primarySceneWidth:self.primarySceneWidth];
    [UIView animateWithDuration:RNNativeNavigateDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        scene.frame = frame;
    } completion:^(BOOL finished) {
        if (!finished) {
            scene.frame = frame;
        }
    }];
}

- (BOOL)isDismissedForViewController:(UIViewController *)viewController {
    return viewController && ![_viewControllers containsObject:viewController];
}

/**
 addChildViewController removeFromParentViewController
 */
- (void)updateSceneWithTransition:(RNNativeSceneTransition)transition
                           action:(RNNativeStackNavigatorAction)action
                       nextScenes:(NSArray<RNNativeScene *> *)nextScenes
                    removedScenes:(NSArray<RNNativeScene *> *)removedScenes
                   insertedScenes:(NSArray<RNNativeScene *> *)insertedScenes
                  beginTransition:(RNNativeNavigatorTransitionBlock)beginTransition
                    endTransition:(RNNativeNavigatorTransitionBlock)endTransition {
    NSArray<RNNativeScene *> *primaryScenes = nextScenes.count > 0 ? @[nextScenes[0]] : nil;
    beginTransition(YES, primaryScenes);
    
    // viewControllers
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (RNNativeScene *scene in nextScenes) {
        [viewControllers addObject:scene.controller];
    }
    [_viewControllers setArray:viewControllers];

    // update will show view frame
    NSInteger currentTopSceneIndex = self.currentScenes.count - 1;
    RNNativeScene *currentTopScene = currentTopSceneIndex >= 0 ? self.currentScenes[currentTopSceneIndex] : nil;
    NSInteger nextTopSceneIndex = nextScenes.count - 1;
    RNNativeScene *nextTopScene = nextTopSceneIndex >= 0 ? nextScenes[nextTopSceneIndex] : nil;
    if (action == RNNativeStackNavigatorActionShow && transition != RNNativeSceneTransitionNone) {
        nextTopScene.frame = [self getBeginFrameWithParentBounds:self.viewController.view.bounds transition:transition index:nextTopSceneIndex fullScreen:nextTopScene.splitFullScreen split:self.split primarySceneWidth:self.primarySceneWidth];
    }
    
    // add scene
    for (NSInteger index = 0, size = nextScenes.count; index < size; index++) {
        RNNativeScene *scene = nextScenes[index];
        // 顶部两层 scene 必须显示，否则手势返回不好处理
        // 分屏状态第一页必须显示
        if (index + 2 < size && !(_split && index == 0)) {
            RNNativeScene *nextScene = nextScenes[index + 1];
            if (!nextScene.transparent) { // 上层 scene 透明时才显示
                continue;
            }
        }
        [self addScene:scene index:index split:self.split primarySceneWidth:self.primarySceneWidth];
    }
    
    // transition
    if (transition == RNNativeSceneTransitionNone || action == RNNativeStackNavigatorActionNone) {
        nextTopScene.frame = [self getFrameWithParentBounds:self.viewController.view.bounds index:nextTopSceneIndex fullScreen:nextTopScene.splitFullScreen split:self.split primarySceneWidth:self.primarySceneWidth];
        [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes split:self.split];
        endTransition(YES, primaryScenes);
    } else if (action == RNNativeStackNavigatorActionShow) {
        [UIView animateWithDuration:RNNativeNavigateDuration animations:^{
            nextTopScene.frame = [self getFrameWithParentBounds:self.viewController.view.bounds index:nextTopSceneIndex fullScreen:nextTopScene.splitFullScreen split:self.split primarySceneWidth:self.primarySceneWidth];
        } completion:^(BOOL finished) {
            if (!finished) {
                nextTopScene.frame = [self getFrameWithParentBounds:self.viewController.view.bounds index:nextTopSceneIndex fullScreen:nextTopScene.splitFullScreen split:self.split primarySceneWidth:self.primarySceneWidth];
            }
            [nextTopScene.controller didMoveToParentViewController:self.viewController];
            [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes split:self.split];
            endTransition(YES, primaryScenes);
        }];
    } else if (action == RNNativeStackNavigatorActionHide) {
        [currentTopScene.superview bringSubviewToFront:currentTopScene];
        [currentTopScene.controller willMoveToParentViewController:nil];
        [UIView animateWithDuration:RNNativeNavigateDuration animations:^{
            currentTopScene.frame = [self getBeginFrameWithParentBounds:self.viewController.view.bounds transition:transition index:currentTopSceneIndex fullScreen:currentTopScene.splitFullScreen split:self.split primarySceneWidth:self.primarySceneWidth];
        } completion:^(BOOL finished) {
            if (!finished) {
                nextTopScene.frame = [self getFrameWithParentBounds:self.viewController.view.bounds index:nextTopSceneIndex fullScreen:nextTopScene.splitFullScreen split:self.split primarySceneWidth:self.primarySceneWidth];
            }
            [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes split:self.split];
            endTransition(YES, primaryScenes);
        }];
    }
}

#pragma mark - Layout

/**
 primarySceneWidth 变化时，scene 的 x y size 都要变
 */
- (void)updateScenesFrame {
    NSArray *subviews = self.viewController.view.subviews;
    NSInteger sceneIndex = 0;
    for (NSInteger index = 0, size = subviews.count; index < size; index++) {
        UIView *view = subviews[index];
        if ([view isKindOfClass:[RNNativeScene class]]) {
            RNNativeScene *scene = (RNNativeScene *)view;
            view.frame = [self getFrameWithParentBounds:self.viewController.view.bounds index:sceneIndex fullScreen:scene.splitFullScreen split:self.split primarySceneWidth:self.primarySceneWidth];
            sceneIndex++;
        }
    }
}

/**
 屏幕宽高变化时，只改变 scene 的宽高，不改变 x 和 y
 */
- (void)updateScenesSize {
    NSArray *subviews = self.viewController.view.subviews;
    CGRect bounds = self.viewController.view.bounds;
    NSInteger sceneIndex = 0;
    for (NSInteger index = 0, size = subviews.count; index < size; index++) {
        UIView *view = subviews[index];
        if ([view isKindOfClass:[RNNativeScene class]]) {
            RNNativeScene *scene = (RNNativeScene *)view;
            CGRect frame = scene.frame;
            if (_split && !scene.splitFullScreen) {
                if (index == 0) {
                    view.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), _primarySceneWidth, CGRectGetHeight(bounds));
                } else {
                    view.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(bounds) - _primarySceneWidth, CGRectGetHeight(bounds));
                }
            } else {
                view.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(bounds), CGRectGetHeight(bounds));
            }
            sceneIndex++;
        }
    }
}

#pragma mark - Private

- (NSArray<RNNativeSplitRule *> *)parseSplitRules:(NSArray<NSDictionary *> *)splitRules {
    NSMutableArray *rules = [NSMutableArray array];
    [splitRules enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RNNativeSplitRule *rule = [RNNativeSplitRule new];
        rule.primarySceneWidth = [obj[@"primarySceneWidth"] floatValue];
        NSArray<NSNumber *> *navigatorWidthRange = obj[@"navigatorWidthRange"];
        rule.navigatorWidthBegin = navigatorWidthRange.count > 0 ? [navigatorWidthRange[0] floatValue] : 0;
        rule.navigatorWidthEnd = navigatorWidthRange.count > 1 ? [navigatorWidthRange[1] floatValue] : CGFLOAT_MAX;
        [rules addObject:rule];
    }];
    return rules;
}

- (CGFloat)getPrimarySceneWidthWithRules:(NSArray<RNNativeSplitRule *> *)rules navigatorWidth:(CGFloat)navigatorWidth {
    for (RNNativeSplitRule *rule in rules) {
        if (rule.navigatorWidthBegin < rule.navigatorWidthEnd
            && rule.navigatorWidthEnd > 0
            && navigatorWidth >= rule.navigatorWidthBegin
            && navigatorWidth <= rule.navigatorWidthEnd
            && rule.primarySceneWidth < navigatorWidth) {
            return rule.primarySceneWidth;
        }
    }
    return 0;
}

@end
