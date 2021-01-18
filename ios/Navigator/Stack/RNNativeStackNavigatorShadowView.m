//
//  RNNativeStackNavigatorShadowView.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/14.
//

#import "RNNativeStackNavigatorShadowView.h"
#import "RNNativeSceneShadowView.h"
#import "RNNativeStackHeaderShadowView.h"
#import "RNNativeNavigatorUtils.h"

#import <React/RCTUIManager.h>
#import <React/RCTUIManagerUtils.h>
#import <React/RCTUtils.h>

@interface RNNativeStackNavigatorShadowView()

@property (nonatomic, assign) CGFloat headerTop;
@property (nonatomic, assign) CGFloat headerHeight;

@end

@implementation RNNativeStackNavigatorShadowView

- (instancetype)initWithHeaderHeight:(CGFloat)headerHeight headerTop:(CGFloat)headerTop {
    self = [super init];
    if (self) {
        _headerTop = headerTop;
        _headerHeight = headerHeight;
    }
    return self;
}

#pragma mark - RNNativeBaseNavigatorShadowView

- (void)insertReactSubview:(RCTShadowView *)subview atIndex:(NSInteger)atIndex {
    [super insertReactSubview:subview atIndex:atIndex];
    
    if ([subview isKindOfClass:[RNNativeSceneShadowView class]]) {
        RNNativeSceneShadowView *shadowView = (RNNativeSceneShadowView *)subview;
        [shadowView updateWithHeaderTop:self.headerTop headerHeight:self.headerHeight];
    }
}

- (void)removeReactSubview:(RCTShadowView *)subview {
    [super removeReactSubview:subview];
}

@end
