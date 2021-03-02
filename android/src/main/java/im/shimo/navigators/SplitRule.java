package im.shimo.navigators;

import android.content.Context;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;

class SplitRule {

  int primarySceneWidth;
  int min;
  int max;


  static SplitRule form(ReadableMap rule, Context context) {
    int primarySceneWidth = Utils.dpToPx(context, (float) rule.getDouble("primarySceneWidth"));
    final ReadableArray navigatorWidthRange = rule.getArray("navigatorWidthRange");
    int min = Utils.dpToPx(context, (float) navigatorWidthRange.getDouble(0));
    int max = navigatorWidthRange.size() > 1 ? Utils.dpToPx(context, (float) navigatorWidthRange.getDouble(1)) : Integer.MAX_VALUE;
    return new SplitRule(primarySceneWidth, min, max);
  }

  public SplitRule(int primarySceneWidth, int min, int max) {
    this.primarySceneWidth = primarySceneWidth;
    this.min = min;
    this.max = max;
  }


}
