//
//  RNNativeSceneListenerManager.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2019/12/16.
//

#import "RNNativeSceneListenerManager.h"

typedef void (^RNNativeSceneListenerManagerCompleteBlock)( NSHashTable<RNNativeScene *> * __nonnull parentScenes,  RNNativeScene * __nullable scene);

@interface RNNativeSceneListenerManager()

@property (nonatomic, strong) NSHashTable<RNNativeScene *> *listenedScenes;
@property (nonatomic, strong) NSMapTable<RNNativeScene *, NSNumber *> *sceneRealStatusMap;

@property (nonatomic, strong) NSMapTable<UIView<RNNativeSceneListener> *, RNNativeScene *> *listenerToSceneMap;
@property (nonatomic, strong) NSMapTable<UIView<RNNativeSceneListener> *, NSHashTable<RNNativeScene *> *> *listenerToParentScenesMap;

@property (nonatomic, strong) NSMapTable<RNNativeScene *, NSHashTable<UIView<RNNativeSceneListener> *> *> *sceneToListenersMap;

@end

@implementation RNNativeSceneListenerManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    __strong static id _sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _listenedScenes = [NSHashTable weakObjectsHashTable];
        _sceneRealStatusMap = [NSMapTable weakToStrongObjectsMapTable];
        
        _listenerToSceneMap = [NSMapTable weakToWeakObjectsMapTable];
        _sceneToListenersMap = [NSMapTable weakToStrongObjectsMapTable];
        
        _listenerToParentScenesMap = [NSMapTable weakToStrongObjectsMapTable];
    }
    return self;
}

#pragma mark - Public

+ (void)registerListener:(nonnull UIView<RNNativeSceneListener> *)listener {
    [[self sharedInstance] registerListener:listener];
}

+ (void)unregisterListener:(nonnull UIView<RNNativeSceneListener> *)listener {
    [[self sharedInstance] unregisterListener:listener];
}

#pragma mark - RNNativeSceneDelegate

- (void)scene:(RNNativeScene *)pScene didUpdateStatus:(RNNativeSceneStatus)status {
    NSHashTable<UIView<RNNativeSceneListener> *> *listeners = [_sceneToListenersMap objectForKey:pScene];
    for (UIView<RNNativeSceneListener> * listener in listeners) {
        NSHashTable<RNNativeScene *> *parentScenes = [_listenerToParentScenesMap objectForKey:listener];
        BOOL parentSceneDidBlur = NO;
        for (RNNativeScene *scene in parentScenes) {
            if (scene && scene.status == RNNativeSceneStatusDidBlur) {
                parentSceneDidBlur = YES;
                break;
            }
        }
        RNNativeScene *scene = [_listenerToSceneMap objectForKey:listener];
        NSNumber *realStatus = [_sceneRealStatusMap objectForKey:scene];
        RNNativeSceneStatus newRealStatus = parentSceneDidBlur ? RNNativeSceneStatusDidBlur : scene.status;
        if (!realStatus || newRealStatus != [realStatus integerValue]) {
            [_sceneRealStatusMap setObject:[NSNumber numberWithInteger:newRealStatus] forKey:scene];
            [listener scene:scene didUpdateStatus:newRealStatus];
        }
    }
}

#pragma mark - Private

