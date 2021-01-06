//
//  RNNativeCardNavigatorController.h
//  react-native-navigators
//
//  Created by Bell Zhong on 2019/11/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RNNativeCardNavigatorControllerDelegate <NSObject>

- (void)didRemoveController:(nonnull UIViewController *)viewController;

@end

@interface RNNativeCardNavigatorController : UIViewController

@property (nonatomic, weak) id<RNNativeCardNavigatorControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
