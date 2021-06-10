#import "RNNativeSceneShadowView.h"
#import "RNNativeStackHeaderShadowView.h"
#import "RNNativeStackNavigatorShadowView.h"

#import <React/RCTUIManagerUtils.h>
#import <React/RCTUtils.h>

@interface RNNativeSceneShadowView()

@property (nonatomic, assign) BOOL hasHeader;

@property (nonatomic, assign) CGFloat headerTop;
@property (nonatomic, assign) CGFloat headerHeight;

@property (nonatomic, assign) CGFloat sceneTop;

@end

@implementation RNNativeSceneShadowView

- (instancetype)initWithHeaderHeight:(CGFloat)headerHeight headerTop:(CGFloat)headerTop {
    self = [super init];
    if (self) {
        _headerTop = headerTop;
        _headerHeight = headerHeight;
        
        _topToWindow = headerTop;
        _inStack = NO;
        _sceneTop = 0;
    }
    return self;
}

#pragma mark - Setter

- (void)setInStack:(BOOL)inStack {
    if (_inStack == inStack) {
        return;
    }
    _inStack = inStack;
    [self updateSceneTop];
}

- (void)setTopToWindow:(CGFloat)topToRootWindow {
    if (_topToWindow == topToRootWindow) {
        return;
    }
    _topToWindow = topToRootWindow;
    [self updateSceneTop];
}

- (void)setHasHeader:(BOOL)hasHeader {
    if (_hasHeader == hasHeader) {
        return;
    }
    _hasHeader = hasHeader;
    [self updateSceneTop];
}

- (void)setSceneTop:(CGFloat)sceneTop {
    if (_sceneTop == sceneTop) {
        return;
    }
    _sceneTop = sceneTop;
    self.top = (YGValue){_sceneTop, YGUnitPoint};
}

- (void)setSplitPrimary:(BOOL)splitPrimary {
    if (_splitPrimary == splitPrimary) {
        return;
    }
    _splitPrimary = splitPrimary;
    [self.delegate didSplitPrimaryChanged:self];
}

#pragma mark - RCTShadowView

- (void)insertReactSubview:(RCTShadowView *)subview atIndex:(NSInteger)atIndex {
    [super insertReactSubview:subview atIndex:atIndex];
    if ([subview isKindOfClass:[RNNativeStackHeaderShadowView class]]) {
        RNNativeStackHeaderShadowView *headerShadowView = (RNNativeStackHeaderShadowView *)subview;
        [headerShadowView setTop:(YGValue){_headerTop, YGUnitPoint}];
        [headerShadowView setHeight:(YGValue){_headerHeight, YGUnitPoint}];
        self.hasHeader = YES;
    }
}

- (void)removeReactSubview:(RCTShadowView *)subview {
    [super removeReactSubview:subview];
    
    if ([subview isKindOfClass:[RNNativeStackHeaderShadowView class]]) {
        self.hasHeader = NO;
    }
}

#pragma mark - private

- (void)updateSceneTop {
    if (_inStack && _hasHeader) {
        [self setSceneTop: _headerHeight + (_topToWindow > _headerTop ? 0 : _headerTop)];
    } else {
        [self setSceneTop:0];
    }
}

@end
