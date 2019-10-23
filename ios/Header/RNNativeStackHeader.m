#import "RNNativeStackHeader.h"
#import "RNNativeStackHeaderItem.h"

#import <React/RCTBridge.h>

@implementation RNNativeStackHeader
{
    __weak UINavigationBar *_navigationBar;
    __weak UINavigationItem *_navigationItem;
    UIImage *_backgroundImage;
    UIBarButtonItem *_leftBarButtonItem;
    UIBarButtonItem *_rightBarButtonItem;
    UIView *_bottomBorderRender;
}

- (void)didUpdateReactSubviews
{
    [self updateNavigationItem];
}

- (void)setHeaderBackgroundColor:(UIColor *)headerBackgroundColor
{
    _headerBackgroundColor = headerBackgroundColor;
    if (!_navigationBar) {
        return;
    }
    if (headerBackgroundColor) {
        if (CGColorGetAlpha(headerBackgroundColor.CGColor) == 0.) {
            if (!_backgroundImage) {
                _backgroundImage = [UIImage new];
            }
            [_navigationBar setBackgroundImage:_backgroundImage forBarMetrics:UIBarMetricsDefault];
            [_navigationBar setBarTintColor:[UIColor clearColor]];
        } else {
            [_navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            [_navigationBar setBarTintColor:headerBackgroundColor];
        }
    } else {
        [_navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [_navigationBar setBarTintColor:nil];
    }
}

- (void)setHeaderBorderColor:(UIColor *)headerBorderColor
{
    _headerBorderColor = headerBorderColor;
    if (!_navigationBar) {
        return;
    }
    if (headerBorderColor) {
        if (!_bottomBorderRender) {
            CGRect navigationBarFrame = _navigationBar.frame;
            CGRect bottomBorderRect = CGRectMake(CGRectGetMinX(navigationBarFrame), CGRectGetHeight(navigationBarFrame), CGRectGetWidth(navigationBarFrame), 1.0f / [UIScreen mainScreen].scale);
            _bottomBorderRender = [[UIView alloc] initWithFrame:bottomBorderRect];
            _bottomBorderRender.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        }
        if (_bottomBorderRender.superview) {
            if (_bottomBorderRender.superview == _navigationBar) {
                [_navigationBar bringSubviewToFront:_bottomBorderRender];
            } else {
                [_bottomBorderRender removeFromSuperview];
                [_navigationBar addSubview:_bottomBorderRender];
            }
        } else {
            [_navigationBar addSubview:_bottomBorderRender];
        }
        [_bottomBorderRender setBackgroundColor:headerBorderColor];
    } else {
        [_bottomBorderRender removeFromSuperview];
    }
}

- (void)attachViewController:(UIViewController *)viewController
{
    _navigationItem = viewController.navigationItem;
    _navigationBar = viewController.navigationController.navigationBar;
    
    [self setHeaderBackgroundColor:_headerBackgroundColor];
    [self setHeaderBorderColor:_headerBorderColor];
    [self updateNavigationItem];
}

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

- (void)detachViewController
{
    [self destroy];
    _navigationBar = nil;
    _navigationItem = nil;
}

- (void)invalidate
{
    [self destroy];
}

- (void)destroy
{
    if (_bottomBorderRender) {
        [_bottomBorderRender removeFromSuperview];
    }
    [_navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [_navigationBar setBarTintColor:nil];
}

@end
