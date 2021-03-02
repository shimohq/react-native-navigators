package im.shimo.navigators;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.coordinatorlayout.widget.CoordinatorLayout;

/**
 * Created by jiang on 2019-11-28
 */

public class SceneStackRootView extends CoordinatorLayout {

  private Scene mScene;

  public SceneStackRootView(@NonNull Context context) {
    super(context);
//        mScene = new Scene((ReactContext) context);
//        addView(mScene);
  }


  public Scene getScene() {
    return mScene;
  }
}
