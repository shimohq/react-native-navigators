package im.shimo.navigators;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Paint;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.ResultReceiver;
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
import com.facebook.react.uimanager.events.EventDispatcher;
import com.facebook.react.views.textinput.ReactEditText;

import im.shimo.navigators.event.DidBlurEvent;
import im.shimo.navigators.event.DidFocusEvent;
import im.shimo.navigators.event.WillBlurEvent;
import im.shimo.navigators.event.WillFocusEvent;

@SuppressLint("ViewConstructor")
public class Scene extends ViewGroup implements ReactPointerEventsView {
    static final String TAG = "Scene";
    private TextView mFocusedView;
    private SceneStatus mStatus = SceneStatus.DID_BLUR;

    private static OnAttachStateChangeListener sShowSoftKeyboardOnAttach = new OnAttachStateChangeListener() {

        @Override
        public void onViewAttachedToWindow(View view) {
            ((ReactEditText) view).requestFocusFromJS();
            InputMethodManager inputMethodManager =
                    (InputMethodManager) view.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
            inputMethodManager.showSoftInput(view, 0);
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

    private boolean mDismissed = false;


    public Scene(ReactContext context) {
        super(context);
    }



    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        int top = 0;
        if (changed) {
            final int width = r - l;
            final int height = b - t - top;
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
//        clearDisappearingChildren();
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();

        mDismissed = true;

        // This method implements a workaround for RN's autoFocus functionality. Because of the way
        // autoFocus is implemented it sometimes gets triggered before native text view is mounted. As
        // a result Android ignores calls for opening soft keyboard and here we trigger it manually
        // again after the scene is attached.
        View view = getFocusedChild();
        if (view != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            while (view instanceof ViewGroup) {
                view = ((ViewGroup) view).getFocusedChild();
            }
            if (view instanceof TextView) {
                TextView textView = (TextView) view;
                if (textView.getShowSoftInputOnFocus()) {
                    textView.addOnAttachStateChangeListener(sShowSoftKeyboardOnAttach);
                }
            }
        }
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
        // TODO: 2019-12-06 动画优化？
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

    public SceneStatus getStatus() {
        return mStatus;
    }

    public void setStatus(SceneStatus status) {
        setStatus(status, false);
    }

    public void setStatus(SceneStatus status, boolean dismissed) {
        if (dismissed && status == SceneStatus.DID_BLUR && !mDismissed) {
            mDismissed = true;
        } else if (mStatus == status
                || (mStatus == SceneStatus.DID_BLUR && status == SceneStatus.WILL_BLUR)
                || (mStatus == SceneStatus.DID_FOCUS && status == SceneStatus.WILL_FOCUS)) {
            return;
        }
        mStatus = status;
        sendEvent(status, dismissed);
    }

    @Override
    public PointerEvents getPointerEvents() {
//        return mTransitioning ? PointerEvents.NONE : PointerEvents.AUTO;
        return PointerEvents.AUTO;
    }

    @Override
    public void setLayerType(int layerType, @Nullable Paint paint) {
        // ignore - layer type is controlled by `transitioning` prop
    }

    protected void setContainer(@Nullable SceneContainer container) {
        mContainer = container;
    }


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
        clearDisappearingChildren();
    }

    public boolean isClosing() {
        return mClosing;
    }

    private void sendEvent(SceneStatus status, boolean isDismissed) {
        final EventDispatcher eventDispatcher = ((ReactContext) getContext())
                .getNativeModule(UIManagerModule.class)
                .getEventDispatcher();

        switch (status) {
            case DID_BLUR:
                eventDispatcher.dispatchEvent(new DidBlurEvent(getId(), isDismissed));
                break;
            case WILL_BLUR:
                eventDispatcher.dispatchEvent(new WillBlurEvent(getId()));
                break;
            case DID_FOCUS:
                eventDispatcher.dispatchEvent(new DidFocusEvent(getId()));
                break;
            case WILL_FOCUS:
                eventDispatcher.dispatchEvent(new WillFocusEvent(getId()));
                break;
            default:
                break;
        }
    }


    public enum SceneStatus {
        DID_BLUR,
        WILL_BLUR,
        DID_FOCUS,
        WILL_FOCUS
    }

    public enum StackAnimation {
        DEFAULT,
        NONE,
        SLIDE_FROM_TOP,
        SLIDE_FROM_RIGHT,
        SLIDE_FROM_BOTTOM,
        SLIDE_FROM_LEFT
    }


}
