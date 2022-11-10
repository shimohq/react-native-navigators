//
//  RNNativePanGestureRecognizerManager.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2020/12/22.
//

#import "RNNativePanGestureRecognizerManager.h"

#import <React/RCTTouchHandler.h>

@interface RNNativePanGestureRecognizerManager()

@property (nonatomic, strong) NSHashTable<UIPanGestureRecognizer *> *panGestureRecognizers;

@end

@implementation RNNativePanGestureRecognizerManager

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedInstance = nil;
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _panGestureRecognizers = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)addPanGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer {
    [_panGestureRecognizers addObject:panGestureRecognizer];
}

- (NSArray<UIPanGestureRecognizer *> *)getAllPanGestureRecognizers {
    return _panGestureRecognizers.allObjects;
}

- (void)cancelTouchesInParent:(UIView *)parent {
    // cancel touches in parent, this is needed to cancel RN touch events. For example when Touchable
    // item is close to an edge and we start pulling from edge we want the Touchable to be cancelled.
    // Without the below code the Touchable will remain active (highlighted) for the duration of back
    // gesture and onPress may fire when we release the finger.
    while (parent != nil && ![parent respondsToSelector:@selector(touchHandler)])
        parent = parent.superview;
    if (parent != nil) {
        RCTTouchHandler *touchHandler = [parent performSelector:@selector(touchHandler)];
        [touchHandler setEnabled:NO];
        [touchHandler setEnabled:YES];
        [touchHandler reset];
    }
}

@end
