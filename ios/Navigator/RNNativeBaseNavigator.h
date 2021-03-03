//
//  RNNativeBaseNavigator.h
//  owl
//
//  Created by Bell Zhong on 2019/10/16.
//  Copyright © 2019 shimo.im. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTView.h>
#import <React/RCTViewManager.h>
#import "RNNativeScene.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RNNativeStackNavigatorAction) {
    RNNativeStackNavigatorActionNone,
    RNNativeStackNavigatorActionShow,
    RNNativeStackNavigatorActionHide
};

@interface RNNativeBaseNavigator : RCTView <RCTInvalidating>

@property (nonatomic, strong, readonly) __kindof UIViewController *viewController;
@property (nonatomic, strong, readonly) NSMutableArray<RNNativeScene *> *currentScenes;
@property (nonatomic, weak, readonly) RCTBridge *bridge;

- (instancetype)initWithBridge:(RCTBridge *)bridge viewController:(UIViewController *)viewController;

- (void)markChildUpdated;
- (void)didUpdateChildren;

/**
 子类重写
 */
- (void)updateSceneWithCurrentScenes:(NSArray<RNNativeScene *> *)currentScenes
                          NextScenes:(NSArray<RNNativeScene *> *)nextScenes
                           comoplete:(RNNativeNavigatorUpdateCompleteBlock)comoplete;

/**
 子类必须实现
 */
- (void)updateSceneWithTransition:(RNNativeSceneTransition)transition
                           action:(RNNativeStackNavigatorAction)action
                    currentScenes:(NSArray<RNNativeScene *> *)currentScenes
                       nextScenes:(NSArray<RNNativeScene *> *)nextScenes
                    removedScenes:(NSArray<RNNativeScene *> *)removedScenes
                   insertedScenes:(NSArray<RNNativeScene *> *)insertedScenes
                  beginTransition:(RNNativeNavigatorTransitionBlock)beginTransition
                    endTransition:(RNNativeNavigatorTransitionBlock)endTransition;

- (BOOL)isDismissedForViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
