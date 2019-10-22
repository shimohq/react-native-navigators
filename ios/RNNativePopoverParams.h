//
//  RNNativePopoverParams.h
//  Pods-examples
//
//  Created by Bell Zhong on 2019/10/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNNativePopoverParams : NSObject

@property (nonatomic, strong) NSDictionary *params;

@property (nonatomic, strong) NSString *sourceViewNativeID;
@property (nonatomic, assign) CGRect sourceRect;
@property (nonatomic, assign) UIPopoverArrowDirection directions;
@property (nonatomic, assign) CGSize contentSize;

- (instancetype)initWithParams:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
