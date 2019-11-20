package im.shimo.navigators;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Color;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.fragment.app.Fragment;

import java.util.ArrayList;

public class SceneStackHeader extends ViewGroup {

    private static final String TAG = "SceneStackHeader";

    private boolean mIsAttachedToWindow = false;
    private static final int[] attrs = new int[]{
            R.attr.headerBackgroundColor,
            R.attr.headerBorderColor,
            R.attr.headerBorderSize
    };

    private View mBottomBorderView;
    private int bottomBorderSize;

    private final Toolbar mToolbar;
    private ArrayList<SceneStackHeaderItem> mItems = new ArrayList<>(3);

    @SuppressLint("ResourceType")
    public SceneStackHeader(Context context) {
        super(context);
        TypedValue typedValue = new TypedValue();
        boolean resolved = context.getTheme().resolveAttribute(R.attr.scene, typedValue, true);
        TypedArray a;
        if (resolved) {
            a = context.obtainStyledAttributes(typedValue.resourceId, attrs);
        } else {
            a = context.obtainStyledAttributes(attrs);
        }
        int backBackgroundColor = a.getColor(0, Color.WHITE);
        int bottomBorderColor = a.getColor(1, Color.DKGRAY);
        bottomBorderSize = a.getDimensionPixelSize(2, 1);
        a.recycle();
        TypedValue tv = new TypedValue();
        int actionBarHeight = 0;
        if (context.getTheme().resolveAttribute(android.R.attr.actionBarSize, tv, true)) {
            actionBarHeight = TypedValue.complexToDimensionPixelSize(tv.data, context.getResources().getDisplayMetrics());
        }

        mToolbar = new Toolbar(context);
        mToolbar.setBackgroundColor(backBackgroundColor);
        mToolbar.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, actionBarHeight));
        mBottomBorderView = new View(context);
        mBottomBorderView.setBackgroundColor(bottomBorderColor);
        mBottomBorderView.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, bottomBorderSize));
    }


    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        // ignore
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        mIsAttachedToWindow = true;
        onUpdate();
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mIsAttachedToWindow = false;
    }

    public View getHeaderItem(int index) {
        return mItems.get(index);
    }

    public int getHeaderItemCount() {
        return mItems.size();
    }

    public void removeHeaderItemView(int index) {
        SceneStackHeaderItem item = mItems.remove(index);
        mToolbar.removeView(item);
    }

    public void addHeaderItemView(SceneStackHeaderItem child, int index) {
        mItems.add(index, child);
        onUpdate();
    }

    private SceneContainer findSceneContainer(View view) {
        final ViewParent viewParent = getParent();
        if (viewParent == null) {
            return null;
        } else if (viewParent instanceof SceneContainer) {
            return (SceneContainer) viewParent;
        } else {
            return findSceneContainer(view);
        }
    }

    private Scene getScene() {
        ViewParent screen = getParent();
        if (screen instanceof Scene) {
            return (Scene) screen;
        }
        return null;
    }

    private SceneStack getScreenStack() {
        Scene scene = getScene();
        if (scene != null) {
            SceneContainer container = scene.getSceneContainer();
            if (container instanceof SceneStack) {
                return (SceneStack) container;
            }
        }
        return null;
    }

    private SceneStackFragment getScreenFragment() {
        ViewParent screen = getParent();
        if (screen instanceof Scene) {
            Fragment fragment = ((Scene) screen).getFragment();
            if (fragment instanceof SceneStackFragment) {
                return (SceneStackFragment) fragment;
            }
        }
        return null;
    }

    public void onUpdate() {
        Scene parent = (Scene) getParent();
        final SceneStack stack = getScreenStack();

        boolean isRoot = stack == null || stack.getRootScreen() == parent;
        boolean isTop = stack == null || stack.getTopScene() == parent;

        if (!mIsAttachedToWindow || !isTop) {
            return;
        }

        if (mToolbar.getParent() == null) {
            getScreenFragment().setToolbar(mToolbar);
            getScreenFragment().setToolBarBottomLine(mBottomBorderView);
        }

        AppCompatActivity activity = (AppCompatActivity) getScreenFragment().getActivity();
        activity.setSupportActionBar(mToolbar);
//        ActionBar actionBar = activity.getSupportActionBar();

        mToolbar.setNavigationIcon(null);
        mToolbar.setTitle(null);

        for (SceneStackHeaderItem item : mItems) {
            final SceneStackHeaderItem.Type type = item.getType();
            Toolbar.LayoutParams params =
                    new Toolbar.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT);
            switch (type) {
                default:
                case LEFT:
                    params.gravity = Gravity.START | Gravity.CENTER_HORIZONTAL;
                    break;
                case CENTER:
                    params.gravity = Gravity.CENTER | Gravity.CENTER_HORIZONTAL;
                    break;
                case RIGHT:
                    params.gravity = Gravity.END | Gravity.CENTER_HORIZONTAL;
                    break;
            }

            item.setLayoutParams(params);
            if (item.getParent() == null) {
                mToolbar.addView(item);
            }
        }
    }

    public void setBottomBorderColor(int color) {
        mBottomBorderView.setBackgroundColor(color);
    }

    @Override
    public void setBackgroundColor(int color) {
        mToolbar.setBackgroundColor(color);
    }


}
