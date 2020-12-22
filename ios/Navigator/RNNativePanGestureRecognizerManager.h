//
//  RNNativePanGestureRecognizerManager.h
//  react-native-navigators
//
//  Created by Bell Zhong on 2020/12/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNNativePanGestureRecognizerManager : NSObject

+ (instancetype)sharedInstance;

- (void)addPanGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer;
- (NSArray<UIPanGestureRecognizer *> *)getAllPanGestureRecognizers;

@end

NS_ASSUME_NONNULL_END
