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
import com.facebook.react.modules.core.ChoreographerCompat;
import com.facebook.react.modules.core.ReactChoreographer;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

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
        int size = mStack.size();
        return size > 0 ? mStack.get(size - 1).getScene() : null;
    }

    protected void onUpdate() {
        final ArrayList<T> nextFragments = new ArrayList<>();
        for (T fragment: mSceneFragments) {
            if (!fragment.getScene().isClosing()) {
                nextFragments.add(fragment);
            }
        }

        final ArrayList<T> removedFragments = new ArrayList<>();
        for (T fragment: mStack) {
            if (fragment.getScene().isClosing() || !mSceneFragments.contains(fragment)) {
                removedFragments.add(fragment);
            }
        }

        ArrayList<T> insertedFragments = new ArrayList<>();
        for (T fragment: nextFragments) {
            if (!mStack.contains(fragment)) {
                insertedFragments.add(fragment);
            }
        }

        // find top scene
        T nextTopFragment = nextFragments.size() > 0 ? nextFragments.get(nextFragments.size() - 1) : null;
        T currentTopFragment = mStack.size() > 0 ? mStack.get(mStack.size() - 1) : null;

        // save or restore focused view
        if (currentTopFragment != nextTopFragment) {
            if (currentTopFragment != null && !removedFragments.contains(currentTopFragment)) {
                currentTopFragment.getScene().saveFocusedView();
            }
            if (nextTopFragment != null && mStack.contains(nextTopFragment)) {
                nextTopFragment.getScene().restoreFocus();
            }
        }

        int[] animIds = new int[2];
        boolean isPushAction = false;
        if (currentTopFragment != null && currentTopFragment != nextTopFragment) {
            if (nextTopFragment != null && !mStack.contains(nextTopFragment)) { // push
                isPushAction = true;
                getAnimationOnPush(nextTopFragment.getScene(), animIds);
                getOrCreateTransaction().setCustomAnimations(animIds[0], animIds[1]);
                nextTopFragment.setAnimationListener(new Animation.AnimationListener() {
                    @Override
                    public void onAnimationStart(Animation animation) {
                        onPushStart(nextFragments, removedFragments);
                    }

                    @Override
                    public void onAnimationEnd(Animation animation) {
                        onPushEnd(nextFragments, removedFragments);
                    }

                    @Override
                    public void onAnimationRepeat(Animation animation) {

                    }
                });
            } else if (!nextFragments.contains(currentTopFragment)) { // pop
                getAnimationOnPop(currentTopFragment.getScene(), animIds);
                getOrCreateTransaction().setCustomAnimations(animIds[0], animIds[1]);
                currentTopFragment.setAnimationListener(new Animation.AnimationListener() {
                    @Override
                    public void onAnimationStart(Animation animation) {
                        onPopStart(nextFragments, removedFragments);
                    }

                    @Override
                    public void onAnimationEnd(Animation animation) {
                        onPopEnd(nextFragments, removedFragments);
                    }

                    @Override
                    public void onAnimationRepeat(Animation animation) {

                    }
                });
            }
        }

        // add
        addFragments(insertedFragments);

        // remove
        removeFragments(removedFragments);

        // update
        updateFragments(nextFragments);

        mStack.clear();
        mStack.addAll(nextFragments);

        if (animIds[0] == 0 && animIds[1] == 0) {
            if (isPushAction) {
                onPushStart(nextFragments, removedFragments);
                tryCommitTransaction();
                onPushEnd(nextFragments, removedFragments);
            } else {
                onPopStart(nextFragments, removedFragments);
                tryCommitTransaction();
                onPopEnd(nextFragments, removedFragments);
            }
        } else {
            tryCommitTransaction();
        }
    }

    private void addFragments(ArrayList<T> fragments) {
        for (T fragment : fragments) {
            getOrCreateTransaction().add(getId(), fragment);
        }
    }

    private void updateFragments(ArrayList<T> nextFragments) {
        for (int index = 0, size = nextFragments.size(); index < size; index ++) {
            boolean show;
            if (index + 1 == size) {
                show = true;
            } else {
                SceneFragment nextFragment = nextFragments.get(index + 1);
                show = nextFragment.getScene().isTransparent();
            }
            SceneFragment fragment = nextFragments.get(index);
            if (show && !fragment.isVisible()) {
                getOrCreateTransaction().show(fragment);
            } else if (!show && fragment.isVisible()) {
                getOrCreateTransaction().hide(fragment);
            }
        }
    }

    private void removeFragments(ArrayList<T> fragments) {
        for (T scene : fragments) {
            getOrCreateTransaction().remove(scene);
        }
    }

    private void onPopEnd(ArrayList<T> nextFragments, ArrayList<T> removedFragments) {
        didBlur(nextFragments, removedFragments);
        didFocus(nextFragments);
    }

    private void onPopStart(ArrayList<T> nextFragments, ArrayList<T> removedFragments) {
        willBlur(nextFragments, removedFragments);
        willFocus(nextFragments);
    }

    private void onPushEnd(ArrayList<T> nextFragments, ArrayList<T> removedFragments) {
        didFocus(nextFragments);
        didBlur(nextFragments, removedFragments);
    }

    private void onPushStart(ArrayList<T> nextFragments, ArrayList<T> removedFragments) {
        willFocus(nextFragments);
        willBlur(nextFragments, removedFragments);
    }

    private void didFocus(ArrayList<T> nextFragments) {
        int size = nextFragments.size();
        if (size > 0) {
            T fragment = nextFragments.get(size - 1);
            fragment.getScene().setStatus(Scene.SceneStatus.DID_FOCUS);
        }
    }

    private void didBlur(ArrayList<T> nextFragments, ArrayList<T> removedFragments) {
        int size = nextFragments.size();
        for (int index = 0; index + 1 < size; index++) {
            T fragment = nextFragments.get(index);
            fragment.getScene().setStatus(Scene.SceneStatus.DID_BLUR);
        }
        for (T fragment: removedFragments) {
            fragment.getScene().setStatus(Scene.SceneStatus.DID_BLUR, true);
        }
    }

    private void willFocus(ArrayList<T> nextFragments) {
        int size = nextFragments.size();
        if (size > 0) {
            T fragment = nextFragments.get(size - 1);
            fragment.getScene().setStatus(Scene.SceneStatus.WILL_FOCUS);
        }
    }

    private void willBlur(ArrayList<T> nextFragments, ArrayList<T> removedFragments) {
        int size = nextFragments.size();
        for (int index = 0; index + 1 < size; index++) {
            T fragment = nextFragments.get(index);
            fragment.getScene().setStatus(Scene.SceneStatus.WILL_BLUR);
        }
        for (T fragment: removedFragments) {
            fragment.getScene().setStatus(Scene.SceneStatus.WILL_BLUR);
        }
    }

    abstract void getAnimationOnPush(Scene scene, int[] anim);

    abstract void getAnimationOnPop(Scene scene, int[] anim);

}
