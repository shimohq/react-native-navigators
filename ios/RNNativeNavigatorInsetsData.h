@interface RNNativeNavigatorInsetsData : NSObject

@property (nonatomic, readonly) CGFloat rightInset;
@property (nonatomic, readonly) CGFloat topInset;
@property (nonatomic, readonly) CGFloat bottomInset;
@property (nonatomic, readonly) CGFloat leftInset;

- (instancetype)initWithInsets:(UIEdgeInsets)insets;

@end
