package im.shimo.navigators;

import android.content.Context;

public class SceneStack extends SceneContainer {


    private static final String TAG = "SceneStack";

    private boolean mLayoutEnqueued = false;


    public SceneStack(Context context) {
        super(context);
    }


    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        for (int i = 0, size = getChildCount(); i < size; i++) {
            getChildAt(i).layout(0, 0, getWidth(), getHeight());
        }
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        for (int i = 0, size = getChildCount(); i < size; i++) {
            getChildAt(i).measure(widthMeasureSpec, heightMeasureSpec);
        }
    }


    private final Runnable mLayoutRunnable = new Runnable() {
        @Override
        public void run() {
            mLayoutEnqueued = false;
            measure(MeasureSpec.makeMeasureSpec(getWidth(), MeasureSpec.EXACTLY),
                    MeasureSpec.makeMeasureSpec(getHeight(), MeasureSpec.EXACTLY));
            layout(getLeft(), getTop(), getRight(), getBottom());
        }
    };

    @Override
    public void requestLayout() {
        super.requestLayout();
        if (!mLayoutEnqueued) {
            mLayoutEnqueued = true;
            post(mLayoutRunnable);
        }
    }


}
