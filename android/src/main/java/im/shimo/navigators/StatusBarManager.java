package im.shimo.navigators;

import android.annotation.TargetApi;
import android.app.Activity;
import android.os.Build;
import android.view.View;
import android.view.WindowManager;

import androidx.annotation.Nullable;

import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.UiThreadUtil;

public class StatusBarManager {
  private boolean mStatusBarHidden = false;
  private String mStatusBarStyle = StatusBarStyle.Default;
  private ReactContext mContext;

  public StatusBarManager(ReactContext context) {
    mContext = context;
  }

  public void setStatusBarHidden(final boolean hidden) {
    if (mStatusBarHidden == hidden) {
      return;
    }
    final Activity activity = mContext.getCurrentActivity();
    if (activity == null) {
      return;
    }
    mStatusBarHidden = hidden;
    UiThreadUtil.runOnUiThread(
      new Runnable() {
        @Override
        public void run() {
          if (hidden) {
            activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
            activity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FORCE_NOT_FULLSCREEN);
          } else {
            activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_FORCE_NOT_FULLSCREEN);
            activity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
          }
        }
      });
  }

  public void setStatusBarStyle(@Nullable final String style) {
    final String statusBarStyle = (style == null) ? StatusBarStyle.Default : style;
    if (statusBarStyle.equals(mStatusBarStyle)) {
      return;
    }
    final Activity activity = mContext.getCurrentActivity();
    if (activity == null) {
      return;
    }
    mStatusBarStyle = statusBarStyle;
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      UiThreadUtil.runOnUiThread(
        new Runnable() {
          @TargetApi(Build.VERSION_CODES.M)
          @Override
          public void run() {
            View decorView = activity.getWindow().getDecorView();
            int systemUiVisibilityFlags = decorView.getSystemUiVisibility();
            if (StatusBarStyle.LightContent.equals(style)) {
              systemUiVisibilityFlags &= ~View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
            } else {
              systemUiVisibilityFlags |= View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
            }
            decorView.setSystemUiVisibility(systemUiVisibilityFlags);
          }
        });
    }
  }

  public interface StatusBarStyle {
    String Default = "default";
    String DarkContent = "darkContent";
    String LightContent = "lightContent";
  }
}
