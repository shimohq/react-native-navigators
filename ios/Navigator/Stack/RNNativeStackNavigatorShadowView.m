//
//  RNNativeStackNavigatorShadowView.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/14.
//

#import "RNNativeStackNavigatorShadowView.h"
#import "RNNativeSceneShadowView.h"


@implementation RNNativeStackNavigatorShadowView

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

@end