- (void)registerListener:(nonnull UIView<RNNativeSceneListener> *)listener {
    [self findScenesOfView:listener complete:^(NSHashTable<RNNativeScene *> * __nonnull newParentScenes, RNNativeScene * __nullable newScene) {
        BOOL updated = NO;
        
        // scene
        RNNativeScene *scene = [_listenerToSceneMap objectForKey:listener];
        if (scene != newScene) {
            updated = YES;
            if (scene) { // unregister old
                [_listenerToSceneMap removeObjectForKey:listener];
                [self unregisterListener:listener toScene:scene];
            }
            if (newScene) { // register new
                [_listenerToSceneMap setObject:newScene forKey:listener];
                [self registerListener:listener toScene:scene];
            }
        }
        
        // parentScenes
        NSHashTable<RNNativeScene *> *parentScenes = [_listenerToParentScenesMap objectForKey:listener];
        // add
        if (newParentScenes.count) {
            if (!parentScenes) {
                parentScenes = [NSHashTable weakObjectsHashTable];
                [_listenerToParentScenesMap setObject:parentScenes forKey:listener];
            }
            for (RNNativeScene *scene in newParentScenes) {
                if (![parentScenes containsObject:scene]) { // register added
                    updated = YES;
                    [parentScenes addObject:scene];
                    [self registerListener:listener toScene:scene];
                }
            }
        }
        // remove
        for (RNNativeScene *scene in parentScenes) {
            if (!newParentScenes || ![newParentScenes containsObject:scene]) { // unregister removed
                updated = YES;
                [self unregisterListener:listener toScene:scene];
            }
        }
        
        // update
        if (updated) {
            [self updateListenedScenes];
        }
    }];
}

- (void)unregisterListener:(nonnull UIView<RNNativeSceneListener> *)listener {
    // scene
    [_listenerToSceneMap removeObjectForKey:listener];
    
    // parentScenes
    NSHashTable<RNNativeScene *> *parentScenes = [_listenerToParentScenesMap objectForKey:listener];
    [_listenerToParentScenesMap removeObjectForKey:listener];
    for (RNNativeScene *scene in parentScenes) {
        NSHashTable<UIView<RNNativeSceneListener> *> *listeners = [_sceneToListenersMap objectForKey:scene];
        if (listeners) {
            [listeners removeObject:listener];
            if (listeners.count == 0) {
                [_sceneToListenersMap removeObjectForKey:scene];
            }
        }
    }
    
    // update
    [self updateListenedScenes];
}

- (void)registerListener:(UIView<RNNativeSceneListener> *)listener toScene:(RNNativeScene *)scene {
    NSHashTable<UIView<RNNativeSceneListener> *> *listeners = [_sceneToListenersMap objectForKey:scene];
    if (!listeners) {
        listeners = [NSHashTable weakObjectsHashTable];
        [_sceneToListenersMap setObject:listeners forKey:scene];
    }
    [listeners addObject:listener];
}

- (void)unregisterListener:(UIView<RNNativeSceneListener> *)listener toScene:(RNNativeScene *)scene {
    NSHashTable<UIView<RNNativeSceneListener> *> *listeners = [_sceneToListenersMap objectForKey:scene];
    if (listeners) {
        [listeners removeObject:listener];
        if (!listeners.count) {
            [_sceneToListenersMap removeObjectForKey:scene];
        }
    }
}

/// register or unregister scene status listener
- (void)updateListenedScenes {
    NSHashTable<RNNativeScene *> *listenedScenes = [NSHashTable weakObjectsHashTable];
    for (RNNativeScene *scene in [_sceneToListenersMap keyEnumerator]) {
        [listenedScenes addObject:scene];
        
        if (![_listenedScenes containsObject:scene]) { // added
            [_listenedScenes addObject:scene];
            [scene registerListener:self];
        }
    }
    
    for (RNNativeScene *scene in _listenedScenes) {
        if (![listenedScenes containsObject:scene]) { // removed
            [_listenedScenes removeObject:scene];
            [scene unregisterListener:self];
            [_sceneRealStatusMap removeObjectForKey:scene];
        }
    }
}

- (void)findScenesOfView:(UIView *)view complete:(RNNativeSceneListenerManagerCompleteBlock) complete {
    NSHashTable<RNNativeScene *> *scenes = [NSHashTable weakObjectsHashTable];
    RNNativeScene *scene = nil;
    UIView *targetView = view.superview;
    while (targetView) {
        if ([targetView isKindOfClass:[RNNativeScene class]]) {
            if (!scene) {
                scene = targetView;
            }
            [scenes addObject:targetView];
        }
        targetView = targetView.superview;
    }
    complete(scenes, scene);
}

@end
