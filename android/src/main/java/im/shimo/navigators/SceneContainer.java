package im.shimo.navigators;

import android.content.Context;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;

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

public abstract class SceneContainer extends ViewGroup {

    private static final String TAG = "SceneContainer";
    protected final ArrayList<Scene> mSceneFragments = new ArrayList<>();
    protected final ArrayList<Scene> mStack = new ArrayList<>();
    protected final Set<Scene> mDismissed = new HashSet<>();
    protected final ArrayList<Scene> mWellAdded = new ArrayList<>();


    private Navigator mNavigator;


    private boolean mNeedUpdate;
    private boolean mIsAttached;

    protected Scene mTopScene = null;


    private ChoreographerCompat.FrameCallback mFrameCallback = new ChoreographerCompat.FrameCallback() {
        @Override
        public void doFrame(long frameTimeNanos) {
            updateIfNeeded();
        }
    };

    public SceneContainer(Context context) {
        super(context);
        mNavigator = new Navigator(this);
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        // no-op
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
//        T fragment = adapt(scene);
//        scene.setFragment(fragment);
        scene.setVisibility(INVISIBLE);
        mSceneFragments.add(index, scene);
        scene.setContainer(this);
        addView(scene, index);
//        mNavigator.push(scene,index);
        markUpdated();
    }

    protected void removeSceneAt(int index) {
        mSceneFragments.get(index).setContainer(null);
        mSceneFragments.remove(index);
//        mNavigator.removeAt(index);
        markUpdated();
    }

    protected int getSceneCount() {
        return mSceneFragments.size();
    }


    protected Scene getSceneAt(int index) {
        return mSceneFragments.get(index);
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
        if (!mNeedUpdate || !mIsAttached) {
            return;
        }
        mNeedUpdate = false;
        onUpdate();
    }


    public Scene getTopScene() {
        return mTopScene;
    }


    protected void onUpdate() {
//        mNavigator.navigate();
        for (Scene scene : mSceneFragments) {
            if (scene.isClosing()) {
                mDismissed.add(scene);
            }
            if (!mStack.contains(scene)) {
                mWellAdded.add(scene);
            }
        }

        Scene newTop = null;
        Scene belowTop = null;

        // find top scene
        for (int i = mSceneFragments.size() - 1; i >= 0; i--) {
            Scene scene = mSceneFragments.get(i);
            if (!mDismissed.contains(scene)) {
                if (newTop == null) {
                    newTop = scene;
                } else {
                    belowTop = scene;
                    break;
                }
            }
        }
        if (newTop.isTransparent()) {
            mDismissed.add(belowTop);
        }


        if (newTop == null) return;
        final Scene finalNewTop = newTop;
        Animation enterAnimation = null;
        Animation exitAnimation = null;
        if (!mStack.contains(newTop)) {
            int[] animIds = new int[2];
            getAnimationOnPush(newTop, animIds);
            enterAnimation = AnimationUtils.loadAnimation(getContext(), animIds[0]);
            exitAnimation = AnimationUtils.loadAnimation(getContext(), animIds[1]);

            final Scene finalBelowTop = belowTop;
            enterAnimation.setAnimationListener(new Animation.AnimationListener() {
                @Override
                public void onAnimationStart(Animation animation) {
                    finalNewTop.setVisibility(VISIBLE);
                    for (Scene scene : mSceneFragments) {
                        if (scene != finalNewTop && !mDismissed.contains(scene)
                                && scene.getVisibility() == VISIBLE) {
                            scene.saveFocusedView();
                        }
                    }
                    ((ReactContext) getContext())
                            .getNativeModule(UIManagerModule.class)
                            .getEventDispatcher()
                            .dispatchEvent(new WillFocusEvent(finalNewTop.getId()));
                    if (finalBelowTop != null) {
                        ((ReactContext) getContext())
                                .getNativeModule(UIManagerModule.class)
                                .getEventDispatcher()
                                .dispatchEvent(new WillBlurEvent(finalBelowTop.getId()));
                    }


                }

                @Override
                public void onAnimationEnd(Animation animation) {
                    for (Scene scene : mSceneFragments) {
                        // detach all scenes that should not be visible
                        if (scene != finalNewTop && !mDismissed.contains(scene)
                                && scene.getVisibility() == VISIBLE) {
                            scene.setVisibility(GONE);
                        }
                    }

                    ((ReactContext) getContext())
                            .getNativeModule(UIManagerModule.class)
                            .getEventDispatcher()
                            .dispatchEvent(new DidFocusEvent(finalNewTop.getId()));
                    if (finalBelowTop != null) {
                        ((ReactContext) getContext())
                                .getNativeModule(UIManagerModule.class)
                                .getEventDispatcher()
                                .dispatchEvent(new DidBlurEvent(finalBelowTop.getId(), false));
                    }


                }

                @Override
                public void onAnimationRepeat(Animation animation) {

                }
            });
            newTop.setAnimation(enterAnimation);
            if (mTopScene != null) {
                mTopScene.setAnimation(exitAnimation);
            }

        } else if (mTopScene != null && !mTopScene.equals(newTop)) { // out
            int[] animIds = new int[2];
            getAnimationOnPop(mTopScene, animIds);
            enterAnimation = AnimationUtils.loadAnimation(getContext(), animIds[0]);
            exitAnimation = AnimationUtils.loadAnimation(getContext(), animIds[1]);


            enterAnimation.setAnimationListener(new Animation.AnimationListener() {
                @Override
                public void onAnimationStart(Animation animation) {
                    finalNewTop.setVisibility(VISIBLE);
                    finalNewTop.restoreFocus();
                    final EventDispatcher eventDispatcher = ((ReactContext) getContext())
                            .getNativeModule(UIManagerModule.class)
                            .getEventDispatcher();

                    for (Scene scene : mDismissed) {
                        eventDispatcher.dispatchEvent(new WillBlurEvent(scene.getId()));
                    }
                    eventDispatcher
                            .dispatchEvent(new WillFocusEvent(mTopScene.getId()));
                }

                @Override
                public void onAnimationEnd(Animation animation) {
                    final EventDispatcher eventDispatcher = ((ReactContext) getContext())
                            .getNativeModule(UIManagerModule.class)
                            .getEventDispatcher();

                    ((ReactContext) getContext())
                            .getNativeModule(UIManagerModule.class)
                            .getEventDispatcher()
                            .dispatchEvent(new DidFocusEvent(finalNewTop.getId()));

                    for (Scene scene : mDismissed) {
                        eventDispatcher.dispatchEvent(new DidBlurEvent(scene.getId(), true));
                    }
                    mDismissed.clear();
                }

                @Override
                public void onAnimationRepeat(Animation animation) {

                }
            });
            newTop.setAnimation(enterAnimation);
            mTopScene.setAnimation(exitAnimation);
        }


        for (Scene scene : mStack) {
            if (!mSceneFragments.contains(scene) || mDismissed.contains(scene)) {
                removeView(scene);
            }
        }
        mTopScene = newTop;

        mStack.clear();
        mStack.addAll(mSceneFragments);

    }

    abstract void getAnimationOnPush(Scene scene, int[] anim);

    abstract void getAnimationOnPop(Scene scene, int[] anim);

}
