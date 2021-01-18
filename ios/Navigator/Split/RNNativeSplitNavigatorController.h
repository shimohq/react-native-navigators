//
//  RNNativeSplitNavigatorController.h
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RNNativeScene;

@protocol RNNativeSplitNavigatorControllerDelegate <NSObject>

- (void)didRemoveController:(nonnull UIViewController *)viewController;
- (void)willLayoutSubviews:(CGRect)parentBounds;

@end

@protocol RNNativeSplitNavigatorControllerDataSource <NSObject>

- (BOOL)isSplit;
- (NSArray<RNNativeScene *> *)getCurrentScenes;

@end

@interface RNNativeSplitNavigatorController : UIViewController

@property (nonatomic, weak) id<RNNativeSplitNavigatorControllerDelegate> delegate;
@property (nonatomic, weak) id<RNNativeSplitNavigatorControllerDataSource> dataSource;

@end

NS_ASSUME_NONNULL_END
