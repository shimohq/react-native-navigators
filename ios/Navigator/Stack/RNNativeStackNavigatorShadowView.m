//
//  RNNativeStackNavigatorShadowView.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/14.
//

#import "RNNativeStackNavigatorShadowView.h"
#import "RNNativeSceneShadowView.h"

#import <React/RCTUIManager.h>
#import <React/RCTUIManagerUtils.h>
#import <React/RCTUIManagerObserverCoordinator.h>


@interface RNNativeStackNavigatorShadowView() <RCTUIManagerObserver>

@property (nonatomic, weak) RCTBridge *bridge;
@property (nonatomic, assign) CGFloat topToWindow;

@end

@implementation RNNativeStackNavigatorShadowView

- (instancetype)initWithBridge:(RCTBridge *)bridge {
    self = [super init];
    if (self) {
        _topToWindow = 0;
        _bridge = bridge;
        [bridge.uiManager.observerCoordinator addObserver:self];
    }
    return self;
}

- (void)dealloc {
    [self.bridge.uiManager.observerCoordinator removeObserver:self];
}

#pragma mark - RNNativeBaseNavigatorShadowView

- (void)insertReactSubview:(RCTShadowView *)subview atIndex:(NSInteger)atIndex {
    [super insertReactSubview:subview atIndex:atIndex];
    
    if ([subview isKindOfClass:[RNNativeSceneShadowView class]]) {
        RNNativeSceneShadowView *shadowView = (RNNativeSceneShadowView *)subview;
        [shadowView setInStack:YES];
        [shadowView setTopToWindow:_topToWindow];
    }
}

- (void)removeReactSubview:(RCTShadowView *)subview {
    [super removeReactSubview:subview];
}

#pragma mark - RCTUIManagerObserver

- (void)uiManagerDidPerformLayout:(RCTUIManager *)manager {
    CGRect frame = self.layoutMetrics.frame;
    
    float topToWindow = 0;
    RCTShadowView *shadowView = self;
    while (shadowView) {
        topToWindow += CGRectGetMinY(shadowView.layoutMetrics.frame);
        shadowView = shadowView.superview;
    }
    [self setTopToWindow:topToWindow];
}

#pragma mark - Setter

- (void)setTopToWindow:(CGFloat)topToWindow {
    if (_topToWindow == topToWindow) {
        return;
    }
    _topToWindow = topToWindow;
    for (RCTShadowView *subview in self.reactSubviews) {
        if ([subview isKindOfClass:[RNNativeSceneShadowView class]]) {
            RNNativeSceneShadowView *shadowView = (RNNativeSceneShadowView *)subview;
            [shadowView setTopToWindow:topToWindow];
        }
    }
}

@end
