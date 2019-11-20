package im.shimo.navigators;

import android.content.Context;
import android.content.ContextWrapper;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.animation.Animation;

import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentTransaction;

import com.facebook.react.ReactRootView;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.modules.core.ChoreographerCompat;
import com.facebook.react.modules.core.ReactChoreographer;
import com.facebook.react.uimanager.UIManagerModule;
import com.facebook.react.uimanager.events.EventDispatcher;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

import im.shimo.navigators.event.DidBlurEvent;
import im.shimo.navigators.event.DidFocusEvent;
import im.shimo.navigators.event.WillBlurEvent;
import im.shimo.navigators.event.WillFocusEvent;

/**
 * Created by jiang on 2019-11-06
 */

public abstract class SceneContainer<T extends SceneFragment> extends ViewGroup {

    private static final String TAG = "SceneContainer";
    protected final ArrayList<T> mSceneFragments = new ArrayList<>();
    protected final ArrayList<T> mStack = new ArrayList<>();

    protected final Set<SceneFragment> mDismissed = new HashSet<>();


    @Nullable
    private FragmentTransaction mCurrentTransaction;

    private boolean mNeedUpdate;
    private boolean mIsAttached;

    protected SceneFragment mTopScene = null;


    private ChoreographerCompat.FrameCallback mFrameCallback = new ChoreographerCompat.FrameCallback() {
        @Override
        public void doFrame(long frameTimeNanos) {
            updateIfNeeded();
        }
    };

    public SceneContainer(Context context) {
        super(context);
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        // no-op
    }

    @SuppressWarnings("unchecked")
    protected T adapt(Scene scene) {
        return (T) new SceneFragment(scene);
    }

    protected void markUpdated() {
        if (!mNeedUpdate) {
            mNeedUpdate = true;
            // enqueue callback of NATIVE_ANIMATED_MODULE type as all view operations are executed in
            // DISPATCH_UI type and we want the callback to be called right after in the same frame.
            ReactChoreographer.getInstance().postFrameCallback(
                    ReactChoreographer.CallbackType.NATIVE_ANIMATED_MODULE,
                    mFrameCallback);
        }
    }

    protected void notifyChildUpdate() {
        markUpdated();
    }


    protected void addScene(Scene scene, int index) {
        T fragment = adapt(scene);
        scene.setFragment(fragment);
        mSceneFragments.add(index, fragment);
        scene.setContainer(this);
        markUpdated();
    }

    protected void removeSceneAt(int index) {
        mSceneFragments.get(index).getScene().setContainer(null);
        mSceneFragments.remove(index);
        markUpdated();
    }

    protected int getSceneCount() {
        return mSceneFragments.size();
    }


    protected Scene getSceneAt(int index) {
        return mSceneFragments.get(index).getScene();
    }


    protected final FragmentActivity findRootFragmentActivity() {
        ViewParent parent = this;
        while (!(parent instanceof ReactRootView) && parent.getParent() != null) {
            parent = parent.getParent();
        }
        // we expect top level view to be of type ReactRootView, this isn't really necessary but in order
        // to find root view we test if parent is null. This could potentially happen also when the view
        // is detached from the hierarchy and that test would not correctly indicate the root view. So
        // in order to make sure we indeed reached the root we test if it is of a correct type. This
        // allows us to provide a more descriptive error message for the aforementioned case.
        if (!(parent instanceof ReactRootView)) {
            throw new IllegalStateException("ScreenContainer is not attached under ReactRootView");
        }
        // ReactRootView is expected to be initialized with the main React Activity as a context but
        // in case of Expo the activity is wrapped in ContextWrapper and we need to unwrap it
        Context context = ((ReactRootView) parent).getContext();
        while (!(context instanceof FragmentActivity) && context instanceof ContextWrapper) {
            context = ((ContextWrapper) context).getBaseContext();
        }
        if (!(context instanceof FragmentActivity)) {
            throw new IllegalStateException(
                    "In order to use RNScreens components your app's activity need to extend ReactFragmentActivity or ReactCompatActivity");
        }
        return (FragmentActivity) context;
    }


