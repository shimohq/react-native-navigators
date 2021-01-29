//
//  RNNativeCardNavigatorShadowView.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/25.
//

#import "RNNativeCardNavigatorShadowView.h"
#import "RNNativeSplitNavigatorShadowView.h"
#import "RNNativeSceneShadowView.h"
#import "RNNativeCardNavigator.h"
#import "RNNativeConst.h"

#import "UIView+RNNativeNavigator.h"

#import <React/RCTUIManager.h>
#import <React/RCTUIManagerUtils.h>
#import <React/RCTUIManagerObserverCoordinator.h>
#import <React/RCTLayoutAnimation.h>
#import <React/RCTLayoutAnimationGroup.h>

@interface RNNativeCardNavigatorShadowView() <RCTUIManagerObserver>

@property (nonatomic, weak) RCTBridge *bridge;
@property (nonatomic, assign) CGSize navigatorSize;

@end

@implementation RNNativeCardNavigatorShadowView

- (instancetype)initWithBridge:(RCTBridge *)bridge {
    self = [super init];
    if (self) {
        _bridge = bridge;
        _navigatorSize = self.layoutMetrics.frame.size;
        
        [bridge.uiManager.observerCoordinator addObserver:self];
    }
    return self;
}

- (void)dealloc {
    [self.bridge.uiManager.observerCoordinator removeObserver:self];
}

#pragma mark - Public

- (void)updateShadowView:(RNNativeSceneShadowView *)shadowView {
    if (shadowView.splitFullScreen) {
        RCTShadowView *taregetShadowView = [self findSplitNavigatorShadowView:self] ?: self;
        
        CGRect relativeFrame = [shadowView.superview measureLayoutRelativeToAncestor:taregetShadowView];
        CGRect taregetFrame = taregetShadowView.layoutMetrics.frame;
        
        [shadowView setLeft:(YGValue){-CGRectGetMinX(relativeFrame),YGUnitPoint}];
        [shadowView setWidth:(YGValue){CGRectGetWidth(taregetFrame),YGUnitPoint}];
        [shadowView setRight:YGValueUndefined];
        
        [shadowView setTop:(YGValue){-CGRectGetMinY(relativeFrame),YGUnitPoint}];
        [shadowView setHeight:(YGValue){CGRectGetHeight(taregetFrame), YGUnitPoint}];
        [shadowView setBottom:YGValueUndefined];
    } else {
        [shadowView setLeft:YGValueZero];
        [shadowView setWidth:YGValueAuto];
        [shadowView setRight:YGValueZero];
        
        [shadowView setTop:YGValueZero];
        [shadowView setHeight:YGValueAuto];
        [shadowView setBottom:YGValueZero];
    }
}

#pragma mark - RCTShadowView

- (void)insertReactSubview:(RCTShadowView *)subview atIndex:(NSInteger)atIndex {
    [super insertReactSubview:subview atIndex:atIndex];
    
    if (!CGSizeEqualToSize(CGSizeZero, self.navigatorSize) && [subview isKindOfClass:[RNNativeSceneShadowView class]]) {
        RNNativeSceneShadowView *sceneShadowView = (RNNativeSceneShadowView *)subview;
        [self updateShadowView:sceneShadowView];
        [self.bridge.uiManager setNeedsLayout];
    }
}

#pragma mark - RCTUIManagerObserver

- (void)uiManagerDidPerformLayout:(RCTUIManager *)manager {
    [self setNavigatorSize:self.layoutMetrics.frame.size];
}

#pragma mark - Setter

- (void)setNavigatorSize:(CGSize)navigatorSize {
    if (CGSizeEqualToSize(_navigatorSize, navigatorSize)) {
        return;
    }
    _navigatorSize = navigatorSize;
    [self updateSubShadowViews];
}

- (void)updateSubShadowViews {
    if (CGSizeEqualToSize(CGSizeZero, self.navigatorSize)) {
        return;
    }
    RCTExecuteOnMainQueue(^{
        RCTExecuteOnUIManagerQueue(^{
            for (RCTShadowView *shadowView in self.reactSubviews) {
                if ([shadowView isKindOfClass:[RNNativeSceneShadowView class]]) {
                    RNNativeSceneShadowView *sceneShadowView = (RNNativeSceneShadowView *)shadowView;
                    [self updateShadowView:sceneShadowView];
                }
            }
            [self.bridge.uiManager setNeedsLayout];
        });
    });
}

#pragma mark - Private

- (nullable RNNativeSplitNavigatorShadowView *)findSplitNavigatorShadowView:(nullable RCTShadowView *)shadowView {
    if (!shadowView) {
        return nil;
    }
    if ([shadowView isKindOfClass:[RNNativeSplitNavigatorShadowView class]]) {
        return (RNNativeSplitNavigatorShadowView *)shadowView;
    }
    return [self findSplitNavigatorShadowView:shadowView.superview];
}

@end
