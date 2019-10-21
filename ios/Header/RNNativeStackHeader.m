#import "RNNativeStackHeader.h"
#import "RNNativeStackHeaderItem.h"

#import <React/RCTBridge.h>

@implementation RNNativeStackHeader
{
    __weak UINavigationBar *_navigationBar;
    __weak UINavigationItem *_navigationItem;
    UIView *_bottomBorderRender;
}


- (void)didUpdateReactSubviews
{
    [self updateNavigationItem];
}


- (void)setHeaderBackgroundColor:(UIColor *)headerBackgroundColor
{
    if (_navigationBar) {
        if (headerBackgroundColor) {
            if (CGColorGetAlpha(headerBackgroundColor.CGColor) == 0.) {
                [_navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
                [_navigationBar setBarTintColor:[UIColor clearColor]];
            } else {
                [_navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
                [_navigationBar setBarTintColor:headerBackgroundColor];
            }
        } else {
            [_navigationBar setBarTintColor:nil];
        }
    }
    
    _headerBackgroundColor = headerBackgroundColor;
}

- (void)setHeaderBorderColor:(UIColor *)headerBorderColor
{
    if (_navigationBar) {
        if (headerBorderColor) {
            if (!_bottomBorderRender) {
                CGRect navigationBarFrame = _navigationBar.frame;
                CGRect bottomBorderRect = CGRectMake(CGRectGetMinX(navigationBarFrame), CGRectGetHeight(navigationBarFrame), CGRectGetWidth(navigationBarFrame), 1.0f / [UIScreen mainScreen].scale);
                _bottomBorderRender = [[UIView alloc] initWithFrame:bottomBorderRect];
            } else {
                [_bottomBorderRender removeFromSuperview];
            }
            
            [_bottomBorderRender setBackgroundColor:headerBorderColor];
            [_navigationBar addSubview:_bottomBorderRender];
        } else {
            [_bottomBorderRender removeFromSuperview];
        }
    }
    
    _headerBorderColor = headerBorderColor;
}

- (void)attachViewController:(UIViewController *)viewController
{
    _navigationItem = viewController.navigationItem;
    UINavigationController *navigationController = viewController.navigationController;
    _navigationBar = navigationController.navigationBar;
    
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
    _navigationItem.titleView = nil;
    _navigationItem.leftBarButtonItem = nil;
    _navigationItem.rightBarButtonItem = nil;

    for (RNNativeStackHeaderItem *headerItem in self.reactSubviews) {
        switch (headerItem.type) {
            case RNNativeStackHeaderTypeCenter:
            {
                _navigationItem.titleView = headerItem;
            }
                break;
            case RNNativeStackHeaderTypeLeft:
            {
                UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:headerItem];
                _navigationItem.leftBarButtonItem = buttonItem;
            }
                break;
            case RNNativeStackHeaderTypeRight:
            {
                UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:headerItem];
                _navigationItem.rightBarButtonItem = buttonItem;
            }
                break;
        }
    }
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
        _bottomBorderRender = nil;
    }
    [_navigationBar setBarTintColor:nil];
}

@end
