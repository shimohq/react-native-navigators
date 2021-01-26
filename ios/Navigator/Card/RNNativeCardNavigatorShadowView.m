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
@property (nonatomic, assign) CGFloat navigatorWidth;

@end

@implementation RNNativeCardNavigatorShadowView

- (instancetype)initWithBridge:(RCTBridge *)bridge {
    self = [super init];
    if (self) {
        _bridge = bridge;
        _navigatorWidth = self.layoutMetrics.frame.size.width;

        [bridge.uiManager.observerCoordinator addObserver:self];
    }
    return self;
}

#pragma mark - RCTShadowView

- (void)insertReactSubview:(RCTShadowView *)subview atIndex:(NSInteger)atIndex {
    [super insertReactSubview:subview atIndex:atIndex];
    
    if ([subview isKindOfClass:[RNNativeSceneShadowView class]]) {
        if (self.navigatorWidth > 0) {
            RCTShadowView *taregetShadowView;
            RNNativeSceneShadowView *sceneShadowView = (RNNativeSceneShadowView *)subview;
            if (sceneShadowView.splitFullScreen) {
                taregetShadowView = [self findSplitNavigatorShadowView:self] ?: self;
            } else {
                taregetShadowView = self;
            }
            CGFloat width = CGRectGetWidth(taregetShadowView.layoutMetrics.frame);
            if (width > 0) {
                [sceneShadowView setLeft:YGValueZero];
                [sceneShadowView setRight:YGValueUndefined];
                [sceneShadowView setWidth:(YGValue){width,YGUnitPoint}];
            }
        }
    }
}

#pragma mark - RCTUIManagerObserver

- (void)uiManagerDidPerformLayout:(RCTUIManager *)manager {
    [self setNavigatorWidth:self.layoutMetrics.frame.size.width];
}

#pragma mark - Setter

//- (void)setLayoutMetrics:(RCTLayoutMetrics)layoutMetrics {
//    [super setLayoutMetrics:layoutMetrics];
//
////    [self setNavigatorWidth:layoutMetrics.frame.size.width];
//}

//- (void)layoutSubviewsWithContext:(RCTLayoutContext)layoutContext {
//    [super layoutSubviewsWithContext:layoutContext];
//
//    NSLog(@"layoutMetrics: layoutSubviewsWithContext: %@", self);
//
//    [self setNavigatorWidth:CGRectGetWidth(self.layoutMetrics.frame)];
//}

- (void)setNavigatorWidth:(CGFloat)navigatorWidth {
    if (_navigatorWidth == navigatorWidth) {
        return;
    }
    _navigatorWidth = navigatorWidth;
    
    [self updateSubShadowViews];
}

- (void)updateSubShadowViews {
    if (_navigatorWidth <= 0) {
        return;
    }
    RCTExecuteOnMainQueue(^{
        RCTExecuteOnUIManagerQueue(^{
            for (RCTShadowView *shadowView in self.reactSubviews) {
                if ([shadowView isKindOfClass:[RNNativeSceneShadowView class]]) {
                    RCTShadowView *taregetShadowView;
                    RNNativeSceneShadowView *sceneShadowView = (RNNativeSceneShadowView *)shadowView;
                    if (sceneShadowView.splitFullScreen) {
                        taregetShadowView = [self findSplitNavigatorShadowView:sceneShadowView] ?: self;
                    } else {
                        taregetShadowView = self;
                    }
                    CGFloat width = CGRectGetWidth(taregetShadowView.layoutMetrics.frame);
                    NSLog(@"Card Width: %f", width);
                    if (width > 0) {
                        [sceneShadowView setLeft:YGValueZero];
                        [sceneShadowView setRight:YGValueUndefined];
                        [sceneShadowView setWidth:(YGValue){width,YGUnitPoint}];
                    }
                }
            }
            [self.bridge.uiManager setNeedsLayout];
        });
    });
}

#pragma mark - Private

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
