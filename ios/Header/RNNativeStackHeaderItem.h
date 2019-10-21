#import <React/RCTViewManager.h>
#import <React/RCTView.h>

typedef NS_ENUM(NSInteger, RNNativeStackHeaderType) {
    RNNativeStackHeaderTypeCenter,
    RNNativeStackHeaderTypeLeft,
    RNNativeStackHeaderTypeRight
};


@interface RNNativeStackHeaderItem : RCTView

@property (nonatomic, assign) RNNativeStackHeaderType type;

@end
