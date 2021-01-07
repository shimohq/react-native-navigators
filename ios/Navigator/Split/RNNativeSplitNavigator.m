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

@interface RNNativeSplitRule : NSObject

@property(nonatomic, assign) CGFloat primarySceneWidth;
@property(nonatomic, assign) CGFloat navigatorWidthBegin;
@property(nonatomic, assign) CGFloat navigatorWidthEnd;

@end

@implementation RNNativeSplitRule

@end

@interface RNNativeSplitNavigator() <RNNativeSplitNavigatorControllerDelegate, RNNativeSplitNavigatorControllerDataSource>

@property (nonatomic, strong) RNNativeSplitNavigatorController *controller;
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
    _controller = [RNNativeSplitNavigatorController new];
    _controller.delegate = self;
    _controller.dataSource = self;
    self = [super initWithBridge:bridge viewController:_controller];
    if (self) {
        _viewControllers = [NSMutableArray array];
        _updating = NO;
        
        _splitRules = nil;
        _rules = [self parseSplitRules:_splitRules];
        _navigatorBounds = _controller.view.bounds;
        _navigatorWidth = CGRectGetWidth(_controller.view.frame);
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
    for (UIView *view in [_controller.view subviews]) {
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
    CGRect frame = [self getFrameWithParentBounds:_controller.view.bounds index:index fullScreen:scene.splitFullScreen];
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
        nextTopScene.frame = [self getBeginFrameWithParentBounds:_controller.view.bounds transition:transition index:nextTopSceneIndex fullScreen:nextTopScene.splitFullScreen];
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
        [self addScene:scene index:index];
    }
    
    // transition
    if (transition == RNNativeSceneTransitionNone || action == RNNativeStackNavigatorActionNone) {
        nextTopScene.frame = [self getFrameWithParentBounds:self.controller.view.bounds index:nextTopSceneIndex fullScreen:nextTopScene.splitFullScreen];
        [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes];
        endTransition(YES, primaryScenes);
    } else if (action == RNNativeStackNavigatorActionShow) {
        [UIView animateWithDuration:RNNativeNavigateDuration animations:^{
            nextTopScene.frame = [self getFrameWithParentBounds:self.controller.view.bounds index:nextTopSceneIndex fullScreen:nextTopScene.splitFullScreen];
        } completion:^(BOOL finished) {
            if (!finished) {
                nextTopScene.frame = [self getFrameWithParentBounds:self.controller.view.bounds index:nextTopSceneIndex fullScreen:nextTopScene.splitFullScreen];
            }
            [nextTopScene.controller didMoveToParentViewController:self.controller];
            [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes];
            endTransition(YES, primaryScenes);
        }];
    } else if (action == RNNativeStackNavigatorActionHide) {
        [currentTopScene.superview bringSubviewToFront:currentTopScene];
        [currentTopScene.controller willMoveToParentViewController:nil];
        [UIView animateWithDuration:RNNativeNavigateDuration animations:^{
            currentTopScene.frame = [self getBeginFrameWithParentBounds:self.controller.view.bounds transition:transition index:currentTopSceneIndex fullScreen:currentTopScene.splitFullScreen];
        } completion:^(BOOL finished) {
            if (!finished) {
                nextTopScene.frame = [self getFrameWithParentBounds:self.controller.view.bounds index:nextTopSceneIndex fullScreen:nextTopScene.splitFullScreen];
            }
            [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes];
            endTransition(YES, primaryScenes);
        }];
    }
}

#pragma mark - Layout

