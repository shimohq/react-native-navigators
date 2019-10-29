#import "RNNativeStackController.h"
#import "RNNativeStackScene.h"
#import "RNNativeStackHeader.h"

@interface RNNativeStackController () <UIGestureRecognizerDelegate>

@end

@implementation RNNativeStackController {
    __weak id _previousFirstResponder;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}

- (instancetype)initWithScene:(RNNativeStackScene *)scene {
    if (self = [self init]) {
        _scene = scene;
    }
    return self;
}

- (void)updateForStatus:(RNNativeStackSceneStatus)status {
    switch (status) {
        case RNNativeStackSceneStatusWillFocus:
            // attach header
            [self updateHeader];
            break;
        case RNNativeStackSceneStatusDidFocus:
            // first responder
            [self setBecomeFirstResponder];
            break;
        case RNNativeStackSceneStatusDidBlur:
            // detach header
            [[self findHeader] detachViewController];
            break;
        case RNNativeStackSceneStatusWillBlur:
            // first responder
            [self updateFirstResponder];
            break;
        default:
            break;
    }
}

#pragma mark - UIViewController

- (void)loadView {
    if (_scene != nil) {
        self.view = _scene;
    }
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    [super willMoveToParentViewController:parent];
    [_scene setStatus:parent ? RNNativeStackSceneStatusWillFocus : RNNativeStackSceneStatusWillBlur];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];
    [_scene setStatus:parent ? RNNativeStackSceneStatusDidFocus : RNNativeStackSceneStatusDidBlur];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_scene setStatus:RNNativeStackSceneStatusWillFocus];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_scene setStatus:RNNativeStackSceneStatusDidFocus];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_scene setStatus:RNNativeStackSceneStatusWillBlur];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_scene setStatus:RNNativeStackSceneStatusDidBlur];
}

#pragma mark - Header

- (void)updateHeader {
    RNNativeStackHeader *header = [self findHeader];
    if (header) {
        if (self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:NO];
        }
        self.navigationController.navigationBar.translucent = _scene.translucent;
        [header attachViewController:self];
    } else {
        if (!self.navigationController.navigationBarHidden) {
            [self.navigationController setNavigationBarHidden:YES];
        }
    }
}

- (RNNativeStackHeader *)findHeader {
    for (UIView *subview in _scene.reactSubviews) {
        if ([subview isKindOfClass:[RNNativeStackHeader class]]) {
            return (RNNativeStackHeader *)subview;
        }
    }
    return nil;
}

#pragma mark - First Responder

- (void)updateFirstResponder {
    id responder = [self findFirstResponder:self.view];
    if (responder != nil) {
        _previousFirstResponder = responder;
    }
}

- (void)setBecomeFirstResponder {
    if (_previousFirstResponder) {
        [_previousFirstResponder becomeFirstResponder];
        _previousFirstResponder = nil;
    }
}

- (id)findFirstResponder:(UIView*)parent {
    if (parent.isFirstResponder) {
        return parent;
    }
    for (UIView *subView in parent.subviews) {
        id responder = [self findFirstResponder:subView];
        if (responder != nil) {
            return responder;
        }
    }
    return nil;
}

@end
