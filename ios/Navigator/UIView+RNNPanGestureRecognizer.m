//
//  UIView+RNNPanGestureRecognizer.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2020/12/22.
//

#import "UIView+RNNPanGestureRecognizer.h"
#import "RNNativePanGestureRecognizerManager.h"

#import <objc/runtime.h>

@implementation UIView (RNNPanGestureRecognizer)

void Swizzle(Class c, SEL orig, SEL new) {
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod  = class_getInstanceMethod(c, new);
    if (class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

+ (void)load {
    Swizzle(UIScrollView.class, @selector(addGestureRecognizer:), @selector(rnn_addGestureRecognizer:));
    Swizzle(NSClassFromString(@"WKApplicationStateTrackingView"), @selector(addGestureRecognizer:), @selector(rnn_addGestureRecognizer:));
}

- (void)rnn_addGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer {
    for (UIPanGestureRecognizer *panGestureRecognizer in [[RNNativePanGestureRecognizerManager sharedInstance] getAllPanGestureRecognizers]) {
        [gestureRecognizer requireGestureRecognizerToFail:panGestureRecognizer];
    }
    [self rnn_addGestureRecognizer:gestureRecognizer];
}

@end
