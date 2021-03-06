//
//  RNNativeSplitNavigatorController.h
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RNNativeScene;

@protocol RNNativeSplitNavigatorControllerDataSource <NSObject>

- (BOOL)isSplit;
- (BOOL)isSplitFullScreen;
- (BOOL)isEnableGestureWhenSplitFullScreen;
- (CGFloat)getPrimarySceneWidth;
- (NSArray<RNNativeScene *> *)getCurrentScenes;
- (__kindof UIView *)getSplitPlaceholder;

@end

@interface RNNativeSplitNavigatorController : UIViewController

@property (nonatomic, weak) id<RNNativeSplitNavigatorControllerDataSource> dataSource;

@end

NS_ASSUME_NONNULL_END
