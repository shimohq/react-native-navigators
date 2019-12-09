package im.shimo.navigators;

import android.content.Context;
import android.content.ContextWrapper;
import android.os.Parcelable;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;

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

public abstract class SceneContainer extends ViewGroup {

    private static final String TAG = "SceneContainer";
    protected final ArrayList<Scene> mSceneFragments = new ArrayList<>();
    protected final ArrayList<Scene> mStack = new ArrayList<>();

    protected final Set<Scene> mDismissed = new HashSet<>();


    @Nullable
    private FragmentTransaction mCurrentTransaction;

    private boolean mNeedUpdate = true;
    private boolean mIsAttached;
    private boolean mLayoutEnqueued = false;
    private boolean mIsPostingFrame;

    private ChoreographerCompat.FrameCallback mFrameCallback = new ChoreographerCompat.FrameCallback() {
        @Override
        public void doFrame(long frameTimeNanos) {
            updateIfNeeded();
            mIsPostingFrame = false;
        }
    };

    public SceneContainer(Context context) {
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

//    @SuppressWarnings("unchecked")
//    protected T adapt(Scene scene) {
//        SceneFragment sceneFragment = new SceneFragment();
//        sceneFragment.setSceneView(scene);
//        return (T) sceneFragment;
//    }

    protected void markUpdated() {
        if (!mIsPostingFrame) {
            mIsPostingFrame = true;
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
//        addView(scene, index);
        mSceneFragments.add(index, scene);
        scene.setContainer(this);
        markUpdated();
    }

    protected void removeSceneAt(int index) {
        mSceneFragments.get(index).setContainer(null);
        mSceneFragments.remove(index);
        markUpdated();
    }

    protected int getSceneCount() {
        return mSceneFragments.size();
    }


    protected Scene getSceneAt(int index) {
        return mSceneFragments.get(index);
    }


    @Nullable
    @Override
    protected Parcelable onSaveInstanceState() {
        return super.onSaveInstanceState();
    }


    @Override
    protected void onRestoreInstanceState(Parcelable state) {
        super.onRestoreInstanceState(state);

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
        if (mNeedUpdate && mIsAttached) {
            onUpdate();
        }
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
        return size > 0 ? mStack.get(size - 1) : null;
    }

    protected void onUpdate() {
        // 看能不能用task在 阻塞,
        // 貌似可以用信号量?
        mNeedUpdate = false;
        final ArrayList<Scene> nextFragments = new ArrayList<>();
        for (Scene scene : mSceneFragments) {
            if (!scene.isClosing()) {
                nextFragments.add(scene);
            }
        }

        final ArrayList<Scene> removedFragments = new ArrayList<>();
        for (Scene scene : mStack) {
            if (scene.isClosing() || !mSceneFragments.contains(scene)) {
                removedFragments.add(scene);
            }
        }

        ArrayList<Scene> insertedFragments = new ArrayList<>();
        for (Scene fragment : nextFragments) {
            if (!mStack.contains(fragment)) {
                insertedFragments.add(fragment);
            }
        }

        // find top scene
        Scene nextTopFragment = nextFragments.size() > 0 ? nextFragments.get(nextFragments.size() - 1) : null;
        Scene currentTopFragment = mStack.size() > 0 ? mStack.get(mStack.size() - 1) : null;

        // save or restore focused view
        if (currentTopFragment != nextTopFragment) {
            if (currentTopFragment != null && !removedFragments.contains(currentTopFragment)) {
                currentTopFragment.saveFocusedView();
            }
            if (nextTopFragment != null && mStack.contains(nextTopFragment)) {
                nextTopFragment.restoreFocus();
            }
        }

        int[] animIds = new int[2];
        boolean isPushAction = false;
        if (currentTopFragment != null && currentTopFragment != nextTopFragment) {
            if (nextTopFragment != null && !mStack.contains(nextTopFragment)) { // push
                isPushAction = true;
                getAnimationOnPush(nextTopFragment, animIds);
                Animation enter = loadAnimation(animIds[0]);
                Animation exit = loadAnimation(animIds[1]);
                if (enter != null) {
                    nextTopFragment.setAnimation(enter);
                }
                if (exit != null) {
                    currentTopFragment.setAnimation(exit);
                }
                Animation anim = enter != null ? enter : exit;
                if (anim != null) {
                    anim.setAnimationListener(new Animation.AnimationListener() {
                        @Override
                        public void onAnimationStart(Animation animation) {
                            onPushStart(nextFragments, removedFragments);
                        }

                        @Override
                        public void onAnimationEnd(Animation animation) {
                            onPushEnd(nextFragments, removedFragments);
                            mNeedUpdate = true;
                        }

                        @Override
                        public void onAnimationRepeat(Animation animation) {

                        }
                    });
                }
            } else if (!nextFragments.contains(currentTopFragment)) { // pop
                getAnimationOnPop(currentTopFragment, animIds);
                Animation enter = loadAnimation(animIds[0]);
                Animation exit = loadAnimation(animIds[1]);
                if (enter != null) {
                    currentTopFragment.setAnimation(exit);
                }
                if (exit != null && nextTopFragment != null) {
                    nextTopFragment.setAnimation(enter);
                }
                Animation anim = enter != null ? enter : exit;
                if (anim != null) {
                    anim.setAnimationListener(new Animation.AnimationListener() {
                        @Override
                        public void onAnimationStart(Animation animation) {
                            onPopStart(nextFragments, removedFragments);
                        }

                        @Override
                        public void onAnimationEnd(Animation animation) {
                            onPopEnd(nextFragments, removedFragments);
                            mNeedUpdate = true;
                        }

                        @Override
                        public void onAnimationRepeat(Animation animation) {

                        }
                    });
                }

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
                onPushEnd(nextFragments, removedFragments);
            } else {
                onPopStart(nextFragments, removedFragments);
                onPopEnd(nextFragments, removedFragments);
            }

            mNeedUpdate = true;
        } else {

        }
    }

    private Animation loadAnimation(int animId) {
        if (animId == 0) return null;
        return AnimationUtils.loadAnimation(getContext(), animId);
    }

    private void addFragments(ArrayList<Scene> fragments) {
        for (Scene fragment : fragments) {
            addView(fragment);
        }
    }

    private void updateFragments(ArrayList<Scene> nextFragments) {
        for (int index = 0, size = nextFragments.size(); index < size; index++) {
            boolean show;
            if (index + 1 == size) {
                show = true;
            } else {
                Scene nextFragment = nextFragments.get(index + 1);
                show = nextFragment.isTransparent();
            }
            final Scene fragment = nextFragments.get(index);
            if (show && fragment.getVisibility() != VISIBLE) {
                fragment.setVisibility(VISIBLE);
            } else if (!show && fragment.getVisibility() == VISIBLE) {
                fragment.setVisibility(GONE);
            }
        }
    }

    private void removeFragments(ArrayList<Scene> fragments) {
        for (Scene scene : fragments) {
            removeView(scene);
        }
    }

    private void onPopEnd(ArrayList<Scene> nextFragments, ArrayList<Scene> removedFragments) {
        didBlur(nextFragments, removedFragments);
        didFocus(nextFragments);
    }

    private void onPopStart(ArrayList<Scene> nextFragments, ArrayList<Scene> removedFragments) {
        willBlur(nextFragments, removedFragments);
        willFocus(nextFragments);
    }

    private void onPushEnd(ArrayList<Scene> nextFragments, ArrayList<Scene> removedFragments) {
        didFocus(nextFragments);
        didBlur(nextFragments, removedFragments);
    }

    private void onPushStart(ArrayList<Scene> nextFragments, ArrayList<Scene> removedFragments) {
        willFocus(nextFragments);
        willBlur(nextFragments, removedFragments);
    }

    private void didFocus(ArrayList<Scene> nextFragments) {
        int size = nextFragments.size();
        if (size > 0) {
            Scene fragment = nextFragments.get(size - 1);
            fragment.setStatus(Scene.SceneStatus.DID_FOCUS);
        }
    }

    private void didBlur(ArrayList<Scene> nextFragments, ArrayList<Scene> removedFragments) {
        int size = nextFragments.size();
        for (int index = 0; index + 1 < size; index++) {
            Scene fragment = nextFragments.get(index);
            fragment.setStatus(Scene.SceneStatus.DID_BLUR);
        }
        for (Scene fragment : removedFragments) {
            fragment.setStatus(Scene.SceneStatus.DID_BLUR, true);
        }
    }

    private void willFocus(ArrayList<Scene> nextFragments) {
        int size = nextFragments.size();
        if (size > 0) {
            Scene fragment = nextFragments.get(size - 1);
            fragment.setStatus(Scene.SceneStatus.WILL_FOCUS);
        }
    }

    private void willBlur(ArrayList<Scene> nextFragments, ArrayList<Scene> removedFragments) {
        int size = nextFragments.size();
        for (int index = 0; index + 1 < size; index++) {
            Scene fragment = nextFragments.get(index);
            fragment.setStatus(Scene.SceneStatus.WILL_BLUR);
        }
        for (Scene fragment : removedFragments) {
            fragment.setStatus(Scene.SceneStatus.WILL_BLUR);
        }
    }

    abstract void getAnimationOnPush(Scene scene, int[] anim);

    abstract void getAnimationOnPop(Scene scene, int[] anim);

}
