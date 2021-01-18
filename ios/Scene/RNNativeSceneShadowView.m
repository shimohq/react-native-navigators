#import "RNNativeSceneShadowView.h"
#import "RNNativeStackHeaderShadowView.h"
#import "RNNativeStackNavigatorShadowView.h"
#import "RNNativeNavigatorInsetsData.h"
#import "RNNativeNavigatorFrameData.h"

#import <React/RCTUIManagerUtils.h>
#import <React/RCTUtils.h>

@interface RNNativeSceneShadowView()

@property (nonatomic, assign) BOOL hasHeader;

@property (nonatomic, assign) CGFloat headerTop;
@property (nonatomic, assign) CGFloat headerHeight;

@property (nonatomic, assign) CGFloat sceneTop;

@end

@implementation RNNativeSceneShadowView

- (instancetype)init {
    self = [super init];
    if (self) {
        _status = RNNativeSceneStatusDidFocus;
        _headerTop = 0;
        _headerHeight = 0;
        _sceneTop = 0;
    }
    return self;
}

#pragma mark - Setter

- (void)setStatus:(RNNativeSceneStatus)status {
    if (_status == status) {
        return;
    }
    _status = status;
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

#pragma mark - RCTShadowView

- (void)insertReactSubview:(RCTShadowView *)subview atIndex:(NSInteger)atIndex {
    [super insertReactSubview:subview atIndex:atIndex];
    if ([subview isKindOfClass:[RNNativeStackHeaderShadowView class]]) {
        self.hasHeader = YES;
    }
}

- (void)removeReactSubview:(RCTShadowView *)subview {
    [super removeReactSubview:subview];
    
    if ([subview isKindOfClass:[RNNativeStackHeaderShadowView class]]) {
        self.hasHeader = NO;
    }
}

#pragma mark - public

- (void)updateWithHeaderTop:(CGFloat)headerTop headerHeight:(CGFloat)headerHeight {
    _headerTop = headerTop;
    _headerHeight = headerHeight;
    [self updateSceneTop];
}

#pragma mark - private

- (void)updateSceneTop {
    if (_hasHeader && (_status == RNNativeSceneStatusWillFocus || _status == RNNativeSceneStatusDidFocus)) {
        [self setSceneTop:_headerTop + _headerHeight];
    } else {
        [self setSceneTop:0];
    }
}

@end
