#import <React/RCTViewManager.h>
#import <React/RCTView.h>

@interface RNNativeStackHeader : RCTView <RCTInvalidating>

@property (nonatomic, retain) UIColor *headerBackgroundColor;
@property (nonatomic, retain) UIColor *headerBorderColor;

- (void)attachViewController:(UIViewController *)viewController;
- (void)detachViewController;

@end
