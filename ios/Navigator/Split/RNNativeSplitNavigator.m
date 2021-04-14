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
#import "RNNativeTransitionUtils.h"
#import "RNNativeConst.h"

#import <React/RCTShadowView.h>
#import <React/RCTRootShadowView.h>
#import <React/RCTUIManager.h>
#import <React/RCTUIManagerUtils.h>

#import "RNNativeBaseNavigator+Layout.h"

@interface RNNativeSplitNavigator() <RNNativeSplitNavigatorControllerDataSource>

@property (nonatomic, assign) BOOL updating;
@property (nonatomic, strong) NSArray<RNNativeSplitRule *> *rules;
@property (nonatomic, assign) CGFloat navigatorWidth;
@property (nonatomic, assign) CGFloat primarySceneWidth;
// whether split mode
@property (nonatomic, assign) BOOL split;
@property (nullable, nonatomic, strong) RNNativeSplitPlaceholder *splitPlaceholder;
@property (nullable, nonatomic, strong) UIView *splitLine;

@end

@implementation RNNativeSplitNavigator

- (instancetype)initWithBridge:(RCTBridge *)bridge {
    RNNativeSplitNavigatorController *viewController = [RNNativeSplitNavigatorController new];
    viewController.dataSource = self;
    self = [super initWithBridge:bridge viewController:viewController];
    if (self) {
        _updating = NO;
        
        _splitFullScreen = NO;
        _enableGestureWhenSplitFullScreen = NO;
        _splitRules = nil;
        _rules = [RNNativeSplitUtils parseSplitRules:_splitRules];
        _navigatorWidth = CGRectGetWidth(self.frame);
        _primarySceneWidth = [RNNativeSplitUtils getPrimarySceneWidthWithRules:_rules navigatorWidth:_navigatorWidth];
        _split = _primarySceneWidth > 0;
        
        _splitLine = [UIView new];
        [viewController.view addSubview:_splitLine];
        [self updateSplitLine];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setNavigatorWidth:CGRectGetWidth(self.bounds)];
    [self updateSplitLine];
}

- (void)updateSplitLine {
    if (self.split) {
        self.splitLine.frame = CGRectMake(self.primarySceneWidth, 0, [RNNativeSplitUtils splitLineWidth], CGRectGetHeight(self.frame));
        [self.splitLine setHidden:NO];
    } else {
        [self.splitLine setHidden:YES];
    }
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
    [self reloadScenes];
}

- (void)setSplitPlaceholder:(nullable RNNativeSplitPlaceholder *)splitPlaceholder {
    if (_splitPlaceholder == splitPlaceholder) {
        return;
    }
    _splitPlaceholder = splitPlaceholder;
   
    [self addSplitPlaceholder];
}

- (void)setSplitLineColor:(UIColor *)splitLineColor {
    if (!splitLineColor) {
        return;
    }
    _splitLineColor = splitLineColor;
    self.splitLine.backgroundColor = _splitLineColor;
}

#pragma mark - RNNativeSplitNavigatorControllerDataSource

- (BOOL)isSplit {
    return self.split;
}

- (BOOL)isSplitFullScreen {
    return self.splitFullScreen;
}

