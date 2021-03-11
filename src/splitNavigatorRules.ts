import { NativeNavigatorSplitRules } from './types';

export function calculateSplitPrimarySceneWidth(
  splitRules: NativeNavigatorSplitRules,
  width: number
): number | undefined {
  for (let i = 0; i < splitRules.length; i++) {
    const rule = splitRules[i];
    const range = rule.navigatorWidthRange;
    // 宽度大于等于当前规则的最小范围
    if (width >= range[0] && rule.primarySceneWidth <= width) {
      // 宽度在当前规则的闭合区间内，匹配成功
      if (typeof range[1] === 'number' && width <= range[1]) {
        return rule.primarySceneWidth;
      } else if (typeof range[1] !== 'number') {
        // 当前规则没有指定最大范围，匹配成功
        return rule.primarySceneWidth;
      }
    }
  }
  return undefined;
}
