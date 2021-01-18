#import "RNNativeStackNavigatorManager.h"
#import "RNNativeStackNavigator.h"
#import "RNNativeStackNavigatorShadowView.h"

#import <React/RCTUIManager.h>

@interface RNNativeStackNavigatorManager()

@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat headerTop;

@end

@implementation RNNativeStackNavigatorManager {
    NSPointerArray *_hostViews;
}


RCT_EXPORT_MODULE()

- (instancetype)init {
    self = [super init];
    if (self) {
        UINavigationController *navigationController = [[UINavigationController alloc] init];
        _headerHeight = CGRectGetHeight(navigationController.navigationBar.frame);
        _headerTop = [UIApplication sharedApplication].delegate.window.rootViewController.view.safeAreaInsets.top;
    }
    return self;
}

- (UIView *)view {
    RNNativeStackNavigator *view = [[RNNativeStackNavigator alloc] initWithBridge:self.bridge];
    if (!_hostViews) {
        _hostViews = [NSPointerArray weakObjectsPointerArray];
    }
    [_hostViews addPointer:(__bridge void *)view];
    return view;
}

- (RCTShadowView *)shadowView {
  return [[RNNativeStackNavigatorShadowView alloc] initWithHeaderHeight:_headerHeight headerTop:_headerTop];
}

#pragma mark - RCTInvalidating

- (void)invalidate {
    for (RNNativeStackNavigator *view in _hostViews) {
        [view invalidate];
    }
}

@end
