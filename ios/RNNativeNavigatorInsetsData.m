#import "RNNativeNavigatorInsetsData.h"

@implementation RNNativeNavigatorInsetsData

- (instancetype)initWithInsets:(UIEdgeInsets)insets
{
  if (self = [super init]) {
    _topInset = insets.top;
    _bottomInset = insets.bottom;
    _leftInset = insets.left;
    _rightInset = insets.right;
  }
  return self;
}

@end
