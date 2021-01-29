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
    _split = primarySceneWidth > 0;
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
    return _split;
}

- (NSArray<RNNativeScene *> *)getCurrentScenes {
    return self.currentScenes;
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

    NSInteger currentTopSceneIndex = self.currentScenes.count - 1;
    RNNativeScene *currentTopScene = currentTopSceneIndex >= 0 ? self.currentScenes[currentTopSceneIndex] : nil;
    NSInteger nextTopSceneIndex = nextScenes.count - 1;
    RNNativeScene *nextTopScene = nextTopSceneIndex >= 0 ? nextScenes[nextTopSceneIndex] : nil;
    
    // update will show view frame
    if (action == RNNativeStackNavigatorActionShow) {
        nextTopScene.frame = [self getBeginFrameWithFrame:nextTopScene.frame
                                               transition:transition
                                                    index:nextTopSceneIndex
                                               fullScreen:nextTopScene.splitFullScreen
                                                    split:self.split
                                        primarySceneWidth:self.primarySceneWidth];
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
        [self addScene:scene];
    }
    
    // transition
    CGRect nextTopSceneEndFrame = [self getEndFrameWithFrame:nextTopScene.frame
                                                       index:nextTopSceneIndex
                                                  fullScreen:nextTopScene.splitFullScreen
                                                       split:self.split
                                           primarySceneWidth:self.primarySceneWidth];
    if (transition == RNNativeSceneTransitionNone || action == RNNativeStackNavigatorActionNone) {
        nextTopScene.frame = nextTopSceneEndFrame;
        [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes split:self.split];
        endTransition(YES, primaryScenes);
    } else if (action == RNNativeStackNavigatorActionShow) {
        [UIView animateWithDuration:RNNativeNavigateDuration animations:^{
            nextTopScene.frame = nextTopSceneEndFrame;
        } completion:^(BOOL finished) {
            if (!finished) {
                nextTopScene.frame = nextTopSceneEndFrame;
            }
            [nextTopScene setStatus:RNNativeSceneStatusDidFocus];
            [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes split:self.split];
            endTransition(YES, primaryScenes);
        }];
    } else if (action == RNNativeStackNavigatorActionHide) {
        [currentTopScene.superview bringSubviewToFront:currentTopScene];
        [currentTopScene setStatus:RNNativeSceneStatusWillBlur];
        [UIView animateWithDuration:RNNativeNavigateDuration animations:^{
            currentTopScene.frame = [self getBeginFrameWithFrame:currentTopScene.frame
                                                      transition:transition
                                                           index:currentTopSceneIndex
                                                      fullScreen:currentTopScene.splitFullScreen
                                                           split:self.split
                                               primarySceneWidth:self.primarySceneWidth];
        } completion:^(BOOL finished) {
            [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes split:self.split];
            endTransition(YES, primaryScenes);
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

#pragma mark - Private

- (CGRect)getBeginFrameWithFrame:(CGRect)frame
                      transition:(RNNativeSceneTransition)transition
                           index:(NSInteger)index
                      fullScreen:(BOOL)fullScreen
                           split:(BOOL)split
               primarySceneWidth:(CGFloat)primarySceneWidth {
    
    CGFloat width = CGRectGetWidth(frame);
    CGFloat height = CGRectGetHeight(frame);
    
    CGRect endFrame = [self getEndFrameWithFrame:frame index:index fullScreen:fullScreen split:split primarySceneWidth:primarySceneWidth];
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

- (CGRect)getEndFrameWithFrame:(CGRect)frame
                         index:(NSInteger)index
                    fullScreen:(BOOL)fullScreen
                         split:(BOOL)split
             primarySceneWidth:(CGFloat)primarySceneWidth {
    if (split && !fullScreen) {
        frame.origin.x = index == 0 ? 0 : primarySceneWidth;
    } else {
        frame.origin.x = 0;
    }
    frame.origin.y = 0;
    return frame;
}

@end
