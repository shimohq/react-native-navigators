package im.shimo.navigators;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Color;
import android.graphics.Paint;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.ResultReceiver;
import android.util.Log;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.facebook.react.bridge.GuardedRunnable;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.uimanager.PointerEvents;
import com.facebook.react.uimanager.ReactPointerEventsView;
import com.facebook.react.uimanager.UIManagerModule;
import com.facebook.react.views.textinput.ReactEditText;

@SuppressLint("ViewConstructor")
public class Scene extends ViewGroup implements ReactPointerEventsView {
    static final String TAG = "Scene";
    private static int actionBarHeight;
    private TextView mFocusedView;


    public enum StackAnimation {
        DEFAULT,
        NONE,
        SLIDE_FROM_TOP,
        SLIDE_FROM_RIGHT,
        SLIDE_FROM_BOTTOM,
        SLIDE_FROM_LEFT
    }

    private static OnAttachStateChangeListener sShowSoftKeyboardOnAttach = new OnAttachStateChangeListener() {

        @Override
        public void onViewAttachedToWindow(View view) {
            ((ReactEditText) view).requestFocusFromJS();
//            InputMethodManager inputMethodManager =
//                    (InputMethodManager) view.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
//            inputMethodManager.showSoftInput(view, 0);
            view.removeOnAttachStateChangeListener(sShowSoftKeyboardOnAttach);
        }

        @Override
        public void onViewDetachedFromWindow(View view) {

        }
    };

    @Nullable
    private SceneContainer mContainer;
    private boolean mClosing = false;
    private boolean mTransitioning;
    private boolean mIsTransparent = false;
    private StackAnimation mStackAnimation = StackAnimation.DEFAULT;

    private boolean mIsTranslucent = false;

    private boolean mHasHeader = false;


    public Scene(ReactContext context) {
        super(context);
        maybeInitActionBarSize(context);
    }

    private void maybeInitActionBarSize(Context context) {
        if (actionBarHeight == 0) {
            TypedValue tv = new TypedValue();
            if (context.getTheme().resolveAttribute(android.R.attr.actionBarSize, tv, true)) {
                actionBarHeight = TypedValue.complexToDimensionPixelSize(tv.data, context.getResources().getDisplayMetrics());
            }
        }
    }


    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        mHasHeader = false;
        final int count = getChildCount();
        for (int i = 0; i < count; i++) {
            View child = getChildAt(i);
            if (child instanceof SceneStackHeader) {
                measureActionBar(child);
                mHasHeader = true;
            } else {
                measureChild(child);
            }
        }

    }

    public boolean hasHeader() {
        return mHasHeader;
    }

    private void measureActionBar(View child) {
        int childWidthMeasureSpec = MeasureSpec.makeMeasureSpec(getWidth(),
                MeasureSpec.EXACTLY);
        int childHeightMeasureSpec = MeasureSpec.makeMeasureSpec(actionBarHeight,
                MeasureSpec.EXACTLY);
        child.measure(childWidthMeasureSpec, childHeightMeasureSpec);
    }

    private void measureChild(View child) {
        int childWidthMeasureSpec = MeasureSpec.makeMeasureSpec(getWidth(),
                MeasureSpec.EXACTLY);
        int height = mHasHeader ? getHeight() - actionBarHeight : getHeight();
        int childHeightMeasureSpec = MeasureSpec.makeMeasureSpec(height,
                MeasureSpec.EXACTLY);
        child.measure(childWidthMeasureSpec, childHeightMeasureSpec);

    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        for (int i = 0, size = getChildCount(); i < size; i++) {
            View child = getChildAt(i);
            if (child instanceof SceneStackHeader) {
                child.layout(0, 0, getWidth(), actionBarHeight);
            } else {
                int top = mHasHeader && !mIsTranslucent ? actionBarHeight : 0;
                child.layout(0, top, getWidth(), getHeight());
            }
        }
        if (changed) {
            final int width = r - l;
            final int height = b - t;
            final ReactContext reactContext = (ReactContext) getContext();
            reactContext.runOnNativeModulesQueueThread(
                    new GuardedRunnable(reactContext.getExceptionHandler()) {
                        @Override
                        public void runGuarded() {
                            reactContext.getNativeModule(UIManagerModule.class)
                                    .updateNodeSize(getId(), width, height);
                        }
                    });
        }
    }


    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        clearDisappearingChildren();
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();


        // This method implements a workaround for RN's autoFocus functionality. Because of the way
        // autoFocus is implemented it sometimes gets triggered before native text view is mounted. As
        // a result Android ignores calls for opening soft keyboard and here we trigger it manually
        // again after the scene is attached.
