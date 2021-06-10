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

@end

@implementation RNNativeStackNavigatorShadowView

- (instancetype)initWithBridge:(RCTBridge *)bridge {
    self = [super init];
    if (self) {
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
    for (RCTShadowView *subview in self.reactSubviews) {
        if ([subview isKindOfClass:[RNNativeSceneShadowView class]]) {
            RNNativeSceneShadowView *shadowView = (RNNativeSceneShadowView *)subview;
            [shadowView setTopToWindow:topToWindow];
        }
    }
}

@end
