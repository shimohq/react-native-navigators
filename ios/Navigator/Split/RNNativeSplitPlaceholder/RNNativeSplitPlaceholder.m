//
//  RNNativeSplitPlaceholder.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/7.
//

#import "RNNativeSplitPlaceholder.h"
#import "RNNativeNavigatorFrameData.h"

#import <React/RCTUIManager.h>

@interface RNNativeSplitPlaceholder()

@property (nonatomic, weak) RCTBridge *bridge;

@end

@implementation RNNativeSplitPlaceholder


- (instancetype)initWithBridge:(RCTBridge *)bridge
{
    if (self = [super init]) {
        _bridge = bridge;
    }
    return self;
}


#pragma mark - UIView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    RNNativeNavigatorFrameData *data = [[RNNativeNavigatorFrameData alloc] initWithFrame:self.frame];
    
    [_bridge.uiManager setLocalData:data forView:self];
}

@end
