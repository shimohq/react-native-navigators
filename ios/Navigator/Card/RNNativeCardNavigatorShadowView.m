//
//  RNNativeCardNavigatorShadowView.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/25.
//

#import "RNNativeCardNavigatorShadowView.h"
#import "RNNativeSplitNavigatorShadowView.h"
#import "RNNativeSceneShadowView.h"

#import "UIView+RNNativeNavigator.h"

#import <React/RCTUIManager.h>
#import <React/RCTUIManagerUtils.h>
#import <React/RCTUIManagerObserverCoordinator.h>

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

#pragma mark - RCTShadowView

- (void)insertReactSubview:(RCTShadowView *)subview atIndex:(NSInteger)atIndex {
    [super insertReactSubview:subview atIndex:atIndex];
    
    if (!CGSizeEqualToSize(CGSizeZero, self.navigatorSize) && [subview isKindOfClass:[RNNativeSceneShadowView class]]) {
        RNNativeSceneShadowView *sceneShadowView = (RNNativeSceneShadowView *)subview;
        [self updateShadowView:sceneShadowView withParentShadowView:self];
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
                    [self updateShadowView:sceneShadowView withParentShadowView:self];
                }
            }
            [self.bridge.uiManager setNeedsLayout];
        });
    });
}

#pragma mark - Private

- (void)updateShadowView:(RNNativeSceneShadowView *)shadowView withParentShadowView:(RCTShadowView *)parentShadowView {
    if (shadowView.splitFullScreen) {
        RCTShadowView *taregetShadowView = [self findSplitNavigatorShadowView:parentShadowView] ?: parentShadowView;
        CGRect frame = taregetShadowView.layoutMetrics.frame;
        
        [shadowView setLeft:YGValueZero];
        [shadowView setWidth:(YGValue){CGRectGetWidth(frame),YGUnitPoint}];
        [shadowView setRight:YGValueUndefined];
        
        [shadowView setTop:YGValueZero];
        [shadowView setHeight:(YGValue){CGRectGetHeight(frame), YGUnitPoint}];
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

- (RNNativeSplitNavigatorShadowView *)findSplitNavigatorShadowView:(RCTShadowView *)shadowView {
    if (!shadowView) {
        return nil;
    }
    if ([shadowView isKindOfClass:[RNNativeSplitNavigatorShadowView class]]) {
        return (RNNativeSplitNavigatorShadowView *)shadowView;
    }
    return [self findSplitNavigatorShadowView:shadowView.superview];
}

@end
