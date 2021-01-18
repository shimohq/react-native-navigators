//
//  RNNativeSplitNavigatorShadowView.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/14.
//

#import "RNNativeSplitNavigatorShadowView.h"
#import "RNNativeSplitRule.h"
#import "RNNativeSplitUtils.h"
#import "RNNativeNavigatorUtils.h"
#import "RNNativeSceneShadowView.h"
#import "RNNativeSplitPlaceholderShadowView.h"

#import <React/RCTShadowView.h>
#import <React/RCTUIManagerUtils.h>
#import <React/RCTUtils.h>

@interface RNNativeSplitNavigatorShadowView()

@property (nonatomic, assign) CGSize navigatorSize;
@property (nonatomic, assign) CGFloat navigatorWidth;
@property (nonatomic, strong) NSArray<RNNativeSplitRule *> *rules;
@property (nonatomic, assign) CGFloat primarySceneWidth;
// whether split mode
@property (nonatomic, assign) BOOL split;

@end

@implementation RNNativeSplitNavigatorShadowView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _splitRules = nil;
        _rules = [RNNativeSplitUtils parseSplitRules:_splitRules];
        _navigatorSize = self.layoutMetrics.frame.size;
        _navigatorSize = CGSizeEqualToSize(CGSizeZero, _navigatorSize) ? CGSizeMake(1024, 768) : _navigatorSize;
        _navigatorWidth = _navigatorSize.width;
        _primarySceneWidth = [RNNativeSplitUtils getPrimarySceneWidthWithRules:_rules navigatorWidth:_navigatorWidth];
        _split = _primarySceneWidth > 0;
    }
    return self;
}

#pragma mark - Setter

- (void)setLayoutMetrics:(RCTLayoutMetrics)layoutMetrics {
    [super setLayoutMetrics:layoutMetrics];
    [self setNavigatorSize:layoutMetrics.frame.size];
}

- (void)setNavigatorSize:(CGSize)navigatorSize {
    if (CGSizeEqualToSize(_navigatorSize, navigatorSize)) {
        return;
    }
    _navigatorSize = navigatorSize;
    [self setNavigatorWidth:_navigatorSize.width];
    [self updateSubShadowViews];
}

- (void)setNavigatorWidth:(CGFloat)navigatorWidth {
    if (_navigatorWidth == navigatorWidth) {
        return;
    }
    _navigatorWidth = navigatorWidth;
    [self setPrimarySceneWidth:[RNNativeSplitUtils getPrimarySceneWidthWithRules:_rules navigatorWidth:_navigatorWidth]];
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
    if (CGSizeEqualToSize(CGSizeZero, self.navigatorSize)) {
        return;
    }
    if ([subview isKindOfClass:[RNNativeSplitPlaceholderShadowView class]]) {
        [self updateShadowView:subview index:1 fullScreen:NO split:YES primarySceneWidth:_primarySceneWidth];
    } else if ([subview isKindOfClass:[RNNativeSceneShadowView class]]) {
        RNNativeSceneShadowView *sceneShadowView = (RNNativeSceneShadowView*)subview;
        NSInteger sceneIndex = 0;
        for (NSInteger index = 0; index < atIndex; index++) {
            RCTShadowView *shadowView = self.reactSubviews[index];
            if ([shadowView isKindOfClass:[RNNativeSceneShadowView class]]) {
                sceneIndex++;
            }
        }
        [self updateShadowView:sceneShadowView index:sceneIndex fullScreen:sceneShadowView.splitFullScreen split:_split primarySceneWidth:_primarySceneWidth];
    }
}

#pragma mark - Private

- (void)updateSubShadowViews {
    if (CGSizeEqualToSize(CGSizeZero, self.navigatorSize)) {
        return;
    }
    // INFO 必须要切线程，否则会报 dirtyNode 错误
    RCTExecuteOnMainQueue(^{
        RCTExecuteOnUIManagerQueue(^{
            NSInteger index = -1;
            for (RCTShadowView *shadowView in self.reactSubviews) {
                if (![shadowView isKindOfClass:[RNNativeSceneShadowView class]]) {
                    continue;
                }
                index++;
                RNNativeSceneShadowView *sceneShadowView = (RNNativeSceneShadowView *)shadowView;
                [self updateShadowView:sceneShadowView index:index fullScreen:sceneShadowView.splitFullScreen split:self.split primarySceneWidth:self.primarySceneWidth];
            }
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
            [shadowView setRight:YGValueZero];
            [shadowView setWidth:YGValueAuto];
        }
    } else {
        [shadowView setLeft:YGValueZero];
        [shadowView setRight:YGValueZero];
        [shadowView setWidth:YGValueAuto];
    }
}

@end
