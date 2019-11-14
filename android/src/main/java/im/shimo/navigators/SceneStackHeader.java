package im.shimo.navigators;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Color;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;

public class SceneStackHeader extends ViewGroup {

    private static final String TAG = "SceneStackHeader";

    private boolean mIsAttachedToWindow = false;
    private static final int[] attrs = new int[]{
            R.attr.headerBackgroundColor,
            R.attr.headerBorderColor,
            R.attr.headerBorderSize
    };

    private Bar mBar;
    private View mBottomBorderView;
    private int bottomBorderSize;

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

        mBar = new Bar(context);
        setBackgroundColor(backBackgroundColor);
        mBottomBorderView = new View(context);
        mBottomBorderView.setBackgroundColor(bottomBorderColor);
        addViewInLayout(mBar, 0, generateDefaultLayoutParams());
        addViewInLayout(mBottomBorderView, 1, generateDefaultLayoutParams());
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        if (MeasureSpec.getMode(widthMeasureSpec) == MeasureSpec.EXACTLY && MeasureSpec.getMode(heightMeasureSpec) == MeasureSpec.EXACTLY) {
            setMeasuredDimension(MeasureSpec.getSize(widthMeasureSpec), MeasureSpec.getSize(heightMeasureSpec));
        }
        int childHeightMeasureSpec = MeasureSpec.makeMeasureSpec(bottomBorderSize, MeasureSpec.EXACTLY);
        mBottomBorderView.measure(widthMeasureSpec, childHeightMeasureSpec);
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        mBar.layout(left, top, right, bottom);
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
        return mBar.getChildAt(index);
    }

    public int getHeaderItemCount() {
        return mBar.getChildCount();
    }

    public void removeHeaderItemView(int index) {
        mBar.removeViewAt(index);
    }

    public void addHeaderItemView(SceneStackHeaderItem child, int index) {
        mBar.addView(child, index);
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

    @Override
    protected boolean checkLayoutParams(ViewGroup.LayoutParams p) {
        return p instanceof LayoutParams;
    }

    @Override
    protected ViewGroup.LayoutParams generateDefaultLayoutParams() {
        return new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
    }

    @Override
    public ViewGroup.LayoutParams generateLayoutParams(AttributeSet attrs) {
        return new LayoutParams(getContext(), attrs);
    }

    @Override
    protected ViewGroup.LayoutParams generateLayoutParams(ViewGroup.LayoutParams p) {
        return new LayoutParams(p);
    }


    public static class LayoutParams extends MarginLayoutParams {

        public LayoutParams(Context c, AttributeSet attrs) {
            super(c, attrs);
        }

        public LayoutParams(int width, int height) {
            super(width, height);
        }

        public LayoutParams(MarginLayoutParams source) {
            super(source);
        }

        public LayoutParams(ViewGroup.LayoutParams source) {
            super(source);
        }
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
