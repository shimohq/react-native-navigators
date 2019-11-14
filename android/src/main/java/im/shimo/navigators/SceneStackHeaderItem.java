package im.shimo.navigators;

import android.annotation.SuppressLint;
import android.view.View;
import android.view.ViewParent;

import com.facebook.react.bridge.ReactContext;
import com.facebook.react.uimanager.UIManagerModule;
import com.facebook.react.views.view.ReactViewGroup;

@SuppressLint("ViewConstructor")
public class SceneStackHeaderItem extends ReactViewGroup {

    static class Measurements {
        public int width;
        public int height;
    }

    public enum Type {
        LEFT,
        CENTER,
        RIGHT
    }

    private int mReactWidth, mReactHeight;
    private final UIManagerModule mUIManager;
    private Type mType = Type.RIGHT;

    public SceneStackHeaderItem(ReactContext context) {
        super(context);
        mUIManager = context.getNativeModule(UIManagerModule.class);
    }


    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        if (MeasureSpec.getMode(widthMeasureSpec) == MeasureSpec.EXACTLY &&
                MeasureSpec.getMode(heightMeasureSpec) == MeasureSpec.EXACTLY) {
            // dimensions provided by react
            mReactWidth = MeasureSpec.getSize(widthMeasureSpec);
            mReactHeight = MeasureSpec.getSize(heightMeasureSpec);
            ViewParent parent = getParent();
            if (parent != null) {
                forceLayout();
                ((View) parent).requestLayout();
            }
        }
        setMeasuredDimension(mReactWidth, mReactHeight);
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        if (changed && (mType == Type.CENTER)) {
            @SuppressLint("DrawAllocation")
            Measurements measurements = new Measurements();
            measurements.width = right - left;
            if (mType == Type.CENTER) {
                // if we want the view to be centered we need to account for the fact that right and left
                // paddings may not be equal.
                View parent = (View) getParent();
                int parentWidth = parent.getWidth();
                int rightPadding = parentWidth - right;
                measurements.width = Math.max(0, parentWidth - 2 * Math.max(rightPadding, left));
            }
            measurements.height = bottom - top;
            mUIManager.setViewLocalData(getId(), measurements);
        }
        super.onLayout(changed, left, top, right, bottom);
    }


    public void setType(Type type) {
        mType = type;
    }

    public Type getType() {
        return mType;
    }
}