- (BOOL)isEnableGestureWhenSplitFullScreen {
    return self.enableGestureWhenSplitFullScreen;
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

- (void)updateSceneWithCurrentScenes:(NSArray<RNNativeScene *> *)currentScenes
                          nextScenes:(NSArray<RNNativeScene *> *)nextScenes
                        checkUpdated:(BOOL)checkUpdated
                           comoplete:(RNNativeNavigatorUpdateCompleteBlock)comoplete {
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
        [super updateSceneWithCurrentScenes:currentPrimaryScenes
                                 nextScenes:nextPrimaryScenes
                               checkUpdated:checkUpdated
                                  comoplete:completeBlock];
        [super updateSceneWithCurrentScenes:currentSecondaryScenes
                                 nextScenes:nextSecondaryScenes
                               checkUpdated:checkUpdated
                                  comoplete:completeBlock];
    } else {
        [super updateSceneWithCurrentScenes:currentScenes
                                 nextScenes:nextScenes
                               checkUpdated:checkUpdated
                                  comoplete:comoplete];
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
    
    // 分栏模式，右边屏幕
    // 第一个场景显示、最后的场景退出的时候需要有动画
    if (self.split) {
        if (currentScenes.count == 0 && nextScenes.count > 0) {
            // 第一个场景显示
            RNNativeScene *scene = nextScenes.lastObject;
            if (!scene.splitPrimary) {
                action = RNNativeStackNavigatorActionShow;
                transition = scene.transition;
            }
        } else if (nextScenes.count == 0 && currentScenes.count > 0) {
            // 最后的场景退出
            RNNativeScene *scene = currentScenes.lastObject;
            if (!scene.splitPrimary) {
                action = RNNativeStackNavigatorActionHide;
                transition = scene.transition;
            }
        }
    }
    
    // nextTopScene 用于进场动画
    NSInteger nextTopSceneIndex = nextScenes.count - 1;
    RNNativeScene *nextTopScene = nextTopSceneIndex >= 0 ? nextScenes[nextTopSceneIndex] : nil;
    
    // currentTopScene 用于退场动画
    NSInteger currentTopSceneIndex = currentScenes.count - 1;
    RNNativeScene *currentTopScene = currentTopSceneIndex >= 0 ? currentScenes[currentTopSceneIndex] : nil;
    
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
    
    // 无动画
    if (transition == RNNativeSceneTransitionNone || action == RNNativeStackNavigatorActionNone) {
        [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes];
        endTransition(YES);
        return;
    }
    
    // 有动画
    
    // 分栏模式动画开始前要把另外一边最顶层的 view 置顶，动画结束后还原
    UIView *coverView = nil;
    if (self.split) {
        RNNativeScene *scene = nextScenes.lastObject ?: currentScenes.lastObject;
        if (scene.splitPrimary) {
            for (RNNativeScene *otherScene in self.currentScenes.reverseObjectEnumerator) {
                if (!otherScene.splitPrimary) {
                    coverView = otherScene;
                    break;
                }
            }
            if (!coverView) {
                coverView = self.splitPlaceholder;
            }
        } else if (!self.splitFullScreen) {
            for (RNNativeScene *otherScene in self.currentScenes.reverseObjectEnumerator) {
                if (otherScene.splitPrimary) {
                    coverView = otherScene;
                    break;
                }
            }
        }
    }
    
    // 有动画显示
    if (action == RNNativeStackNavigatorActionShow) {
        // update will show view frame
        nextTopScene.frame = [self getBeginFrameWithScene:nextTopScene transition:transition];
        
        CGRect nextTopSceneEndFrame = [self getEndFrameWithScene:nextTopScene];
        
        CGRect currentTopSceneOriginalFrame = currentTopScene.frame;
        CGRect currentTopSceneEndFrame = [RNNativeTransitionUtils getDownViewFrameWithView:currentTopScene transition:transition];
        
        CGFloat coverViewOriginalZPosition = coverView.layer.zPosition;
        coverView.layer.zPosition = 1000;
        
        BOOL originalUserInteractionEnabled = self.userInteractionEnabled;
        self.userInteractionEnabled = NO;
        [UIView animateWithDuration:RNNativeNavigateDuration animations:^{
            nextTopScene.frame = nextTopSceneEndFrame;
            currentTopScene.frame = currentTopSceneEndFrame;
        } completion:^(BOOL finished) {
            if (!finished) {
                nextTopScene.frame = nextTopSceneEndFrame;
            }
            currentTopScene.frame = currentTopSceneOriginalFrame;
            coverView.layer.zPosition = coverViewOriginalZPosition;
            
            [nextTopScene setStatus:RNNativeSceneStatusDidFocus];
            [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes];
            
            self.userInteractionEnabled = originalUserInteractionEnabled;
            endTransition(YES);
        }];
        return;
    }
    
    // 有动画退出
    if (action == RNNativeStackNavigatorActionHide) {
        [currentTopScene.superview bringSubviewToFront:currentTopScene];
        [currentTopScene setStatus:RNNativeSceneStatusWillBlur];
        
        NSInteger currentSecondSceneIndex = currentScenes.count - 2;
        RNNativeScene *currentSecondScene = currentSecondSceneIndex >= 0 ? currentScenes[currentSecondSceneIndex] : nil;
        CGRect currentSecondSceneOriginalFrame = currentSecondScene.frame;
        currentSecondScene.frame = [RNNativeTransitionUtils getDownViewFrameWithView:currentSecondScene transition:transition];
        
        CGFloat coverViewOriginalZPosition = coverView.layer.zPosition;
        coverView.layer.zPosition = 1000;
        
        BOOL originalUserInteractionEnabled = self.userInteractionEnabled;
        self.userInteractionEnabled = NO;
        [UIView animateWithDuration:RNNativeNavigateDuration animations:^{
            currentTopScene.frame = [self getBeginFrameWithScene:currentTopScene
                                                      transition:transition];
            currentSecondScene.frame = currentSecondSceneOriginalFrame;
        } completion:^(BOOL finished) {
            if (!finished) {
                currentSecondScene.frame = currentSecondSceneOriginalFrame;
            }
            coverView.layer.zPosition = coverViewOriginalZPosition;
            [self removeScenesWithRemovedScenes:removedScenes nextScenes:nextScenes];
            
            self.userInteractionEnabled = originalUserInteractionEnabled;
            endTransition(YES);
        }];
    }
}

- (void)addScene:(RNNativeScene *)scene {
    if (self.split && scene.splitPrimary) {
        RNNativeScene *bottomSecondaryScene = nil;
        for (UIView *view in self.viewController.view.subviews) {
            if ([view isKindOfClass:[RNNativeScene class]]) {
                RNNativeScene *scene = (RNNativeScene *)view;
                if (!scene.splitPrimary) {
                    bottomSecondaryScene = scene;
                    break;
                }
            }
        }
        if (bottomSecondaryScene) {
            UIView *superView = [scene superview];
            if (superView) {
                [scene removeFromSuperview];
            }
            UIViewController *parentViewController = [scene.controller parentViewController];
            if (parentViewController && parentViewController != self.viewController) {
                [scene.controller removeFromParentViewController];
                parentViewController = nil;
            }
            
            if (!parentViewController) {
                [self.viewController addChildViewController:scene.controller];
            }
            [self.viewController.view insertSubview:scene belowSubview:bottomSecondaryScene];
        } else {
            [super addScene:scene];
        }
    } else {
        [super addScene:scene];
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
            frame.origin.x = self.primarySceneWidth + [RNNativeSplitUtils splitLineWidth];
        } else {
            frame.origin.x = self.splitFullScreen ? 0 : self.primarySceneWidth + [RNNativeSplitUtils splitLineWidth];
        }
    } else {
        frame.origin.x = 0;
    }
    frame.origin.y = 0;
    return frame;
}

@end
