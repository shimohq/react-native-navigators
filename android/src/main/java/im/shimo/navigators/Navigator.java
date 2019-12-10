package im.shimo.navigators;

import android.content.Context;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;

import androidx.annotation.AnimRes;
import androidx.annotation.AnimatorRes;

import com.facebook.react.bridge.ReactContext;
import com.facebook.react.uimanager.UIManagerModule;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

import im.shimo.navigators.event.WillBlurEvent;
import im.shimo.navigators.event.WillFocusEvent;

/**
 * Created by jiang on 2019-11-11
 */

public class Navigator {

    private final SceneContainer mContainer;
    private final Context mContext;
    private Scene mTopScene = null;
    private Scene mLastTopScene = null;
    private Scene mBelowTop;

    private final ArrayList<Scene> mScenes = new ArrayList<>();
    private final ArrayList<Scene> mStack = new ArrayList<>();
    private final Set<Scene> mDismissed = new HashSet<>();

    private EnterAnimationListener mEnterAnimationListener;
    private ExitAnimationListener mExitAnimationListener;

    public Navigator(SceneContainer container) {
        mContainer = container;
        mContext = mContainer.getContext();
        mEnterAnimationListener = new EnterAnimationListener();
        mExitAnimationListener = new ExitAnimationListener();
    }

    public void push(Scene scene, int index) {
        scene.setContainer(mContainer);
        mScenes.add(index, scene);
        mContainer.addView(scene, index);
    }


    public void removeAt(int index) {
        mScenes.remove(index);
    }

    public void findTopScene() {
        Scene newTop = null;
        Scene belowTop = null;
        for (int i = mScenes.size() - 1; i >= 0; i--) {
            Scene scene = mScenes.get(i);
            if (!mDismissed.contains(scene)) {
                if (newTop == null) {
                    newTop = scene;
                } else {
                    belowTop = scene;
                    break;
                }
            }
        }
        mTopScene = newTop;
        mBelowTop = belowTop;
    }

    private TransitionAnimationInfo getTransitionAnimation(Scene scene) {
        int enterAnimation = 0;
        int exitAnimation = 0;
        switch (scene.getStackAnimation()) {
            case NONE:
                break;
            case DEFAULT:
            case SLIDE_FROM_RIGHT:
                enterAnimation = R.anim.slide_in_right;
                exitAnimation = R.anim.slide_out_left_p50;
                break;
            case SLIDE_FROM_LEFT:
                enterAnimation = R.anim.slide_in_left;
                exitAnimation = R.anim.slide_out_right_p50;
                break;
            default:
            case SLIDE_FROM_TOP:
                enterAnimation = R.anim.slide_in_top;
                break;
            case SLIDE_FROM_BOTTOM:
                enterAnimation = R.anim.slide_in_bottom;
                break;
        }
        return new TransitionAnimationInfo(enterAnimation, exitAnimation);
    }


    public void navigate() {
        doNavigate();
    }

    private boolean isEnter(Scene scene) {
        return !mStack.contains(scene);
    }


