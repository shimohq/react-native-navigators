//
//  RNNativeBaseNavigator.h
//  owl
//
//  Created by Bell Zhong on 2019/10/16.
//  Copyright © 2019 shimo.im. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTViewManager.h>
#import "RNNativeStackScene.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RNNativeStackSceneMode) {
    RNNativeStackSceneModeStack,
    RNNativeStackSceneModePopover,
    RNNativeStackSceneModeModal,
};

typedef NS_ENUM(NSInteger, RNNativeStackNavigatorAction) {
    RNNativeStackNavigatorActionNone,
    RNNativeStackNavigatorActionShow,
    RNNativeStackNavigatorActionHide
};

typedef void (^RNNativeNavigatorTransitionBlock)(void);

@interface RNNativeBaseNavigator : UIView <RCTInvalidating>

@property (nonatomic, strong, readonly) NSMutableArray<RNNativeStackScene *> *currentScenes;
@property (nonatomic, weak, readonly) RCTBridge *bridge;

- (instancetype)initWithBridge:(RCTBridge *)bridge viewController:(UIViewController *)viewController;

- (void)markChildUpdated;
- (void)didUpdateChildren;

/**
 子类必须实现
 */
- (void)updateSceneWithTransition:(RNNativeStackSceneTransition)transition
                           action:(RNNativeStackNavigatorAction)action
                       nextScenes:(NSArray<RNNativeStackScene *> *)nextScenes
                    removedScenes:(NSArray<RNNativeStackScene *> *)removedScenes
                   insertedScenes:(NSArray<RNNativeStackScene *> *)insertedScenes
                  beginTransition:(RNNativeNavigatorTransitionBlock)beginTransition
                    endTransition:(RNNativeNavigatorTransitionBlock)endTransition;

- (BOOL)isDismissedForViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
