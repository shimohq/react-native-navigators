#import "RNNativeStackHeader.h"
#import "RNNativeStackHeaderItem.h"

#import <React/RCTBridge.h>

static NSInteger RNNativeStackHeaderBottomBorderTag = 1024;

@implementation RNNativeStackHeader
{
    __weak UINavigationBar *_navigationBar;
    __weak UINavigationItem *_navigationItem;
    UIImage *_originalBackgroundImage;
    UIColor *_originalBarTintColor;
    UIColor *_originalHeaderBorderColor;
    
    UIImage *_backgroundImage;
    UIBarButtonItem *_leftBarButtonItem;
    UIBarButtonItem *_rightBarButtonItem;
}

- (void)didUpdateReactSubviews
{
    [self updateNavigationItem];
}

- (void)setHeaderBackgroundColor:(UIColor *)headerBackgroundColor
{
    _headerBackgroundColor = headerBackgroundColor;
    [self updateHeaderBackgroundColor:headerBackgroundColor];
}

- (void)setHeaderBorderColor:(UIColor *)headerBorderColor
{
    _headerBorderColor = headerBorderColor;
    [self updateHeaderBorderColor:_headerBorderColor];
}

- (void)attachViewController:(UIViewController *)viewController
{
    _navigationItem = viewController.navigationItem;
    _navigationBar = viewController.navigationController.navigationBar;
    
    [self updateHeaderBackgroundColor:_headerBackgroundColor];
    [self updateHeaderBorderColor:_headerBorderColor];
    [self updateNavigationItem];
}

- (void)detachViewController
{
    [self destroy];
    _navigationBar = nil;
    _navigationItem = nil;
}

- (void)invalidate
{
    // do nothing
}

- (void)destroy
{
    [self updateHeaderBackgroundColor:nil];
    [self updateHeaderBorderColor:nil];
}

#pragma mark - Private

- (void)updateNavigationItem
{
    if (!_navigationItem) {
        return;
    }
    _navigationItem.hidesBackButton = YES;
    
    UIView *titleView = nil;
    UIBarButtonItem *leftBarButtonItem = nil;
    UIBarButtonItem *rightBarButtonItem = nil;
    for (RNNativeStackHeaderItem *headerItem in self.reactSubviews) {
        switch (headerItem.type) {
            case RNNativeStackHeaderTypeCenter:
                titleView = headerItem;
                break;
            case RNNativeStackHeaderTypeLeft:
                if (!_leftBarButtonItem || _leftBarButtonItem.customView != headerItem) {
                    _leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:headerItem];
                }
                leftBarButtonItem = _leftBarButtonItem;
                break;
            case RNNativeStackHeaderTypeRight:
                if (!_rightBarButtonItem || _rightBarButtonItem.customView != headerItem) {
                    _rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:headerItem];
                }
                rightBarButtonItem = _rightBarButtonItem;
                break;
        }
    }
    _navigationItem.titleView = titleView;
    _navigationItem.leftBarButtonItem = leftBarButtonItem;
    _navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)updateHeaderBackgroundColor:(UIColor *)color
{
    if (!_navigationBar) {
        return;
    }
    if (color) {
        // back up
        _originalBackgroundImage = [_navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault];
        _originalBarTintColor = _navigationBar.barTintColor;
        
        // update
        if (CGColorGetAlpha(color.CGColor) == 0.) {
            if (!_backgroundImage) {
                _backgroundImage = [UIImage new];
            }
            [_navigationBar setBackgroundImage:_backgroundImage forBarMetrics:UIBarMetricsDefault];
            [_navigationBar setBarTintColor:[UIColor clearColor]];
        } else {
            [_navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            [_navigationBar setBarTintColor:color];
        }
    } else { // recover
        [_navigationBar setBackgroundImage:_originalBackgroundImage forBarMetrics:UIBarMetricsDefault];
        [_navigationBar setBarTintColor:_originalBarTintColor];
    }
}

- (void)updateHeaderBorderColor:(UIColor *)color
{
    if (!_navigationBar) {
        return;
    }
    UIView *bottomBorderRender = [_navigationBar viewWithTag:RNNativeStackHeaderBottomBorderTag];
    if (color) {
        if (!bottomBorderRender) {
            CGRect navigationBarFrame = _navigationBar.frame;
            CGRect bottomBorderRect = CGRectMake(CGRectGetMinX(navigationBarFrame), CGRectGetHeight(navigationBarFrame), CGRectGetWidth(navigationBarFrame), 1.0f / [UIScreen mainScreen].scale);
            bottomBorderRender = [[UIView alloc] initWithFrame:bottomBorderRect];
            bottomBorderRender.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            bottomBorderRender.tag = RNNativeStackHeaderBottomBorderTag;
            [_navigationBar addSubview:bottomBorderRender];
        } else {
            [_navigationBar bringSubviewToFront:bottomBorderRender];
        }
        // back up
        _originalHeaderBorderColor = bottomBorderRender.backgroundColor;
        // update
        [bottomBorderRender setBackgroundColor:color];
    } else { // recover
        if (bottomBorderRender) {
            [bottomBorderRender setBackgroundColor:_originalHeaderBorderColor];
        }
    }
}

@end