    private void doNavigate() {
        if (mTopScene != null && mTopScene.isClosing()) {
            if (!mDismissed.contains(mTopScene)) {
                mDismissed.add(mTopScene);
            }
        }

        Scene newTop = null;
        Scene belowTop = null;
        for (int i = mScenes.size() - 1; i >= 0; i--) {
            Scene scene = mScenes.get(i);
            if (!mDismissed.contains(scene)) {
                if (newTop == null) {
                    newTop = scene;
                } else {
                    belowTop = scene;
                    break;
                }
            }
        }

        if (newTop == null) return;
        final Scene finalNewTop = newTop;
        Animation enterAnimation = null;
        Animation exitAnimation = null;
        if (isEnter(newTop)) {
            final TransitionAnimationInfo transitionAnimation = getTransitionAnimation(newTop);
            if (transitionAnimation.mEnterAnimation != 0) {
                enterAnimation = AnimationUtils.loadAnimation(mContext, transitionAnimation.mEnterAnimation);
            }
            if (transitionAnimation.mExitAnimation != 0) {
                exitAnimation = AnimationUtils.loadAnimation(mContext, transitionAnimation.mExitAnimation);
            }

            if (enterAnimation != null) {
                enterAnimation.setAnimationListener(new Animation.AnimationListener() {
                    @Override
                    public void onAnimationStart(Animation animation) {
                        mTopScene.setVisibility(View.VISIBLE);
//                        finalNewTop.restoreFocus();
                        for (Scene scene : mScenes) {
                            // detach all scenes that should not be visible
                            if (scene != mTopScene && !mDismissed.contains(scene)
                                    && !scene.isClosing()) {
                                scene.saveFocusedView();
                            }
                        }
                    }

                    @Override
                    public void onAnimationEnd(Animation animation) {
                        for (Scene scene : mScenes) {
                            // detach all scenes that should not be visible
                            if (scene != mTopScene && !mDismissed.contains(scene)
                                    && !scene.isClosing()) {
                                scene.setVisibility(View.GONE);
                            }
                        }
                    }

                    @Override
                    public void onAnimationRepeat(Animation animation) {

                    }
                });
            } else if (exitAnimation != null) {
                exitAnimation.setAnimationListener(new Animation.AnimationListener() {
                    @Override
                    public void onAnimationStart(Animation animation) {
                        mTopScene.setVisibility(View.VISIBLE);
                        mTopScene.restoreFocus();
                    }

                    @Override
                    public void onAnimationEnd(Animation animation) {
                        for (Scene scene : mScenes) {
                            // detach all scenes that should not be visible
                            if (scene != mTopScene && !mDismissed.contains(scene)
                                    && !scene.isClosing()) {
                                if (scene.hasFocus()) {
                                    scene.saveFocusedView();
                                }
                                scene.setVisibility(View.GONE);
                            }
                        }
                    }

                    @Override
                    public void onAnimationRepeat(Animation animation) {

                    }
                });
            }

            newTop.setAnimation(enterAnimation);
            if (belowTop != null) {
                belowTop.setAnimation(exitAnimation);
            }
            ((ReactContext) mContext)
                    .getNativeModule(UIManagerModule.class)
                    .getEventDispatcher()
                    .dispatchEvent(new WillFocusEvent(newTop.getId()));





        } else if (mTopScene != null && !mTopScene.equals(newTop)) { // out
            switch (mTopScene.getStackAnimation()) {
                case NONE:
                    break;
                default:
                case DEFAULT:
                case SLIDE_FROM_RIGHT:
                    enterAnimation = AnimationUtils.loadAnimation(mContext, R.anim.slide_in_left_p50);
                    exitAnimation = AnimationUtils.loadAnimation(mContext, R.anim.slide_out_right);
                    break;
                case SLIDE_FROM_LEFT:
                    enterAnimation = AnimationUtils.loadAnimation(mContext, R.anim.slide_in_right_p50);
                    exitAnimation = AnimationUtils.loadAnimation(mContext, R.anim.slide_out_left);
                    break;
                case SLIDE_FROM_TOP:
                    exitAnimation = AnimationUtils.loadAnimation(mContext, R.anim.slide_out_top);
                    break;
                case SLIDE_FROM_BOTTOM:
                    exitAnimation = AnimationUtils.loadAnimation(mContext, R.anim.slide_out_bottom);
                    break;
            }
            if (enterAnimation != null) {
                enterAnimation.setAnimationListener(new Animation.AnimationListener() {
                    @Override
                    public void onAnimationStart(Animation animation) {
                        finalNewTop.setVisibility(View.VISIBLE);
                        //finalNewTop.restoreFocus();
                    }

                    @Override
                    public void onAnimationEnd(Animation animation) {
                        for (Scene scene : mScenes) {
                            // detach all scenes that should not be visible
                            if (scene != mTopScene && !mDismissed.contains(scene)
                                    && !scene.isClosing()) {
                                if (scene.hasFocus()) {
                                    scene.saveFocusedView();
                                }
                                scene.setVisibility(View.GONE);
                            }
                        }
                    }

                    @Override
                    public void onAnimationRepeat(Animation animation) {

                    }
                });
            } else if (exitAnimation != null) {
                exitAnimation.setAnimationListener(new Animation.AnimationListener() {
                    @Override
                    public void onAnimationStart(Animation animation) {
                        finalNewTop.setVisibility(View.VISIBLE);
                        finalNewTop.restoreFocus();

                    }

                    @Override
                    public void onAnimationEnd(Animation animation) {
                        for (Scene scene : mScenes) {
                            // detach all scenes that should not be visible
                            if (scene != mTopScene && !mDismissed.contains(scene)
                                    && !scene.isClosing()) {
                                if (scene.hasFocus()) {
                                    scene.saveFocusedView();
                                }
                                scene.setVisibility(View.GONE);
                            }
                        }
                    }

                    @Override
                    public void onAnimationRepeat(Animation animation) {

                    }
                });
            }

            newTop.setAnimation(enterAnimation);
            mTopScene.setAnimation(exitAnimation);
            ((ReactContext) mContext)
                    .getNativeModule(UIManagerModule.class)
                    .getEventDispatcher()
                    .dispatchEvent(new WillBlurEvent(mTopScene.getId()));
        }

        if (newTop.isTransparent()) {
            mDismissed.add(newTop);
        }

        for (Scene scene : mStack) {
            if (!mScenes.contains(scene) || mDismissed.contains(scene)) {
                mContainer.removeView(scene);
            }
        }
        mTopScene = newTop;

        mStack.clear();
        mStack.addAll(mScenes);


    }


    private void setTransitionAnimation(@AnimatorRes @AnimRes int enter,
                                        @AnimatorRes @AnimRes int exit) {

    }


    private static class EnterAnimationListener implements Animation.AnimationListener {

        private View mTopView;
        private View mBelowView;

        public void setAnimationView(View topView, View belowView) {
            mTopView = topView;
            mBelowView = belowView;
        }

        @Override
        public void onAnimationStart(Animation animation) {

        }

        @Override
        public void onAnimationEnd(Animation animation) {

        }

        @Override
        public void onAnimationRepeat(Animation animation) {

        }
    }


    private static class ExitAnimationListener implements Animation.AnimationListener {
        @Override
        public void onAnimationStart(Animation animation) {

        }

        @Override
        public void onAnimationEnd(Animation animation) {

        }

        @Override
        public void onAnimationRepeat(Animation animation) {

        }
    }

    private static class TransitionAnimationInfo {

        private int mEnterAnimation;

        private int mExitAnimation;

        public TransitionAnimationInfo(int enterAnimation, int exitAnimation) {
            mEnterAnimation = enterAnimation;
            mExitAnimation = exitAnimation;
        }

        public int getEnterAnimation() {
            return mEnterAnimation;
        }

        public int getExitAnimation() {
            return mExitAnimation;
        }
    }

}