//        View view = getFocusedChild();
//        if (view != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
//            while (view instanceof ViewGroup) {
//                view = ((ViewGroup) view).getFocusedChild();
//            }
//            if (view instanceof TextView) {
//                TextView textView = (TextView) view;
//                if (textView.getShowSoftInputOnFocus()) {
//                    textView.addOnAttachStateChangeListener(sShowSoftKeyboardOnAttach);
//                }
//            }
//        }
//        if (mFocusedView != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
//            if (mFocusedView.getShowSoftInputOnFocus()) {
////                mFocusedView.addOnAttachStateChangeListener(sShowSoftKeyboardOnAttach);
//                if (mFocusedView instanceof ReactEditText) {
//                    ((ReactEditText) mFocusedView).requestFocusFromJS();
//                    final InputMethodManager imm =
//                            (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
//                    imm.showSoftInput(mFocusedView, 0, new ResultReceiver(new Handler()) {
//                        @Override
//                        protected void onReceiveResult(int resultCode, Bundle resultData) {
//                            if (resultCode == InputMethodManager.RESULT_UNCHANGED_HIDDEN
//                                    || resultCode == InputMethodManager.RESULT_HIDDEN) {
//                                imm.toggleSoftInput(InputMethodManager.SHOW_IMPLICIT, 0);
//                            }
//                        }
//                    });
//                    imm.toggleSoftInput(InputMethodManager.SHOW_FORCED, InputMethodManager.HIDE_NOT_ALWAYS);
//
//                }
//            }
//        }
    }

    public void saveFocusedView() {
        View view = getFocusedChild();
        mFocusedView = null;
        if (view != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            while (view instanceof ViewGroup) {
                view = ((ViewGroup) view).getFocusedChild();
            }
            if (view instanceof TextView) {
                mFocusedView = (TextView) view;
            }
        }

    }


    public void restoreFocus() {
        if (mFocusedView != null) {
            final ReactContext reactContext = (ReactContext) getContext();
            reactContext.runOnUiQueueThread(new Runnable() {
                @Override
                public void run() {
                    if (mFocusedView instanceof ReactEditText) {
                        ((ReactEditText) mFocusedView).requestFocusFromJS();
                    }

                    final InputMethodManager imm =
                            (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
                    imm.showSoftInput(mFocusedView, 0, new ResultReceiver(new Handler()) {
                        @Override
                        protected void onReceiveResult(int resultCode, Bundle resultData) {
                            if (resultCode == InputMethodManager.RESULT_UNCHANGED_HIDDEN
                                    || resultCode == InputMethodManager.RESULT_HIDDEN) {
                                imm.toggleSoftInput(0, 0);
                            }
                        }
                    });
                    imm.toggleSoftInput(InputMethodManager.SHOW_FORCED, InputMethodManager.HIDE_IMPLICIT_ONLY);
                }
            });

        }
    }

    /**
     * While transitioning this property allows to optimize rendering behavior on Android and provide
     * a correct blending options for the animated scene. It is turned on automatically by the container
     * when transitioning is detected and turned off immediately after
     */
    public void setTransitioning(boolean transitioning) {
        if (mTransitioning == transitioning) {
            return;
        }
        mTransitioning = transitioning;
        super.setLayerType(transitioning ? View.LAYER_TYPE_HARDWARE : View.LAYER_TYPE_NONE, null);
    }


    public void setStackAnimation(StackAnimation stackAnimation) {
        mStackAnimation = stackAnimation;
    }

    public StackAnimation getStackAnimation() {
        return mStackAnimation;
    }

    public void setTransparent(boolean transparent) {
        mIsTransparent = transparent;
    }

    public boolean isTransparent() {
        return mIsTransparent;
    }

    @Override
    public PointerEvents getPointerEvents() {
        return mTransitioning ? PointerEvents.NONE : PointerEvents.AUTO;
    }

    @Override
    public void setLayerType(int layerType, @Nullable Paint paint) {
        // ignore - layer type is controlled by `transitioning` prop
    }

    protected void setContainer(@Nullable SceneContainer container) {
        mContainer = container;
    }

//    public void updateHeader() {
//        final int count = getChildCount();
//        for (int i = 0; i < count; i++) {
//            View child = getChildAt(i);
//            if (child instanceof SceneStackHeader) {
//                ((SceneStackHeader) child).onUpdate();
//            }
//        }
//    }

    @Nullable
    protected SceneContainer getSceneContainer() {
        return mContainer;
    }

    public void setClosing(boolean closing) {
        if (mClosing == closing) return;
        mClosing = closing;
        if (mContainer != null) {
            mContainer.notifyChildUpdate();
        }
    }

    public boolean isClosing() {
        return mClosing;
    }

    public void setTranslucent(boolean translucent) {

        for (int i = 0, size = getChildCount(); i < size; i++) {
            View child = getChildAt(i);
            Log.d(TAG, "setTranslucent() called with: child = [" + child + "], i = [" + i + "]");
            if (child instanceof SceneStackHeader) {
                child.setBackgroundColor(Color.BLACK);
                child.setAlpha(0.8f);
            }
        }
        mIsTranslucent = translucent;
        requestLayout();
    }

}
