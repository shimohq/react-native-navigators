//
//  RNNativeCardNavigatorController.h
//  react-native-navigators
//
//  Created by Bell Zhong on 2019/11/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RNNativeScene;

@protocol RNNativeCardNavigatorControllerDelegate <NSObject>

- (void)didRemoveController:(nonnull UIViewController *)viewController;

@end

@protocol RNNativeCardNavigatorControllerDataSource <NSObject>

- (BOOL)isSplit;
- (NSArray<RNNativeScene *> *)getCurrentScenes;

@end

@interface RNNativeCardNavigatorController : UIViewController

@property (nonatomic, weak) id<RNNativeCardNavigatorControllerDelegate> delegate;
@property (nonatomic, weak) id<RNNativeCardNavigatorControllerDataSource> dataSource;

@end

NS_ASSUME_NONNULL_END
