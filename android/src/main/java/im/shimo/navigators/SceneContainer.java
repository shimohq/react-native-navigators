package im.shimo.navigators;

import android.content.Context;
import android.graphics.Rect;
import android.util.Log;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;

import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentTransaction;

import com.facebook.react.bridge.ReactContext;
import com.facebook.react.modules.core.ChoreographerCompat;
import com.facebook.react.modules.core.ReactChoreographer;
import com.facebook.react.uimanager.UIManagerModule;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

/**
 * Created by jiang on 2019-11-06
 */

public abstract class SceneContainer extends ViewGroup {

  private static final String TAG = "SceneContainer";
  protected final ArrayList<Scene> mScenes = new ArrayList<>();
  protected final ArrayList<Scene> mStack = new ArrayList<>();

  protected final Set<Scene> mDismissed = new HashSet<>();


  @Nullable
  private FragmentTransaction mCurrentTransaction;

  private boolean mNeedUpdate = true;
  private boolean mNeedUpdateOnAnimEnd = false;
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


  private final Runnable mLayoutRunnable = () -> {
    mLayoutEnqueued = false;
    measure(MeasureSpec.makeMeasureSpec(getWidth(), MeasureSpec.EXACTLY),
      MeasureSpec.makeMeasureSpec(getHeight(), MeasureSpec.EXACTLY));
    layout(getLeft(), getTop(), getRight(), getBottom());
  };

  @Override
  public void requestLayout() {
    super.requestLayout();
    if (!mLayoutEnqueued) {
      mLayoutEnqueued = true;
      post(mLayoutRunnable);
    }
  }

  private Rect mRect = new Rect();

  @Override
  protected void onSizeChanged(int w, int h, int oldw, int oldh) {
    super.onSizeChanged(w, h, oldw, oldh);
    final ReactContext reactContext = (ReactContext) getContext();
    mRect.set(getLeft(), getTop(), w, h);
    Log.d(TAG, "onSizeChanged() called with: mRect = [" + mRect + "], h = [" + h + "], oldw = [" + oldw + "], oldh = [" + oldh + "]");
    reactContext.getNativeModule(UIManagerModule.class).setViewLocalData(getId(), mRect);
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
    scene.setVisibility(INVISIBLE);
    addView(scene, index);
    mScenes.add(index, scene);
    scene.setContainer(this);
    Log.d(TAG, "addScene() called with: scene = [" + scene + "], index = [" + index + "], size :" + mScenes.size());
    markUpdated();
  }

  protected void removeSceneAt(int index) {
    mScenes.get(index).setContainer(null);
    mScenes.remove(index);
    Log.d(TAG, "removeSceneAt() called with: index = [" + index + "], size :" + mScenes.size());
    markUpdated();
  }

  protected int getSceneCount() {
    return mScenes.size();
  }


  protected Scene getSceneAt(int index) {
    return mScenes.get(index);
  }

