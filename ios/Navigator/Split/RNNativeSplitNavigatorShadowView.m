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
    [self updateSubShadowViews];
}

- (void)setSplitRules:(NSArray<NSDictionary *> *)splitRules {
    if ([_splitRules isEqualToArray:splitRules]) {
        return;
    }
    _splitRules = splitRules;
    _rules = [RNNativeSplitUtils parseSplitRules:_splitRules];
    [self setPrimarySceneWidth:[RNNativeSplitUtils getPrimarySceneWidthWithRules:_rules navigatorWidth:_navigatorWidth]];
}

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
        [subview setDisplay: self.split ? YGDisplayFlex : YGDisplayNone];
        [self updateShadowView:subview index:1 fullScreen:NO split:self.split primarySceneWidth:self.primarySceneWidth];
    } else if ([subview isKindOfClass:[RNNativeSceneShadowView class]]) {
        RNNativeSceneShadowView *sceneShadowView = (RNNativeSceneShadowView*)subview;
        sceneShadowView.delegate = self;
        NSInteger sceneIndex = 0;
        for (NSInteger index = 0; index < atIndex; index++) {
            RCTShadowView *shadowView = self.reactSubviews[index];
            if ([shadowView isKindOfClass:[RNNativeSceneShadowView class]]) {
                sceneIndex++;
            }
        }
        [self updateShadowView:sceneShadowView index:sceneIndex fullScreen:sceneShadowView.splitFullScreen split:self.split primarySceneWidth:self.primarySceneWidth];
    }
}

#pragma mark - RNNativeSceneShadowViewDelegate

- (void)didSplitFullScrennChanged:(RNNativeSceneShadowView *)sceneShadowView {
    NSInteger sceneIndex = -1;
    for (NSInteger index = 0, size = self.reactSubviews.count; index < size; index++) {
        RCTShadowView *shadowView = self.reactSubviews[index];
        if ([shadowView isKindOfClass:[RNNativeSceneShadowView class]]) {
            sceneIndex++;
        }
        if (sceneShadowView == shadowView) {
            break;
        }
    }
    
    RCTLayoutAnimation *layoutAnimation = [[RCTLayoutAnimation alloc] initWithDuration:RNNativeNavigateDuration
                                                                                                 delay:0.0
                                                                                              property:@"fullScreen"
                                                                                         springDamping:0.0
                                                                                       initialVelocity:0.0
                                                                                         animationType:RCTAnimationTypeEaseInEaseOut];
    RCTLayoutAnimationGroup *layoutAnimationGroup = [[RCTLayoutAnimationGroup alloc] initWithCreatingLayoutAnimation:nil updatingLayoutAnimation:layoutAnimation deletingLayoutAnimation:nil callback:^(NSArray *response) {}];
    RCTExecuteOnMainQueue(^{
        [self.bridge.uiManager setNextLayoutAnimationGroup:layoutAnimationGroup];
    });
    
    [self updateShadowView:sceneShadowView index:sceneIndex fullScreen:sceneShadowView.splitFullScreen split:self.split primarySceneWidth:self.primarySceneWidth];
}

#pragma mark - Private

- (void)updateSubShadowViews {
    if (self.navigatorWidth <= 0) {
        return;
    }
    // INFO 必须要切线程，否则会报 dirtyNode 错误
    RCTExecuteOnMainQueue(^{
        RCTExecuteOnUIManagerQueue(^{
            NSInteger index = -1;
            for (RCTShadowView *shadowView in self.reactSubviews) {
                if ([shadowView isKindOfClass:[RNNativeSplitPlaceholderShadowView class]]) {
                    [shadowView setDisplay:self.split ? YGDisplayFlex : YGDisplayNone];
                    [self updateShadowView:shadowView index:1 fullScreen:NO split:self.split primarySceneWidth:self.primarySceneWidth];
                } else if ([shadowView isKindOfClass:[RNNativeSceneShadowView class]]) {
                    index++;
                    RNNativeSceneShadowView *sceneShadowView = (RNNativeSceneShadowView *)shadowView;
                    [self updateShadowView:sceneShadowView index:index fullScreen:sceneShadowView.splitFullScreen split:self.split primarySceneWidth:self.primarySceneWidth];
                }
            }
            [self.bridge.uiManager setNeedsLayout];
        });
    });
}

- (void)updateShadowView:(RCTShadowView *)shadowView
                   index:(NSInteger)index
              fullScreen:(BOOL)fullScreen
                   split:(BOOL)split
       primarySceneWidth:(CGFloat)primarySceneWidth {
    if (split && !fullScreen) {
        if (index == 0) {
            [shadowView setLeft:YGValueZero];
            [shadowView setRight:YGValueUndefined];
            [shadowView setWidth:(YGValue){primarySceneWidth,YGUnitPoint}];
        } else {
            [shadowView setLeft:(YGValue){primarySceneWidth,YGUnitPoint}];
            [shadowView setWidth:(YGValue){_navigatorWidth - primarySceneWidth,YGUnitPoint}];
            [shadowView setRight:YGValueUndefined];
        }
    } else {
        [shadowView setLeft:YGValueZero];
        [shadowView setWidth:(YGValue){_navigatorWidth, YGUnitPoint}];
        [shadowView setRight:YGValueUndefined];
    }
}

@end
