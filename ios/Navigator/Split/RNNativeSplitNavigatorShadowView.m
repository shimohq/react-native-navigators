//
//  RNNativeSplitNavigatorShadowView.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/14.
//

#import "RNNativeSplitNavigatorShadowView.h"
#import "RNNativeSplitRule.h"
#import "RNNativeSplitUtils.h"
#import "RNNativeSceneShadowView.h"
#import "RNNativeSplitPlaceholderShadowView.h"
#import "RNNativeConst.h"
#import "RNNativeSplitUtils.h"

#import <React/RCTShadowView.h>
#import <React/RCTUIManager.h>
#import <React/RCTUIManagerUtils.h>
#import <React/RCTUtils.h>
#import <React/RCTUIManagerObserverCoordinator.h>
#import <React/RCTLayoutAnimation.h>
#import <React/RCTLayoutAnimationGroup.h>

@interface RNNativeSplitNavigatorShadowView() <RNNativeSceneShadowViewDelegate, RCTUIManagerObserver>

@property (nonatomic, weak) RCTBridge *bridge;
@property (nonatomic, assign) CGFloat navigatorWidth;
@property (nonatomic, strong) NSArray<RNNativeSplitRule *> *rules;
@property (nonatomic, assign) CGFloat primarySceneWidth;
// whether split mode
@property (nonatomic, assign) BOOL split;

@end

@implementation RNNativeSplitNavigatorShadowView

- (instancetype)init {
    self = [super init];
    if (self) {
        _splitFullScreen = NO;
        _splitRules = nil;
        _rules = [RNNativeSplitUtils parseSplitRules:_splitRules];
        _navigatorWidth = CGRectGetWidth(self.layoutMetrics.frame);
        _primarySceneWidth = [RNNativeSplitUtils getPrimarySceneWidthWithRules:_rules navigatorWidth:_navigatorWidth];
        _split = _primarySceneWidth > 0;
    }
    return self;
}

- (instancetype)initWithBridge:(RCTBridge *)bridge {
    self = [self init];
    if (self) {
        _bridge = bridge;
        [bridge.uiManager.observerCoordinator addObserver:self];
    }
    return self;
}

- (void)dealloc {
    [self.bridge.uiManager.observerCoordinator removeObserver:self];
}

#pragma mark - RCTUIManagerObserver

- (void)uiManagerDidPerformLayout:(RCTUIManager *)manager {
    [self setNavigatorWidth:CGRectGetWidth(self.layoutMetrics.frame)];
}

#pragma mark - Setter

- (void)setNavigatorWidth:(CGFloat)navigatorWidth {
    if (_navigatorWidth == navigatorWidth) {
        return;
    }
    _navigatorWidth = navigatorWidth;
    [self setPrimarySceneWidth:[RNNativeSplitUtils getPrimarySceneWidthWithRules:_rules navigatorWidth:_navigatorWidth]];
    
    // update
    [self updateSubShadowViews];
}

- (void)setSplitRules:(NSArray<NSDictionary *> *)splitRules {
    if ([_splitRules isEqualToArray:splitRules]) {
        return;
    }
    _splitRules = splitRules;
    _rules = [RNNativeSplitUtils parseSplitRules:_splitRules];
    [self setPrimarySceneWidth:[RNNativeSplitUtils getPrimarySceneWidthWithRules:_rules navigatorWidth:_navigatorWidth]];
    
    // update
    [self updateSubShadowViews];
}

- (void)setSplitFullScreen:(BOOL)splitFullScreen {
    if (_splitFullScreen == splitFullScreen) {
        return;
    }
    _splitFullScreen = splitFullScreen;
    
    RCTLayoutAnimation *layoutAnimation = [[RCTLayoutAnimation alloc] initWithDuration:RNNativeNavigateDuration
                                                                                                 delay:0.0
                                                                                              property:@"fullScreen"
                                                                                         springDamping:0.0
                                                                                       initialVelocity:0.0
                                                                                         animationType:RCTAnimationTypeEaseInEaseOut];
    RCTLayoutAnimationGroup *layoutAnimationGroup = [[RCTLayoutAnimationGroup alloc] initWithCreatingLayoutAnimation:nil updatingLayoutAnimation:layoutAnimation deletingLayoutAnimation:nil callback:^(NSArray *response) {
        // 最顶层场景动画结束后更新其它场景
        [self updateSubShadowViews];
    }];
    RCTExecuteOnMainQueue(^{
        [self.bridge.uiManager setNextLayoutAnimationGroup:layoutAnimationGroup];
    });
    
    // 最顶层场景播放动画
    for (RCTShadowView *shadowView in self.reactSubviews.reverseObjectEnumerator) {
       if ([shadowView isKindOfClass:[RNNativeSceneShadowView class]]) {
           RNNativeSceneShadowView *sceneShadowView = (RNNativeSceneShadowView *)shadowView;
           if (!sceneShadowView.splitPrimary) {
               [self updateSceneShadowView:sceneShadowView];
           }
        }
    }
}

#pragma mark - Setter - Compute Result

