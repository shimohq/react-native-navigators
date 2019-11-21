package im.shimo.navigators;

import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import androidx.annotation.Nullable;
import androidx.appcompat.widget.Toolbar;
import androidx.coordinatorlayout.widget.CoordinatorLayout;

import com.google.android.material.appbar.AppBarLayout;

/**
 * Created by jiang on 2019-11-19
 */

public class SceneStackFragment extends SceneFragment {

    private AppBarLayout mAppBarLayout;
    private Toolbar mToolbar;
    private View mBottomLine;

    SceneStackFragment(Scene scene) {
        super(scene);
    }

    public void removeToolbar() {
        if (getView() != null && mAppBarLayout != null && mAppBarLayout.getParent() != null) {
            ((ViewGroup) getView()).removeView(mAppBarLayout);
            mAppBarLayout.removeAllViews();
        }
    }

    public void setToolbar(Toolbar toolbar) {
        if (mAppBarLayout != null) {
            if (mAppBarLayout.getParent() == null) {
                ((ViewGroup) requireView()).addView(mAppBarLayout, 0);
            }
            mAppBarLayout.addView(toolbar);

        }
        mToolbar = toolbar;
        AppBarLayout.LayoutParams params = new AppBarLayout.LayoutParams(
                AppBarLayout.LayoutParams.MATCH_PARENT, AppBarLayout.LayoutParams.WRAP_CONTENT);
        params.setScrollFlags(0);
        mToolbar.setLayoutParams(params);
    }


    public void setToolBarBottomLine(View view) {
        if (mAppBarLayout != null) {
            if (mAppBarLayout.getParent() == null) {
                ((ViewGroup) requireView()).addView(mAppBarLayout, 0);
            }
            if (view.getParent() == null) {
                mAppBarLayout.addView(view);
            }
        }
    }


    public void onStackUpdate() {
        View child = mSceneView.getChildAt(0);
        if (child instanceof SceneStackHeader) {
            ((SceneStackHeader) child).onUpdate();
        }
    }

    public View onCreateView(LayoutInflater inflater,
                             @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        CoordinatorLayout view = new CoordinatorLayout(requireContext());
        CoordinatorLayout.LayoutParams params = new CoordinatorLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT);
        params.setBehavior(new AppBarLayout.ScrollingViewBehavior());
        mSceneView.setLayoutParams(params);
        view.addView(mSceneView);
        mAppBarLayout = new AppBarLayout(requireContext());
        mAppBarLayout.setBackgroundColor(Color.TRANSPARENT);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            mAppBarLayout.setStateListAnimator(null);
        }
        mAppBarLayout.setLayoutParams(new AppBarLayout.LayoutParams(
                AppBarLayout.LayoutParams.MATCH_PARENT, AppBarLayout.LayoutParams.WRAP_CONTENT));
        view.addView(mAppBarLayout);

        if (mToolbar != null) {
            mAppBarLayout.addView(mToolbar);
        }

        return view;
    }


    public void setBottomBorderColor(int color) {

    }
}
