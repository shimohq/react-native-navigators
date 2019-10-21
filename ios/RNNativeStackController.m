#import "RNNativeStackController.h"
#import "RNNativeStackScene.h"
#import "RNNativeStackHeader.h"

@interface RNNativeStackController () <UIGestureRecognizerDelegate>

@end

@implementation RNNativeStackController
{
    __weak id _previousFirstResponder;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}

- (instancetype)initWithScene:(RNNativeStackScene *)scene
{
    if (self = [self init]) {
        _scene = scene;
    }
    return self;
}

#pragma mark - UIViewController

- (void)loadView
{
    if (_scene != nil) {
        self.view = _scene;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_scene transitionEnd:NO];
    
    if (_previousFirstResponder) {
        [_previousFirstResponder becomeFirstResponder];
        _previousFirstResponder = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    id responder = [self findFirstResponder:self.view];
    if (responder != nil) {
        _previousFirstResponder = responder;
    }
    
    [[self findHeader] detachViewController];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.parentViewController == nil && self.presentingViewController == nil) {
        if (_scene.closing) {
            [_scene transitionEnd:YES];
        } else {
            [_scene dismiss];
        }
    }
}

#pragma mark - Private

- (RNNativeStackHeader *)findHeader
{
    for (UIView *subview in _scene.reactSubviews) {
        if ([subview isKindOfClass:[RNNativeStackHeader class]]) {
            return (RNNativeStackHeader *)subview;
        }
    }
    
    return nil;
}

- (id)findFirstResponder:(UIView*)parent
{
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
