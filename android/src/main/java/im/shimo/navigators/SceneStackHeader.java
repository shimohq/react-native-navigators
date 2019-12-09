package im.shimo.navigators;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Color;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.WindowManager;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import com.facebook.react.bridge.ReactContext;

public class SceneStackHeader extends ViewGroup {

    private static final String TAG = "SceneStackHeader";

    private boolean mIsAttachedToWindow = false;
    private static final int[] attrs = new int[]{
            R.attr.headerBackgroundColor,
            R.attr.headerBorderColor,
            R.attr.headerBorderSize
    };

    private Toolbar mToolbar;
    private View mBottomBorderView;
    private int bottomBorderSize;
    int actionBarHeight = 0;
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


        if (context.getTheme().resolveAttribute(android.R.attr.actionBarSize, typedValue, true)) {
            actionBarHeight = TypedValue.complexToDimensionPixelSize(typedValue.data, context.getResources().getDisplayMetrics());
        }

        mToolbar = new Toolbar(context);
        mToolbar.setBackgroundColor(backBackgroundColor);
        Activity activity = ((ReactContext) context).getCurrentActivity();
        if (activity != null) {
            int windowFlags = activity.getWindow().getAttributes().flags;
            if (((windowFlags & WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS) != 0 &&
                    ((activity.getWindow().getDecorView().getSystemUiVisibility() & (View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                            | View.SYSTEM_UI_FLAG_LAYOUT_STABLE)) != 0))
                    || (windowFlags & WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS) != 0) {
                int resourceId = getResources().getIdentifier("status_bar_height", "dimen", "android");
                int statusBarHeight = getResources().getDimensionPixelSize(resourceId);
                mToolbar.setPadding(0, statusBarHeight, 0, 0);
            }
        }
        mToolbar.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, (actionBarHeight + mToolbar.getPaddingTop())));
        ((AppCompatActivity) ((ReactContext) getContext()).getCurrentActivity()).setSupportActionBar(mToolbar);
        mBottomBorderView = new View(context);
        mBottomBorderView.setBackgroundColor(bottomBorderColor);
        addViewInLayout(mToolbar, 0, generateDefaultLayoutParams());
        addViewInLayout(mBottomBorderView, 1, generateDefaultLayoutParams());
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        if (MeasureSpec.getMode(widthMeasureSpec) == MeasureSpec.EXACTLY && MeasureSpec.getMode(heightMeasureSpec) == MeasureSpec.EXACTLY) {
//            setMeasuredDimension(MeasureSpec.getSize(widthMeasureSpec), MeasureSpec.getSize(heightMeasureSpec));
            setMeasuredDimension(MeasureSpec.getSize(widthMeasureSpec), MeasureSpec.makeMeasureSpec(actionBarHeight + mToolbar.getPaddingTop(), MeasureSpec.EXACTLY));

        }
        int childHeightMeasureSpec = MeasureSpec.makeMeasureSpec(bottomBorderSize, MeasureSpec.EXACTLY);
        mBottomBorderView.measure(widthMeasureSpec, childHeightMeasureSpec);
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        mToolbar.layout(left, top, right, bottom);
        mBottomBorderView.layout(left, bottom - mBottomBorderView.getMeasuredHeight(), right, bottom);
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        mIsAttachedToWindow = true;
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mIsAttachedToWindow = false;
    }

    public View getHeaderItem(int index) {
        return mToolbar.getChildAt(index);
    }

    public int getHeaderItemCount() {
        return mToolbar.getChildCount();
    }

    public void removeHeaderItemView(int index) {
        mToolbar.removeViewAt(index);
    }

    public void addHeaderItemView(SceneStackHeaderItem child, int index) {
        SceneStackHeaderItem.Type type = child.getType();
        Toolbar.LayoutParams params =
                new Toolbar.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
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
        child.setLayoutParams(params);
        mToolbar.addView(child, index);
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

    public void setBottomBorderColor(int color) {
        mBottomBorderView.setBackgroundColor(color);
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


    public void onUpdate() {
        Scene parent = (Scene) getParent();
        final SceneStack stack = getScreenStack();

        boolean isRoot = stack == null || stack.getRootScreen() == parent;
        boolean isTop = stack == null || stack.getTopScene() == parent;

        if (!mIsAttachedToWindow || !isTop) {
            return;
        }

        AppCompatActivity activity = (AppCompatActivity) ((ReactContext) getContext()).getCurrentActivity();
        activity.setSupportActionBar(mToolbar);

    }


    private static class Bar extends ViewGroup {

        public Bar(Context context) {
            super(context);
        }

        @Override
        protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
            int count = getChildCount();
            int l, t, r, b;
            for (int i = 0; i < count; i++) {
                SceneStackHeaderItem item = (SceneStackHeaderItem) getChildAt(i);
                final SceneStackHeaderItem.Type type = item.getType();
                t = top + ((bottom - top) - item.getMeasuredHeight()) >> 1;
                b = t + item.getMeasuredHeight();
                switch (type) {
                    default:
                    case LEFT:
                        l = left;
                        r = l + item.getMeasuredWidth();
                        break;
                    case RIGHT:
                        r = right;
                        l = r - item.getMeasuredWidth();
                        break;
                    case CENTER:
                        l = left + ((right - left) - item.getMeasuredWidth()) >> 1;
                        r = l + item.getMeasuredWidth();
                        break;
                }
                item.layout(l, t, r, b);
            }
        }
    }


}