  protected int indexOfScene(Scene scene) {
    return mScenes.indexOf(scene);
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

  public void updateIfNeeded() {
    if (!mIsAttached) return;
    if (mNeedUpdate) {
      onUpdate();
    } else {
      mNeedUpdateOnAnimEnd = true;
    }
  }

  public Scene getRootScreen() {
    for (int i = 0, size = getSceneCount(); i < size; i++) {
      Scene scene = getSceneAt(i);
      if (!mDismissed.contains(scene)) {
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
    mNeedUpdate = false;
    final ArrayList<Scene> nextFragments = new ArrayList<>();
    for (Scene scene : mScenes) {
      if (!scene.isClosing()) {
        nextFragments.add(scene);
      }
    }

    final ArrayList<Scene> removedScene = new ArrayList<>();
    for (Scene scene : mStack) {
      if (scene.isClosing() || !mScenes.contains(scene)) {
        removedScene.add(scene);
      }
    }

//        ArrayList<Scene> insertedFragments = new ArrayList<>();
//        for (Scene fragment : nextFragments) {
//            if (!mStack.contains(fragment)) {
//                insertedFragments.add(fragment);
//            }
//        }

    // find top scene
    Scene nextTopScene = getTopScene(nextFragments);
    Scene currentTopScene = getTopScene(mStack);

    // save or restore focused view
    if (currentTopScene != nextTopScene) {
      if (currentTopScene != null && !removedScene.contains(currentTopScene)) {
        currentTopScene.saveFocusedView();
      }
      if (nextTopScene != null && mStack.contains(nextTopScene)) {
        nextTopScene.restoreFocus();
      }
    }

    int[] animIds = new int[2];
    Animation anim = null;
    boolean isPushAction = false;
    if (currentTopScene != nextTopScene) {
      if (nextTopScene != null && !mStack.contains(nextTopScene)) { // push
        isPushAction = true;
        getAnimationOnPush(nextTopScene, animIds);

        Animation enter = loadAnimation(animIds[0]);
        Animation exit = loadAnimation(animIds[1]);
        if (enter != null) {
          nextTopScene.setAnimation(enter);
          anim = enter;
        }
        if (exit != null && currentTopScene != null) {
          currentTopScene.setAnimation(exit);
          anim = exit;
        }

        if (anim != null) {
          anim.setAnimationListener(new Animation.AnimationListener() {
            @Override
            public void onAnimationStart(Animation animation) {
              onPushStart(nextFragments, removedScene);
            }

            @Override
            public void onAnimationEnd(Animation animation) {
              hideFragments(nextFragments);
              onPushEnd(nextFragments, removedScene);
              mNeedUpdate = true;
              if (mNeedUpdateOnAnimEnd) {
                mNeedUpdateOnAnimEnd = false;
                markUpdated();
              }
            }

            @Override
            public void onAnimationRepeat(Animation animation) {

            }
          });
        }
      } else if (!nextFragments.contains(currentTopScene)) { // pop
        getAnimationOnPop(currentTopScene, animIds);
        Animation enter = loadAnimation(animIds[0]);
        Animation exit = loadAnimation(animIds[1]);

        if (enter != null && currentTopScene != null) {
          currentTopScene.setAnimation(exit);
          anim = exit;
        }
        if (exit != null && nextTopScene != null) {
          nextTopScene.setAnimation(enter);
          anim = enter;
        }
        if (anim != null) {
          anim.setAnimationListener(new Animation.AnimationListener() {
            @Override
            public void onAnimationStart(Animation animation) {
              onPopStart(nextFragments, removedScene);
            }

            @Override
            public void onAnimationEnd(Animation animation) {
              hideFragments(nextFragments);
              onPopEnd(nextFragments, removedScene);
              mNeedUpdate = true;
              if (mNeedUpdateOnAnimEnd) {
                mNeedUpdateOnAnimEnd = false;
                markUpdated();
              }
            }

            @Override
            public void onAnimationRepeat(Animation animation) {

            }
          });
        }

      }
    }

    // add
//        addFragments(insertedFragments);

    // remove
    removeFragments(removedScene);

    // update
    showFragments(nextFragments);

    mStack.clear();
    mStack.addAll(nextFragments);

    if (anim == null) {
      if (isPushAction) {
        onPushStart(nextFragments, removedScene);
        onPushEnd(nextFragments, removedScene);
      } else {
        onPopStart(nextFragments, removedScene);
        onPopEnd(nextFragments, removedScene);
      }
      showFragments(nextFragments);
      hideFragments(nextFragments);
      mNeedUpdate = true;
    }
  }

  protected Scene getTopScene(ArrayList<Scene> scenes) {
    return scenes.size() > 0 ? scenes.get(scenes.size() - 1) : null;
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

  protected void hideFragments(ArrayList<Scene> nextFragments) {
    for (int index = 0, size = nextFragments.size(); index < size; index++) {
      boolean show = isShow(nextFragments, index, size);
      final Scene fragment = nextFragments.get(index);
      if (!show && fragment.getVisibility() == VISIBLE) {
        fragment.setVisibility(GONE);
      }
    }
  }

  protected void showFragments(ArrayList<Scene> nextFragments) {
    for (int index = 0, size = nextFragments.size(); index < size; index++) {
      boolean show = isShow(nextFragments, index, size);
      final Scene fragment = nextFragments.get(index);
      if (show && fragment.getVisibility() != VISIBLE) {
        fragment.setVisibility(VISIBLE);
      }
    }
  }

  protected boolean isShow(ArrayList<Scene> nextFragments, int index, int size) {
    boolean show;
    if (index + 1 == size) {
      show = true;
    } else {
      Scene nextFragment = nextFragments.get(index + 1);
      show = nextFragment.isTransparent();
    }
    return show;
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
