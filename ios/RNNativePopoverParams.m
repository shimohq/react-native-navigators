//
//  RNNativePopoverParams.m
//  Pods-examples
//
//  Created by Bell Zhong on 2019/10/22.
//

#import "RNNativePopoverParams.h"

@implementation RNNativePopoverParams

- (instancetype)initWithParams:(NSDictionary *)params
{
    self = [super init];
    if (self) {
        _params = params;
        
        _sourceViewNativeID = params[@"sourceViewNativeID"];
        
        // sourceRect
        NSDictionary *sourceRect = params[@"sourceRect"];
        if ([sourceRect isKindOfClass:[NSDictionary class]]) {
            _sourceRect = CGRectMake([sourceRect[@"x"] floatValue], [sourceRect[@"y"] floatValue], [sourceRect[@"width"] floatValue], [sourceRect[@"height"] floatValue]);
        }
        
        // directions
        UIPopoverArrowDirection popoverArrowDirection = 0;
        NSArray *directions = params[@"directions"];
        if ([directions isKindOfClass:[NSArray class]]) {
            for (NSString *direction in directions) {
                if ([direction isEqualToString:@"up"]) {
                    popoverArrowDirection = popoverArrowDirection | UIPopoverArrowDirectionUp;
                } else if ([direction isEqualToString:@"down"]) {
                    popoverArrowDirection = popoverArrowDirection | UIPopoverArrowDirectionDown;
                } else if ([direction isEqualToString:@"left"]) {
                    popoverArrowDirection = popoverArrowDirection | UIPopoverArrowDirectionLeft;
                } else if ([direction isEqualToString:@"right"]) {
                    popoverArrowDirection = popoverArrowDirection | UIPopoverArrowDirectionRight;
                }
            }
        }
        _directions = popoverArrowDirection == 0 ? UIPopoverArrowDirectionAny : popoverArrowDirection;
        
        // contentSize
        NSDictionary *contentSize = params[@"contentSize"];
        if ([contentSize isKindOfClass:[NSDictionary class]]) {
            _contentSize = CGSizeMake([contentSize[@"width"] floatValue], [contentSize[@"height"] floatValue]);
        }
    }
    return self;
}

@end
