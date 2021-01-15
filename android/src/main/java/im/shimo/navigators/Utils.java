package im.shimo.navigators;

import android.content.Context;
import android.util.DisplayMetrics;
import android.util.TypedValue;

import androidx.annotation.NonNull;

class Utils {


  public static int dpToPx(@NonNull Context context, float dp) {
    return dpToPx(context.getResources().getDisplayMetrics(), dp);
  }


  public static int dpToPx(DisplayMetrics metrics, float dp) {
    return Math.round(TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp, metrics));
  }


}
