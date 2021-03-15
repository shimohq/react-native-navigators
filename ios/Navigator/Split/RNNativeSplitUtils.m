//
//  RNNativeSplitUtils.m
//  react-native-navigators
//
//  Created by Bell Zhong on 2021/1/14.
//

#import "RNNativeSplitUtils.h"

@implementation RNNativeSplitUtils

+ (NSArray<RNNativeSplitRule *> *)parseSplitRules:(NSArray<NSDictionary *> *)splitRules {
    NSMutableArray *rules = [NSMutableArray array];
    [splitRules enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RNNativeSplitRule *rule = [RNNativeSplitRule new];
        rule.primarySceneWidth = [obj[@"primarySceneWidth"] floatValue];
        NSArray<NSNumber *> *navigatorWidthRange = obj[@"navigatorWidthRange"];
        rule.navigatorWidthBegin = navigatorWidthRange.count > 0 ? [navigatorWidthRange[0] floatValue] : 0;
        rule.navigatorWidthEnd = navigatorWidthRange.count > 1 ? [navigatorWidthRange[1] floatValue] : CGFLOAT_MAX;
        [rules addObject:rule];
    }];
    return rules;
}

+ (CGFloat)getPrimarySceneWidthWithRules:(NSArray<RNNativeSplitRule *> *)rules navigatorWidth:(CGFloat)navigatorWidth {
    for (RNNativeSplitRule *rule in rules) {
        if (rule.navigatorWidthBegin < rule.navigatorWidthEnd
            && rule.navigatorWidthEnd > 0
            && navigatorWidth >= rule.navigatorWidthBegin
            && navigatorWidth <= rule.navigatorWidthEnd
            && rule.primarySceneWidth < navigatorWidth) {
            return rule.primarySceneWidth;
        }
    }
    return 0;
}

+ (CGFloat)splitLineWidth {
    return 1.0 / [UIScreen mainScreen].scale;
}

@end