- (void)addScene:(RNNativeScene *)scene index:(NSInteger)index {
    UIView *superView = [scene superview];
    if (superView && superView != _controller.view) {
        [scene removeFromSuperview];
        superView = nil;
    }
    
    UIViewController *parentViewController = [scene.controller parentViewController];
    if (parentViewController && parentViewController != _controller) {
        [scene.controller removeFromParentViewController];
        parentViewController = nil;
    }
    
    if (!parentViewController) {
        [_controller addChildViewController:scene.controller];
    }
    
    if (superView) {
        [_controller.view bringSubviewToFront:scene];
    } else {
        [_controller.view addSubview:scene];
    }
    
    CGRect frame = scene.frame;
    CGRect bounds = _controller.view.bounds;
    if (_split) {
        if (index == 0) {
            scene.frame = CGRectMake(frame.origin.x, frame.origin.y, _primarySceneWidth, bounds.size.height);
            scene.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        } else {
            scene.frame = CGRectMake(frame.origin.x, frame.origin.y, bounds.size.width - _primarySceneWidth, bounds.size.height);
            scene.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        }
    } else {
        scene.frame = CGRectMake(frame.origin.x, frame.origin.y, bounds.size.width, bounds.size.height);
        scene.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
}

- (void)removeScene:(RNNativeScene *)scene {
    [scene removeFromSuperview];
    [scene.controller removeFromParentViewController];
}

- (void)removeScenes:(NSArray<RNNativeScene *> *)scenes {
    for (RNNativeScene *scene in scenes) {
        [self removeScene:scene];
    }
}

- (void)removeScenesWithRemovedScenes:(NSArray<RNNativeScene *> *)removedScenes nextScenes:(NSArray<RNNativeScene *> *)nextScenes {
    for (RNNativeScene *scene in removedScenes) {
        [self removeScene:scene];
    }
    // 顶部两层 scene 必须显示，否则手势返回不好处理
    for (NSInteger index = 0, size = nextScenes.count; index < size - 2; index++) {
        // 分屏状态第一页必须显示
        if (_split && index == 0) {
            continue;
        }
        RNNativeScene *scene = nextScenes[index];
        RNNativeScene *nextScene = nextScenes[index + 1];
        if (!nextScene.transparent) { // 上层 scene 不透明时移除
            [self removeScene:scene];
        }
    }
}

/**
 primarySceneWidth 变化时，scene 的 x y size 都要变
 */
- (void)updateScenesFrame {
    NSArray *subviews = _controller.view.subviews;
    NSInteger sceneIndex = 0;
    for (NSInteger index = 0, size = subviews.count; index < size; index++) {
        UIView *view = subviews[index];
        if ([view isKindOfClass:[RNNativeScene class]]) {
            RNNativeScene *scene = (RNNativeScene *)view;
            view.frame = [self getFrameWithParentBounds:_controller.view.bounds index:sceneIndex fullScreen:scene.splitFullScreen];
            sceneIndex++;
        }
    }
}

/**
 屏幕宽高变化时，只改变 scene 的宽高，不改变 x 和 y
 */
- (void)updateScenesSize {
    NSArray *subviews = _controller.view.subviews;
    CGRect bounds = _controller.view.bounds;
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

- (CGRect)getBeginFrameWithParentBounds:(CGRect)bounds transition:(RNNativeSceneTransition)transition index:(NSInteger)index fullScreen:(BOOL)fullScreen {
    CGRect frame;
    CGFloat width;
    CGFloat minX;
    if (_split && !fullScreen) {
        minX = index == 0 ? 0 : _primarySceneWidth;
        width = index == 0 ? _primarySceneWidth : (CGRectGetWidth(bounds) - _primarySceneWidth);
    } else {
        minX = CGRectGetMinX(bounds);
        width = CGRectGetWidth(bounds);
    }
    
    switch (transition) {
        case RNNativeSceneTransitionSlideFormRight:
            frame = CGRectMake(CGRectGetMaxX(bounds), CGRectGetMinY(bounds), width, CGRectGetHeight(bounds));
            break;
        case RNNativeSceneTransitionSlideFormLeft:
            frame = CGRectMake(-CGRectGetMaxX(bounds), CGRectGetMinY(bounds), width, CGRectGetHeight(bounds));
            break;
        case RNNativeSceneTransitionSlideFormTop:
            frame = CGRectMake(minX, -CGRectGetMaxY(bounds), width, CGRectGetHeight(bounds));
            break;
        case RNNativeSceneTransitionSlideFormBottom:
        case RNNativeSceneTransitionDefault:
            frame = CGRectMake(minX, CGRectGetMaxY(bounds), width, CGRectGetHeight(bounds));
            break;
        default:
            frame = bounds;
            break;
    }
    return frame;
}

- (CGRect)getFrameWithParentBounds:(CGRect)bounds index:(NSInteger)index fullScreen:(BOOL)fullScreen {
    if (_split && !fullScreen) {
        if (index == 0) {
            return CGRectMake(0, 0, _primarySceneWidth, CGRectGetHeight(bounds));
        } else {
            return CGRectMake(_primarySceneWidth, 0, CGRectGetWidth(bounds) - _primarySceneWidth, CGRectGetHeight(bounds));
        }
    } else {
        return bounds;
    }
}

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
