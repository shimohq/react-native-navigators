package im.shimo.navigators;

import android.graphics.Color;
import android.os.Build;
import android.view.View;
import android.widget.LinearLayout;

import androidx.appcompat.widget.Toolbar;
import androidx.coordinatorlayout.widget.CoordinatorLayout;

import com.google.android.material.appbar.AppBarLayout;

/**
 * Created by jiang on 2019-11-19
 */

public class SceneStackModel extends SceneModel {

    private AppBarLayout mAppBarLayout;
    private Toolbar mToolbar;

    public SceneStackModel(Scene scene) {
        super(scene);
    }

    @Override
    protected void onCreateScene(Scene scene) {
        mRootView = new SceneStackRootView(scene.getContext());

        CoordinatorLayout.LayoutParams params = new CoordinatorLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT);
       // params.setBehavior(new AppBarLayout.ScrollingViewBehavior());
        scene.setLayoutParams(params);
        mRootView.addView(scene);
        mAppBarLayout = new AppBarLayout(getContext());
        mAppBarLayout.setBackgroundColor(Color.TRANSPARENT);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            mAppBarLayout.setStateListAnimator(null);
        }
        mAppBarLayout.setLayoutParams(new AppBarLayout.LayoutParams(
                AppBarLayout.LayoutParams.MATCH_PARENT, AppBarLayout.LayoutParams.WRAP_CONTENT));
        mRootView.addView(mAppBarLayout);

        if (mToolbar != null) {
            mAppBarLayout.addView(mToolbar);
        }
    }

    public void removeToolbar() {
        if (mRootView != null && mAppBarLayout != null && mAppBarLayout.getParent() != null) {
            mRootView.removeView(mAppBarLayout);
            mAppBarLayout.removeAllViews();
        }
    }

    public void setToolbar(Toolbar toolbar) {
        if (mAppBarLayout != null) {
            if (mAppBarLayout.getParent() == null) {
                mRootView.addView(mAppBarLayout, 0);
            }
            mAppBarLayout.addView(toolbar);

        }
        mToolbar = toolbar;
        AppBarLayout.LayoutParams params = (AppBarLayout.LayoutParams) mToolbar.getLayoutParams();
        params.setScrollFlags(0);
    }


    public void setToolBarBottomLine(View view) {
        if (mAppBarLayout != null) {
            if (mAppBarLayout.getParent() == null) {
                mRootView.addView(mAppBarLayout, 0);
            }
            if (view.getParent() == null) {
                mAppBarLayout.addView(view);
            }
        }
    }


//    public void onStackUpdate() {
//        View child = mSceneView.getChildAt(0);
//        if (child instanceof SceneStackHeader) {
//            ((SceneStackHeader) child).onUpdate();
//        }
//    }



    public void setBottomBorderColor(int color) {

    }
}