    protected FragmentTransaction getOrCreateTransaction() {
        if (mCurrentTransaction == null) {
            mCurrentTransaction = findRootFragmentActivity().getSupportFragmentManager().beginTransaction();
            mCurrentTransaction.setReorderingAllowed(true);
        }
        return mCurrentTransaction;
    }

    protected void tryCommitTransaction() {
        if (mCurrentTransaction != null) {
            mCurrentTransaction.commitAllowingStateLoss();
            mCurrentTransaction = null;
        }
    }

    private void attachScreen(SceneFragment sceneFragment) {
        getOrCreateTransaction().add(getId(), sceneFragment);
//        mActiveScreenFragments.add(sceneFragment);
    }

    private void moveToFront(SceneFragment screenFragment) {
        FragmentTransaction transaction = getOrCreateTransaction();
        transaction.remove(screenFragment);
        transaction.add(getId(), screenFragment);
    }

    private void detachScreen(SceneFragment screenFragment) {
        getOrCreateTransaction().remove(screenFragment);
//        mActiveScreenFragments.remove(screenFragment);
    }

//    protected boolean isScreenActive(SceneFragment screenFragment) {
//        return screenFragment.getScene().isActive();
//    }


    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        mIsAttached = true;
        updateIfNeeded();
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mIsAttached = false;
    }

    private void updateIfNeeded() {
        if (!mNeedUpdate || !mIsAttached) {
            return;
        }
        mNeedUpdate = false;
        onUpdate();
    }

    public Scene getRootScreen() {
        for (int i = 0, size = getSceneCount(); i < size; i++) {
            Scene scene = getSceneAt(i);
            if (!mDismissed.contains(scene.getFragment())) {
                return scene;
            }
        }
        throw new IllegalStateException("Stack has no root screen set");
    }

    public Scene getTopScene() {
        return mTopScene.getScene();
    }


    protected void onUpdate() {
        for (SceneFragment fragment : mSceneFragments) {
            if (fragment.getScene().isClosing()) {
                mDismissed.add(fragment);
            }
//            if (!mStack.contains(fragment)) {
//                mWellAdded.add(fragment);
//            }
        }


        SceneFragment newTop = null;
        SceneFragment belowTop = null;

        // find top scene
        for (int i = mSceneFragments.size() - 1; i >= 0; i--) {
            SceneFragment fragment = mSceneFragments.get(i);
            if (!mDismissed.contains(fragment)) {
                if (newTop == null) {
                    newTop = fragment;
                } else {
                    belowTop = fragment;
                    break;
                }
            }
        }
        if (newTop == null) return;

        if (newTop.getScene().isTransparent()) {
            mDismissed.add(belowTop);
        }
        final SceneFragment finalNewTop = newTop;
        final SceneFragment finalBelowTop = belowTop;
        int[] animIds = new int[2];
        boolean isPushAction = false;
        if (!mStack.contains(newTop)) {
            isPushAction = true;
            getAnimationOnPush(newTop.getScene(), animIds);
            for (SceneFragment scene : mSceneFragments) {
                if (scene != finalNewTop && !mDismissed.contains(scene)
                        && scene.isVisible()) {
                    scene.getScene().saveFocusedView();
                }
            }
            getOrCreateTransaction().setCustomAnimations(animIds[0], animIds[1]);
            newTop.setAnimationListener(new Animation.AnimationListener() {
                @Override
                public void onAnimationStart(Animation animation) {
                    onPushStart(finalNewTop, finalBelowTop);
                }

                @Override
                public void onAnimationEnd(Animation animation) {
                    onPushEnd(finalNewTop, finalBelowTop);
                }

                @Override
                public void onAnimationRepeat(Animation animation) {

                }
            });


        } else if (mTopScene != null && !mTopScene.equals(newTop)) { // out
            getAnimationOnPop(mTopScene.getScene(), animIds);
            getOrCreateTransaction().setCustomAnimations(animIds[0], animIds[1]);
            mTopScene.setAnimationListener(new Animation.AnimationListener() {
                @Override
                public void onAnimationStart(Animation animation) {
                    onPopStart(finalNewTop);
                }

                @Override
                public void onAnimationEnd(Animation animation) {
                    onPopEnd(finalNewTop);
                }

                @Override
                public void onAnimationRepeat(Animation animation) {

                }
            });

        }

        for (SceneFragment scene : mStack) {
            if (!mSceneFragments.contains(scene) || mDismissed.contains(scene)) {
                getOrCreateTransaction().remove(scene);
            }
        }
        for (SceneFragment sceneFragment : mSceneFragments) {
            if (!mStack.contains(sceneFragment) && !mDismissed.contains(sceneFragment)) {
                getOrCreateTransaction().add(getId(), sceneFragment);
            }
            if (sceneFragment != newTop && !mDismissed.contains(sceneFragment)) {
                getOrCreateTransaction().hide(sceneFragment);
            }
        }
        getOrCreateTransaction().show(newTop);

        mTopScene = newTop;

        mStack.clear();
        mStack.addAll(mSceneFragments);
        tryCommitTransaction();
        if (animIds[0] == 0 && animIds[1] == 0) {
            if (isPushAction) {
                onPushStart(finalNewTop, finalBelowTop);
                onPushEnd(finalNewTop, finalBelowTop);
            } else {
                onPopStart(finalNewTop);
                onPopEnd(finalNewTop);
            }
        }

    }

    private void onPopEnd(SceneFragment finalNewTop) {
        final EventDispatcher eventDispatcher = ((ReactContext) getContext())
                .getNativeModule(UIManagerModule.class)
                .getEventDispatcher();

        ((ReactContext) getContext())
                .getNativeModule(UIManagerModule.class)
                .getEventDispatcher()
                .dispatchEvent(new DidFocusEvent(finalNewTop.getScene().getId()));

        for (SceneFragment scene : mDismissed) {
            eventDispatcher.dispatchEvent(new DidBlurEvent(scene.getScene().getId(), true));
        }
        mDismissed.clear();
    }

    private void onPopStart(SceneFragment finalNewTop) {
        finalNewTop.getScene().restoreFocus();
        final EventDispatcher eventDispatcher = ((ReactContext) getContext())
                .getNativeModule(UIManagerModule.class)
                .getEventDispatcher();
        for (SceneFragment scene : mDismissed) {
            eventDispatcher.dispatchEvent(new WillBlurEvent(scene.getScene().getId()));
        }
        eventDispatcher
                .dispatchEvent(new WillFocusEvent(mTopScene.getScene().getId()));
    }

    private void onPushEnd(SceneFragment finalNewTop, SceneFragment finalBelowTop) {
        ((ReactContext) getContext())
                .getNativeModule(UIManagerModule.class)
                .getEventDispatcher()
                .dispatchEvent(new DidFocusEvent(finalNewTop.getId()));
        if (finalBelowTop != null) {
            ((ReactContext) getContext())
                    .getNativeModule(UIManagerModule.class)
                    .getEventDispatcher()
                    .dispatchEvent(new DidBlurEvent(finalBelowTop.getScene().getId(), false));
        }
    }

    private void onPushStart(SceneFragment finalNewTop, SceneFragment finalBelowTop) {
        ((ReactContext) getContext())
                .getNativeModule(UIManagerModule.class)
                .getEventDispatcher()
                .dispatchEvent(new WillFocusEvent(finalNewTop.getScene().getId()));
        if (finalBelowTop != null) {
            ((ReactContext) getContext())
                    .getNativeModule(UIManagerModule.class)
                    .getEventDispatcher()
                    .dispatchEvent(new WillBlurEvent(finalBelowTop.getScene().getId()));
        }
    }

    abstract void getAnimationOnPush(Scene scene, int[] anim);

    abstract void getAnimationOnPop(Scene scene, int[] anim);

}
