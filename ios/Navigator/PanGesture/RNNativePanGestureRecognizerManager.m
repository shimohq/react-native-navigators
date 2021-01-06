//
//  RNNativePanGestureRecognizerManager.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2020/12/22.
//

#import "RNNativePanGestureRecognizerManager.h"

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

@end
