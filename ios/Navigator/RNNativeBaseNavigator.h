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

NS_ASSUME_NONNULL_BEGIN

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
   nextScrenes:(NSArray<RNNativeStackScene *> *)nextScrenes
 removedScenes:(NSMutableArray<RNNativeStackScene *> *)removedScenes
insertedScenes:(NSMutableArray<RNNativeStackScene *> *)insertedScenes;

@end

NS_ASSUME_NONNULL_END