- (void)setPrimarySceneWidth:(CGFloat)primarySceneWidth {
    if (_primarySceneWidth == primarySceneWidth) {
        return;
    }
    _primarySceneWidth = primarySceneWidth;
    _split = _primarySceneWidth > 0;
}

#pragma mark - RCTShadowView

- (void)insertReactSubview:(RCTShadowView *)subview atIndex:(NSInteger)atIndex {
    [super insertReactSubview:subview atIndex:atIndex];
    
    if (self.navigatorWidth <= 0) {
        return;
    }
    if ([subview isKindOfClass:[RNNativeSplitPlaceholderShadowView class]]) {
        [self updateSplitPlaceholderShadowView:(RNNativeSplitPlaceholderShadowView *)subview];
    } else if ([subview isKindOfClass:[RNNativeSceneShadowView class]]) {
        RNNativeSceneShadowView *sceneShadowView = (RNNativeSceneShadowView*)subview;
        sceneShadowView.delegate = self;
        [self updateSceneShadowView:sceneShadowView];
    }
}

#pragma mark - RNNativeSceneShadowViewDelegate

- (void)didSplitPrimaryChanged:(RNNativeSceneShadowView *)sceneShadowView {
    if (![self.reactSubviews containsObject:sceneShadowView]) {
        return;
    }
    
    RCTLayoutAnimation *layoutAnimation = [[RCTLayoutAnimation alloc] initWithDuration:RNNativeNavigateDuration
                                                                                                 delay:0.0
                                                                                              property:@"splitPrimary"
                                                                                         springDamping:0.0
                                                                                       initialVelocity:0.0
                                                                                         animationType:RCTAnimationTypeEaseInEaseOut];
    RCTLayoutAnimationGroup *layoutAnimationGroup = [[RCTLayoutAnimationGroup alloc] initWithCreatingLayoutAnimation:nil updatingLayoutAnimation:layoutAnimation deletingLayoutAnimation:nil callback:^(NSArray *response) {}];
    RCTExecuteOnMainQueue(^{
        [self.bridge.uiManager setNextLayoutAnimationGroup:layoutAnimationGroup];
    });
    [self updateSceneShadowView:sceneShadowView];
}

#pragma mark - Private

- (void)updateSubShadowViews {
    if (self.navigatorWidth <= 0) {
        return;
    }
    // INFO 必须要切线程，否则会报 dirtyNode 错误
    RCTExecuteOnMainQueue(^{
        RCTExecuteOnUIManagerQueue(^{
            for (RCTShadowView *shadowView in self.reactSubviews) {
                if ([shadowView isKindOfClass:[RNNativeSplitPlaceholderShadowView class]]) {
                    [self updateSplitPlaceholderShadowView:(RNNativeSplitPlaceholderShadowView *)shadowView];
                } else if ([shadowView isKindOfClass:[RNNativeSceneShadowView class]]) {
                    [self updateSceneShadowView:(RNNativeSceneShadowView *)shadowView];
                }
            }
            [self.bridge.uiManager setNeedsLayout];
        });
    });
}

- (void)updateSceneShadowView:(RNNativeSceneShadowView *)shadowView {
    [self updateShadowView:shadowView primary:shadowView.splitPrimary placeHolder:NO];
}

- (void)updateSplitPlaceholderShadowView:(RNNativeSplitPlaceholderShadowView *)shadowView {
    [self updateShadowView:shadowView primary:NO placeHolder:YES];
}

- (void)updateShadowView:(RCTShadowView *)shadowView
                 primary:(BOOL)primary
             placeHolder:(BOOL)placeHolder {
    // update whether show
    if (placeHolder) {
        [shadowView setDisplay:self.split ? YGDisplayFlex : YGDisplayNone];
    }
    
    // update layout
    if (self.split) {
        if (primary) { // 左边屏幕
            [shadowView setLeft:YGValueZero];
            [shadowView setRight:YGValueUndefined];
            [shadowView setWidth:(YGValue){self.primarySceneWidth,YGUnitPoint}];
        } else { // 右边屏幕
            if (self.splitFullScreen && !placeHolder) {
                // 全屏且非 placeHolder 的 scene 全屏展示
                [shadowView setLeft:YGValueZero];
                [shadowView setWidth:(YGValue){self.navigatorWidth, YGUnitPoint}];
                [shadowView setRight:YGValueUndefined];
            } else {
                CGFloat splitLineWidth = [RNNativeSplitUtils splitLineWidth];
                [shadowView setLeft:(YGValue){self.primarySceneWidth + splitLineWidth, YGUnitPoint}];
                [shadowView setWidth:(YGValue){self.navigatorWidth - self.primarySceneWidth - splitLineWidth, YGUnitPoint}];
                [shadowView setRight:YGValueUndefined];
            }
        }
    } else {
        [shadowView setLeft:YGValueZero];
        [shadowView setWidth:(YGValue){self.navigatorWidth, YGUnitPoint}];
        [shadowView setRight:YGValueUndefined];
    }
}

@end
