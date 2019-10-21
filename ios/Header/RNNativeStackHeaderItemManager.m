#import "RNNativeStackHeaderItemManager.h"
#import "RNNativeStackHeaderItem.h"

@implementation RNNativeStackHeaderItemManager


RCT_EXPORT_MODULE()

- (UIView *)view
{
  return [RNNativeStackHeaderItem new];
}

RCT_EXPORT_VIEW_PROPERTY(type, RNNativeStackHeaderType)

@end
